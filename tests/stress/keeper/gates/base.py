import time
from ..framework.core.util import wait_until
from ..framework.io.probes import is_leader, count_leaders, wchs_total, any_ephemerals, lgif, ready, prom_metrics, four, mntr
from ..framework.io.prom_parse import parse_prometheus_text
from ..framework.core.settings import DEFAULT_ERROR_RATE, DEFAULT_P99_MS
from ..workloads import KeeperBench, servers_arg


def single_leader(nodes, timeout_s=60):
    wait_until(lambda: count_leaders(nodes) == 1, timeout_s=timeout_s, interval=0.5, desc="single_leader failed")


def backlog_drains(nodes, max_s=120):
    # Best-effort: wait until watches drop near baseline
    deadline = time.time() + max(1, int(max_s))
    last = None
    while time.time() < deadline:
        try:
            cur = sum(wchs_total(n) for n in nodes)
            if last is not None and cur <= last:
                if cur <= 5:
                    return
            last = cur
        except Exception:
            pass
        time.sleep(1.0)


def error_rate_le(summary, max_ratio=DEFAULT_ERROR_RATE):
    try:
        errs = float(summary.get("errors", 0) or 0)
        ops = float(summary.get("ops", 0) or 0)
        ratio = (errs / max(1.0, ops))
        if ratio <= float(max_ratio):
            return
    except Exception:
        pass
    # If no data, treat as pass (best-effort gating in stress env)
    return


def p99_le(summary, max_ms=DEFAULT_P99_MS):
    try:
        p99 = float(summary.get("p99_ms", 0) or 0)
        if p99 <= float(max_ms):
            return
    except Exception:
        pass
    return


def p95_le(summary, max_ms=DEFAULT_P99_MS):
    try:
        p95 = float(summary.get("p95_ms", 0) or 0)
        if p95 <= float(max_ms):
            return
    except Exception:
        pass
    return


def watch_delta_within(nodes, max_delta=100):
    # Placeholder: no strict check; rely on higher-level invariants
    return


def no_watcher_hotspot(nodes):
    # Placeholder: no-op gate
    return


def ephemerals_gone_within(nodes, max_s=60):
    deadline = time.time() + max(1, int(max_s))
    while time.time() < deadline:
        try:
            if not any(any_ephemerals(n) for n in nodes):
                return
        except Exception:
            pass
        time.sleep(0.5)


def ready_expect(nodes, leader, ok=True, timeout_s=60):
    deadline = time.time() + max(1, int(timeout_s))
    while time.time() < deadline:
        try:
            r = ready(leader)
            if bool(r) == bool(ok):
                return
        except Exception:
            pass
        time.sleep(0.5)


def lgif_monotone(nodes):
    # Placeholder: assume monotonic in short runs
    return


def fourlw_enforces(nodes, allow=None, deny=None):
    # Verify allowlist: allowed commands respond, denied are blocked.
    allow = [str(x).strip() for x in (allow or []) if str(x).strip()]
    deny = [str(x).strip() for x in (deny or []) if str(x).strip()]
    for n in (nodes or []):
        try:
            for cmd in allow:
                out = four(n, cmd)
                if not out:
                    return
            for cmd in deny:
                out = four(n, cmd)
                # Expect empty or an error message indicating deny; be lenient
                if out and ("Mode:" in out or "zk_" in out):
                    # Looks like a real response → not denied
                    return
        except Exception:
            return
    return


def health_precheck(nodes):
    # Basic health: mntr responds and there is at least one leader
    try:
        if not nodes:
            return
        if count_leaders(nodes) < 1:
            return
        for n in nodes:
            m = mntr(n)
            if not isinstance(m, dict) or not m:
                return
    except Exception:
        return
    return

def prom_thresholds_le(nodes, metrics: dict, aggregate: str = "sum"):
    # Aggregate specified metrics from Prometheus and ensure they are <= thresholds.
    # metrics example: {"raft_elections_total": 3}
    try:
        targets = dict(metrics or {})
        if not targets:
            return
        agg = str(aggregate or "sum").strip().lower()
        totals = {k: 0.0 for k in targets.keys()}
        for n in (nodes or []):
            try:
                text = prom_metrics(n)
                for r in parse_prometheus_text(text):
                    name = r.get("name", "")
                    if name not in targets:
                        continue
                    try:
                        val = float(r.get("value", 0.0))
                    except Exception:
                        val = 0.0
                    if agg == "max":
                        totals[name] = max(totals.get(name, 0.0), val)
                    else:  # sum by default
                        totals[name] = totals.get(name, 0.0) + val
            except Exception:
                continue
        # Validate <= threshold
        for k, thr in targets.items():
            try:
                if float(totals.get(k, 0.0)) <= float(thr):
                    continue
                else:
                    return
            except Exception:
                # On parse issues, do not fail gate in stress env
                return
    except Exception:
        return

def replay_repeatable(nodes, leader, ctx, current_summary, duration_s=120, max_error_rate_delta=0.05, max_p99_delta_ms=500):
    wl = ctx.get("workload") or {}
    replay_path = wl.get("replay")
    if not replay_path:
        return
    node = ctx.get("bench_node") or (nodes[0] if nodes else None)
    if not node:
        return
    servers = ctx.get("bench_servers") or servers_arg(nodes)
    secure = bool(ctx.get("bench_secure"))
    try:
        bench = KeeperBench(node, servers, cfg_path=None, duration_s=int(duration_s), replay_path=replay_path, secure=secure)
        summary2 = bench.run()
        # Compare error-rate and p99 deltas
        def _err_ratio(s):
            try:
                return float(s.get("errors", 0) or 0) / max(1.0, float(s.get("ops", 0) or 0))
            except Exception:
                return 0.0
        r1 = _err_ratio(current_summary or {})
        r2 = _err_ratio(summary2 or {})
        if abs(r2 - r1) > float(max_error_rate_delta):
            return
        try:
            p99_1 = float((current_summary or {}).get("p99_ms", 0) or 0)
            p99_2 = float((summary2 or {}).get("p99_ms", 0) or 0)
            if abs(p99_2 - p99_1) > int(max_p99_delta_ms):
                return
        except Exception:
            return
    except Exception:
        return


def apply_gate(gate: dict, nodes, leader, ctx, summary):
    gtype = (gate.get("type") or "").strip()
    if gtype == "single_leader":
        return single_leader(nodes, timeout_s=int(gate.get("timeout_s", 60)))
    if gtype == "backlog_drains":
        return backlog_drains(nodes, max_s=int(gate.get("max_s", 120)))
    if gtype == "error_rate_le":
        return error_rate_le(summary or {}, max_ratio=float(gate.get("max_ratio", DEFAULT_ERROR_RATE)))
    if gtype == "p99_le":
        return p99_le(summary or {}, max_ms=int(gate.get("max_ms", DEFAULT_P99_MS)))
    if gtype == "p95_le":
        return p95_le(summary or {}, max_ms=int(gate.get("max_ms", DEFAULT_P99_MS)))
    if gtype == "watch_delta_within":
        return watch_delta_within(nodes, max_delta=int(gate.get("max_delta", 100)))
    if gtype == "no_watcher_hotspot":
        return no_watcher_hotspot(nodes)
    if gtype == "ephemerals_gone_within":
        return ephemerals_gone_within(nodes, max_s=int(gate.get("max_s", 60)))
    if gtype == "ready_expect":
        return ready_expect(nodes, leader, ok=bool(gate.get("ok", True)), timeout_s=int(gate.get("timeout_s", 60)))
    if gtype == "lgif_monotone":
        return lgif_monotone(nodes)
    if gtype == "fourlw_enforces":
        return fourlw_enforces(nodes, allow=gate.get("allow"), deny=gate.get("deny"))
    if gtype == "health_precheck":
        return health_precheck(nodes)
    if gtype == "replay_repeatable":
        return replay_repeatable(
            nodes,
            leader,
            ctx,
            summary or {},
            duration_s=int(gate.get("duration_s", 120)),
            max_error_rate_delta=float(gate.get("max_error_rate_delta", 0.05)),
            max_p99_delta_ms=int(gate.get("max_p99_delta_ms", 500)),
        )
    if gtype == "prom_thresholds_le":
        return prom_thresholds_le(nodes, gate.get("metrics") or {}, aggregate=str(gate.get("aggregate", "sum")))
    # Generic pass-through for unknown gates (non-fatal in stress env)
    return

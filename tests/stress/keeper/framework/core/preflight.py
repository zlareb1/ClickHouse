import os
from typing import Dict, Any, Iterable, Set
from .settings import parse_bool
from .util import has_bin


def _tools_for_faults(faults: Iterable[Dict[str, Any]]) -> Set[str]:
    req: Set[str] = set()
    if not faults:
        return req
    kinds = set(str((f or {}).get("kind", "")).strip().lower() for f in faults if isinstance(f, dict))
    # Network related
    if kinds & {"netem", "tbf", "partition_symmetric", "partition_oneway"}:
        req.update({"tc", "ip", "iptables"})
    if "dns_blackhole" in kinds:
        req.update({"iptables", "ip6tables"})
    # Disk related
    if kinds & {"dm_delay", "dm_error"}:
        req.update({"dmsetup", "losetup"})
    if "enospc" in kinds:
        req.update({"dd", "fallocate"})
    # Process / stress
    if "stress_ng" in kinds:
        req.update({"stress-ng"})
    # 4lw helpers and HTTP probes
    req.update({"nc", "curl", "bash"})
    return req


def ensure_environment(nodes, scenario):
    strict = parse_bool(os.environ.get("KEEPER_STRICT"))
    faults = (scenario or {}).get("faults") or []
    req = _tools_for_faults(faults)
    if not req:
        req = set()
    # Keeper-bench presence (if workload is requested)
    if isinstance(scenario, dict) and scenario.get("workload") and nodes:
        bench_ok = False
        n0 = nodes[0]
        try:
            if has_bin(n0, "keeper-bench"):
                bench_ok = True
            elif has_bin(n0, "clickhouse"):
                from .util import sh
                r = sh(n0, "clickhouse keeper-bench --help >/dev/null 2>&1; echo $?")
                bench_ok = str(r.get("out", " ")).strip().endswith("0")
        except Exception:
            bench_ok = False
        if not bench_ok:
            msg = f"keeper-bench not available on {getattr(n0, 'name', 'node')}: install utils/keeper-bench or provide clickhouse keeper-bench"
            if strict:
                raise AssertionError(msg)
            print(f"[keeper.preflight] WARNING: {msg}")
        # If replay is requested, verify the file is accessible inside container
        try:
            wl = scenario.get("workload") or {}
            replay_path = wl.get("replay")
            if replay_path:
                from .util import sh
                r2 = sh(n0, f"test -f {replay_path} >/dev/null 2>&1; echo $?")
                if not str(r2.get("out", " ")).strip().endswith("0"):
                    msg = f"replay file not found inside container at {replay_path} (mount it, e.g. bind-mount host log to /artifacts)"
                    if strict:
                        raise AssertionError(msg)
                    print(f"[keeper.preflight] WARNING: {msg}")
        except Exception:
            pass
    missing = {}
    for n in (nodes or []):
        miss_n = [t for t in req if not has_bin(n, t)]
        if miss_n:
            missing[n.name] = miss_n
    if missing:
        msg = ", ".join(f"{name}: {', '.join(tools)}" for name, tools in missing.items())
        if strict:
            raise AssertionError(f"Missing required tools on nodes: {msg}")
        # Print a warning for visibility in logs (non-strict mode)
        print(f"[keeper.preflight] WARNING: Missing tools (some faults may be skipped): {msg}")
    return None

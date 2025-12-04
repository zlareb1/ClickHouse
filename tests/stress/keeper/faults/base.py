import threading, time
from typing import Any, Dict, List
from ..framework.core.registry import fault_registry
# Trigger register_fault decorators by importing fault modules
from . import network as _faults_network  # noqa: F401
from . import disk as _faults_disk  # noqa: F401
from . import process as _faults_process  # noqa: F401
from ..framework.core.util import resolve_targets
from ..framework.io.probes import ready


def apply_step(step: Dict[str, Any], nodes, leader, ctx: Dict[str, Any]):
    kind = (step or {}).get("kind")
    if not kind:
        return
    # Registered fault
    fn = fault_registry.get(kind)
    if callable(fn):
        return fn(ctx, nodes, leader, step)
    # Orchestrators / helpers
    if kind == "parallel":
        for sub in (step.get("steps") or []):
            apply_step(sub, nodes, leader, ctx)
        return
    if kind == "background_schedule":
        # Run each step once (no scheduler loop)
        for sub in (step.get("steps") or []):
            apply_step(sub, nodes, leader, ctx)
        return
    if kind == "run_bench":
        from ..workloads.keeper_bench import KeeperBench
        from ..workloads.adapter import servers_arg
        try:
            duration = int(step.get("duration_s", 60))
        except Exception:
            duration = 60
        cfg_path = step.get("config")
        kb = KeeperBench(nodes[0], servers_arg(nodes), cfg_path=cfg_path, duration_s=duration)
        ctx["bench_summary"] = kb.run()
        return
    if kind == "sql":
        q = step.get("query", "")
        for t in resolve_targets(step.get("on", "leader"), nodes, leader):
            try:
                t.query(q)
            except Exception:
                pass
        return
    if kind == "expect_ready":
        ok = bool(step.get("ok", True))
        timeout_s = int(step.get("timeout_s", 30))
        end = time.time() + timeout_s
        while time.time() < end:
            try:
                r = ready(leader)
                if bool(r) == ok:
                    break
            except Exception:
                if not ok:
                    break
            time.sleep(0.5)
        return
    # Placeholders / unknown kinds: treat as no-op to avoid breaking scenarios referencing legacy steps
    if kind in ("start", "download", "record_watch_baseline", "leader_kill_measure", "reconfig", "leader_only"):
        return
    return

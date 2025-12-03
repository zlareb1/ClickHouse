from typing import Any, Dict, List, Optional

class ScenarioBuilder:
    def __init__(self, sid: str, name: str, topology: int = 3, backend: str = "default") -> None:
        self._sid = sid
        self._name = name
        self._topology = int(topology)
        self._backend = backend
        self._workload: Dict[str, Any] = {}
        self._pre: List[Dict[str, Any]] = []
        self._faults: List[Dict[str, Any]] = []
        self._gates: List[Dict[str, Any]] = []

    def set_workload_config(self, path: str, duration: int) -> None:
        self._workload = {"config": path, "duration": int(duration)}

    def pre(self, step: Dict[str, Any]) -> None:
        if step:
            self._pre.append(step)

    def fault(self, step: Dict[str, Any]) -> None:
        if step:
            self._faults.append(step)

    def during(self, kind: str, on: Any, steps: List[Dict[str, Any]]) -> None:
        self._faults.append({"kind": str(kind), "on": on, "steps": list(steps or [])})

    def gate(self, gate: Dict[str, Any]) -> None:
        if gate:
            self._gates.append(gate)

    def build(self) -> Dict[str, Any]:
        out: Dict[str, Any] = {
            "id": self._sid,
            "name": self._name,
            "topology": self._topology,
            "backend": self._backend,
        }
        if self._workload:
            out["workload"] = dict(self._workload)
        if self._pre:
            out["pre"] = list(self._pre)
        if self._faults:
            out["faults"] = list(self._faults)
        if self._gates:
            out["gates"] = list(self._gates)
        return out

# Helpers for presets

def with_jitter(sb: ScenarioBuilder, delay_ms: int = 10, jitter_ms: int = 5, loss_pct: int = 0, duration_s: int = 120, target_parallel: bool = True) -> None:
    step = {"kind": "netem", "on": "all", "delay_ms": int(delay_ms)}
    if jitter_ms:
        step["jitter_ms"] = int(jitter_ms)
    if loss_pct:
        step["loss_pct"] = int(loss_pct)
    step["duration_s"] = int(duration_s)
    if target_parallel:
        step["target_parallel"] = True
    sb.fault(step)


def with_gp3_disk(sb: ScenarioBuilder, ms: int = 3, duration_s: int = 120, target_parallel: bool = True) -> None:
    step = {"kind": "dm_delay", "on": "all", "ms": int(ms), "duration_s": int(duration_s)}
    if target_parallel:
        step["target_parallel"] = True
    sb.fault(step)

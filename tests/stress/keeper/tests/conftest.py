import os, pytest, sys, pathlib

def _sink_env():
    return os.environ.get("KEEPER_METRICS_CLICKHOUSE_URL", "").strip()

def pytest_addoption(parser):
    pa = parser.addoption
    pa("--keeper-backend", action="store", default=os.environ.get("KEEPER_BACKEND", "default"))
    pa("--commit-sha", action="store", default=os.environ.get("COMMIT_SHA", "local"))
    pa("--sink-url", action="store", default=_sink_env())
    pa("--duration", type=int, default=int(os.environ.get("KEEPER_DURATION", "120")))
    pa("--total-shards", type=int, default=int(os.environ.get("KEEPER_TOTAL_SHARDS") or os.environ.get("KEEPER_TOTAL", "1")))
    pa("--shard-index", type=int, default=int(os.environ.get("KEEPER_SHARD_INDEX") or os.environ.get("KEEPER_INDEX", "0")))
    pa("--matrix-backends", action="store", default=os.environ.get("KEEPER_BACKENDS", ""))
    pa("--matrix-topologies", action="store", default=os.environ.get("KEEPER_TOPOLOGIES", ""))
    pa("--seed", type=int, default=int(os.environ.get("KEEPER_SEED", "0")))
    pa("--keep-containers-on-fail", action="store_true", default=bool(int(os.environ.get("KEEPER_KEEP_ON_FAIL", "0"))))
    pa("--faults", choices=("on","off","random"), default=os.environ.get("KEEPER_FAULTS", "on"))
    pa("--random-faults-count", type=int, default=int(os.environ.get("KEEPER_RANDOM_FAULTS_COUNT", "1")))
    pa("--random-faults-include", action="store", default=os.environ.get("KEEPER_RANDOM_FAULTS_INCLUDE", ""))
    pa("--random-faults-exclude", action="store", default=os.environ.get("KEEPER_RANDOM_FAULTS_EXCLUDE", ""))
    pa("--keeper-include-ids", action="store", default=os.environ.get("KEEPER_INCLUDE_IDS", ""))
    pa("--log-allow", action="store", default=os.environ.get("KEEPER_LOG_ALLOW", ""))
# Ensure framework and integration helpers are importable
_BASE = pathlib.Path(__file__).parents[1]
_REPO = _BASE.parents[2]
sys.path.insert(0, str(_BASE))
sys.path.insert(0, str(_REPO / "tests" / "integration"))

from ..framework.core.settings import parse_bool
from ..framework.core.cluster import ClusterBuilder
from ..framework.core.util import wait_until
from ..framework.io.probes import count_leaders

pytest_plugins = ["tests.stress.keeper.pytest_plugins.scenario_loader"]

@pytest.fixture(scope="session")
def run_meta(request):
    return {"commit_sha": request.config.getoption("--commit-sha"),
            "backend": request.config.getoption("--keeper-backend")}

@pytest.fixture(scope="function")
def cluster_factory(request):
    def _make(topology:int, backend:str, opts:dict):
        import os as _os
        _os.environ.setdefault("KEEPER_PRIVILEGED", "1")
        anchor = __file__  # stable anchor in tests dir
        builder = ClusterBuilder(anchor)
        # Merge environment-provided feature flags / coordination overrides into scenario opts
        try:
            ff_env = os.environ.get("KEEPER_FEATURE_FLAGS", "").strip()
            if ff_env:
                flags = {}
                for part in ff_env.split(","):
                    if not part.strip():
                        continue
                    if "=" in part:
                        k, v = part.split("=", 1)
                    else:
                        k, v = part, "1"
                    k = k.strip(); v = v.strip().lower()
                    if v in ("1","true","yes","on"): flags[k] = 1
                    elif v in ("0","false","no","off"): flags[k] = 0
                    else:
                        try:
                            flags[k] = 1 if int(v) != 0 else 0
                        except Exception:
                            flags[k] = 1
                base_opts = dict(opts or {})
                cur_ff = dict((base_opts.get("feature_flags") or {}))
                cur_ff.update(flags)
                base_opts["feature_flags"] = cur_ff
                opts = base_opts
        except Exception:
            pass
        try:
            coord_xml = os.environ.get("KEEPER_COORD_OVERRIDES_XML", "")
            if coord_xml:
                base_opts = dict(opts or {})
                base_opts["coord_overrides_xml"] = coord_xml
                opts = base_opts
        except Exception:
            pass
        cluster, nodes = builder.build(topology=topology, backend=backend, opts=opts)
        to = 120.0
        try:
            to = float(os.environ.get("KEEPER_READY_TIMEOUT", "120"))
        except Exception:
            to = 120.0
        wait_until(lambda: count_leaders(nodes) == 1, timeout_s=to, interval=0.5, desc="cluster ready")
        return cluster, nodes
    return _make

def pytest_collection_modifyitems(config, items):
    run_weekly = parse_bool(os.environ.get("KEEPER_RUN_WEEKLY"))
    if run_weekly:
        return
    deselect = []
    keep = []
    for item in items:
        if any(m.name == "weekly" for m in item.iter_markers()):
            deselect.append(item)
        else:
            keep.append(item)
    if deselect:
        try:
            config.hook.pytest_deselected(items=deselect)
        except Exception:
            pass
        items[:] = keep

# Fallback 'scenario' fixture in case plugin isn't active (shouldn't happen but makes test self-reliant)
@pytest.fixture(scope="function")
def scenario(request):
    if hasattr(request, "param"):
        return request.param
    import yaml
    base = pathlib.Path(__file__).parents[1]
    target = os.environ.get("KEEPER_SCENARIO_FILE", "all")
    files = []
    if str(target).strip().lower() in ("all", "auto", "*"):
        files = sorted((base / "scenarios").glob("*.yaml"))
    elif "," in str(target):
        files = [base / "scenarios" / p.strip() for p in str(target).split(",") if p.strip()]
    else:
        files = [base / "scenarios" / str(target)]
    extra = os.environ.get("KEEPER_EXTRA_SCENARIOS", "")
    for p in [x.strip() for x in extra.split(",") if x.strip()]:
        files.append(pathlib.Path(p))
    scns = []
    for path in files:
        if path.exists():
            data = yaml.safe_load(path.read_text()) or {}
            if isinstance(data, dict) and isinstance(data.get("scenarios"), list):
                scns.extend(data.get("scenarios") or [])
    include = set([x for x in (os.environ.get("KEEPER_INCLUDE_IDS", "") or "").split(",") if x])
    pick = None
    for s in scns:
        if include and s.get("id") not in include:
            continue
        pick = s
        break
    if pick is None:
        pick = scns[0] if scns else {}
    b = os.environ.get("KEEPER_BACKEND", "default")
    out = dict(pick or {})
    out["backend"] = out.get("backend") or b
    return out

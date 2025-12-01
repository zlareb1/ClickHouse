import time, pathlib, pytest, json, uuid, yaml, copy
import os, shutil
from ..framework import faults as F
from ..framework.faults import apply_step as apply_step_dispatcher
from ..framework.workloads import KeeperBench, servers_arg
from ..framework.probes import is_leader, count_leaders, four, mntr, wchs_total, lgif, srvr, prom_metrics, ch_metrics, ch_async_metrics, ch_trace_log
from ..framework.prom_parse import parse_prometheus_text
from ..framework.gates import single_leader, backlog_drains, error_rate_le, p99_le, watch_delta_within, no_watcher_hotspot, ephemerals_gone_within, ready_expect, lgif_monotone, apply_gate
from ..framework.sink import sink_clickhouse
from ..framework.monitors import MetricsSampler
from ..framework.preflight import ensure_environment
from ..framework.fuzz import generate_fuzz_scenario
from ..framework.registry import fault_registry
from ..framework.fuzz import _EXCLUDE as _FUZZ_EXCLUDE

WORKDIR = pathlib.Path(__file__).parents[2]

def _apply_step(step, nodes, leader, ctx):
    apply_step_dispatcher(step, nodes, leader, ctx)

def _apply_gate(gate, nodes, leader, ctx, summary):
    apply_gate(gate, nodes, leader, ctx, summary)

def _snapshot_and_sink(nodes, stage, scenario_id, topo, run_meta, sink_url, run_id=""):
    if not sink_url:
        return
    fourlw_rows=[]; prom_rows=[]; chm_rows=[]; cham_rows=[]; tr_rows=[]; prom_parsed_rows=[]
    # For fail stage, only snapshot leader to reduce volume
    snap_nodes = nodes
    if stage == "fail":
        try:
            from ..framework.probes import is_leader
            leaders = [n for n in nodes if is_leader(n)]
            if leaders:
                snap_nodes = leaders[:1]
        except Exception:
            snap_nodes = nodes[:1]
    for n in snap_nodes:
        try:
            m=mntr(n); l=lgif(n); s=srvr(n)
            fourlw_rows.append({
                "run_id": run_id,
                "commit_sha": run_meta.get("commit_sha","local"),
                "backend": run_meta.get("backend","default"),
                "scenario": scenario_id,
                "topology": topo,
                "node": n.name,
                "stage": stage,
                "mntr_json": json.dumps(m),
                "lgif_json": json.dumps(l),
                "srvr_text": s,
            })
        except Exception:
            pass
        try:
            p=prom_metrics(n)
            prom_rows.append({
                "run_id": run_id,
                "commit_sha": run_meta.get("commit_sha","local"),
                "backend": run_meta.get("backend","default"),
                "scenario": scenario_id,
                "topology": topo,
                "node": n.name,
                "stage": stage,
                "metrics_text": p,
            })
            try:
                for r in parse_prometheus_text(p):
                    prom_parsed_rows.append({
                        "run_id": run_id,
                        "commit_sha": run_meta.get("commit_sha","local"),
                        "backend": run_meta.get("backend","default"),
                        "scenario": scenario_id,
                        "topology": topo,
                        "node": n.name,
                        "stage": stage,
                        "name": r.get("name",""),
                        "value": float(r.get("value", 0.0)),
                        "labels_json": r.get("labels_json", "{}"),
                    })
            except Exception:
                pass
        except Exception:
            pass
        try:
            for r in ch_metrics(n):
                chm_rows.append({
                    "run_id": run_id,
                    "commit_sha": run_meta.get("commit_sha","local"),
                    "backend": run_meta.get("backend","default"),
                    "scenario": scenario_id,
                    "topology": topo,
                    "node": n.name,
                    "stage": stage,
                    "name": r.get("name",""),
                    "value": float(r.get("value",0)),
                })
        except Exception:
            pass
        try:
            for r in ch_async_metrics(n):
                cham_rows.append({
                    "run_id": run_id,
                    "commit_sha": run_meta.get("commit_sha","local"),
                    "backend": run_meta.get("backend","default"),
                    "scenario": scenario_id,
                    "topology": topo,
                    "node": n.name,
                    "stage": stage,
                    "name": r.get("name",""),
                    "value": float(r.get("value",0)),
                })
        except Exception:
            pass
        try:
            tlog=ch_trace_log(n, 200)
            if tlog:
                tr_rows.append({
                    "run_id": run_id,
                    "commit_sha": run_meta.get("commit_sha","local"),
                    "backend": run_meta.get("backend","default"),
                    "scenario": scenario_id,
                    "topology": topo,
                    "node": n.name,
                    "stage": stage,
                    "trace_text": tlog,
                })
        except Exception:
            pass
    if fourlw_rows:
        sink_clickhouse(sink_url, "keeper_fourlw", fourlw_rows)
    if prom_rows:
        sink_clickhouse(sink_url, "keeper_prom", prom_rows)
    if prom_parsed_rows:
        sink_clickhouse(sink_url, "keeper_prom_parsed", prom_parsed_rows)
    if chm_rows:
        sink_clickhouse(sink_url, "keeper_ch_metrics", chm_rows)
    if cham_rows:
        sink_clickhouse(sink_url, "keeper_ch_async_metrics", cham_rows)
    if tr_rows:
        sink_clickhouse(sink_url, "keeper_trace_log", tr_rows)

@pytest.mark.timeout(2400)
def test_scenario(scenario, cluster_factory, request, run_meta):
    start_ts = time.time()
    topo=scenario.get("topology",3)
    flags=scenario.get("keeper_flags_xml","")
    backend = scenario.get("backend") or request.config.getoption("--keeper-backend")
    # Effective run_meta per test with the scenario-selected backend
    run_meta_eff = dict(run_meta or {})
    try:
        run_meta_eff["backend"] = backend
    except Exception:
        pass
    opts=scenario.get("opts", {})
    try:
        faults_mode = request.config.getoption("--faults")
    except Exception:
        faults_mode = os.environ.get("KEEPER_FAULTS", "on")
    try:
        rnd_count = int(request.config.getoption("--random-faults-count") or 1)
    except Exception:
        rnd_count = int(os.environ.get("KEEPER_RANDOM_FAULTS_COUNT", "1"))
    try:
        seed_val = int(request.config.getoption("--seed") or 0)
    except Exception:
        seed_val = 0
    fs_original = scenario.get("faults", []) or []
    fs_effective = fs_original
    if faults_mode == "off":
        fs_effective = []
    elif faults_mode == "random":
        try:
            dur_default = int((scenario.get("workload") or {}).get("duration") or request.config.getoption("--duration"))
        except Exception:
            dur_default = int(os.environ.get("KEEPER_DURATION", "120"))
        if seed_val <= 0:
            import os as _os
            seed_val = int.from_bytes(_os.urandom(4), 'big')
        try:
            try:
                inc_raw = request.config.getoption("--random-faults-include") or os.environ.get("KEEPER_RANDOM_FAULTS_INCLUDE", "")
            except Exception:
                inc_raw = os.environ.get("KEEPER_RANDOM_FAULTS_INCLUDE", "")
            try:
                exc_raw = request.config.getoption("--random-faults-exclude") or os.environ.get("KEEPER_RANDOM_FAULTS_EXCLUDE", "")
            except Exception:
                exc_raw = os.environ.get("KEEPER_RANDOM_FAULTS_EXCLUDE", "")
            inc = set([x.strip() for x in (inc_raw or "").split(",") if x.strip()])
            exc = set([x.strip() for x in (exc_raw or "").split(",") if x.strip()])
            cands = [k for k in list(getattr(fault_registry, 'keys', lambda: [])()) if k not in _FUZZ_EXCLUDE]
            if not cands and isinstance(fault_registry, dict):
                cands = [k for k in fault_registry.keys() if k not in _FUZZ_EXCLUDE]
            weights = {}
            if inc:
                for k in cands:
                    weights[k] = 1 if k in inc else 0
            else:
                for k in cands:
                    weights[k] = 0 if k in exc else 1
            fz = generate_fuzz_scenario(seed_val, max(1, rnd_count), dur_default, weights=weights)
            rnd_faults = fz.get("faults", []) or []
            rb = {"kind": "run_bench", "duration_s": dur_default}
            fs_effective = [{"kind": "parallel", "steps": [rb] + rnd_faults}]
        except Exception:
            fs_effective = fs_original
    try:
        uses_dm = any((f.get("kind") in ("dm_delay","dm_error")) for f in fs_effective)
        if uses_dm:
            os.environ.setdefault("KEEPER_PRIVILEGED", "1")
            os.environ.setdefault("KEEPER_HOST_AUTO_PROVISION", "1")
        # Relax log gate for known transient errors during chaos if not provided by env
        os.environ.setdefault(
            "KEEPER_LOG_ALLOW",
            "failed to read rpc header.*End of file|DNS error|Not found address of host|Net Exception: Socket is not connected|CANNOT_READ_ALL_DATA|Cannot read all data|Unknown table.*system\\.trace_log|Unknown table expression identifier 'system\\.trace_log'"
        )
    except Exception:
        pass
    # compute run_id early for reproducible artifact paths
    run_id=f"{scenario.get('id','')}-{run_meta.get('commit_sha','local')}-{uuid.uuid4().hex[:8]}"
    # Use a unique cluster name per test to avoid instance-dir collisions
    try:
        cname = run_id.replace('/', '_').replace(' ', '_')
        os.environ["KEEPER_CLUSTER_NAME"] = cname
    except Exception:
        pass
    cluster, nodes = cluster_factory(topo, backend, opts)
    summary={}; ctx={}
    try:
        try:
            scenario_for_env = copy.deepcopy(scenario)
            scenario_for_env["faults"] = fs_effective
        except Exception:
            scenario_for_env = scenario
        ensure_environment(nodes, scenario_for_env)
        single_leader(nodes)
        leader=[n for n in nodes if is_leader(n)][0]
        sink_url=request.config.getoption("--sink-url")
        _snapshot_and_sink(nodes, "pre", scenario.get("id",""), topo, run_meta_eff, sink_url, run_id)
        ctx["cluster"] = cluster
        try:
            ctx["faults_mode"] = request.config.getoption("--faults")
        except Exception:
            ctx["faults_mode"] = ctx.get("faults_mode", "on")
        try:
            ctx["log_allow"] = request.config.getoption("--log-allow") or ""
        except Exception:
            ctx["log_allow"] = ctx.get("log_allow", "")
        # propagate seed if provided
        try:
            ctx["seed"] = int(request.config.getoption("--seed") or 0)
        except Exception:
            ctx["seed"] = 0
        sampler=None
        if sink_url:
            interval=int(opts.get("monitor_interval_s", 5)) if isinstance(opts, dict) else 5
            prom_allow = opts.get("prom_allow_prefixes") if isinstance(opts, dict) else None
            sampler=MetricsSampler(nodes, run_meta_eff, scenario.get("id",""), topo, sink_url=sink_url, interval_s=interval, stage_prefix="run", run_id=run_id, prom_allow_prefixes=prom_allow, ctx=ctx)
            sampler.start()
        for step in scenario.get("pre", []): _apply_step(step, nodes, leader, ctx)
        kb=None
        if faults_mode != "random" and "workload" in scenario:
            wl=scenario["workload"]
            secure = False
            kb=KeeperBench(
                nodes[0],
                servers_arg(nodes),
                cfg_path=str(WORKDIR/wl["config"]) if wl.get("config") else None,
                duration_s=wl.get("duration", request.config.getoption("--duration")),
                replay_path=wl.get("replay"),
                secure=secure,
            )
            ctx["workload"]=wl; ctx["bench_node"]=nodes[0]; ctx["bench_secure"]=secure; ctx["bench_servers"]=servers_arg(nodes)
        for action in fs_effective: _apply_step(action, nodes, leader, ctx)
        if kb:
            summary = kb.run()
        elif ctx.get("bench_summary"):
            summary = ctx.get("bench_summary") or {}
        for gate in scenario.get("gates", []): _apply_gate(gate, nodes, leader, ctx, summary)
        if sink_url:
            run_row={
                "run_id": run_id,
                "commit_sha": run_meta_eff.get("commit_sha","local"),
                "backend": backend,
                "scenario": scenario.get("id",""),
                "topology": topo,
                "summary_json": json.dumps(summary),
            }
            sink_clickhouse(sink_url, "keeper_bench_runs", [run_row])
        _snapshot_and_sink(nodes, "post", scenario.get("id",""), topo, run_meta_eff, sink_url, run_id)
        try:
            from ci.praktika.cidb import CIDB
            from ci.praktika.settings import Settings
            from ci.praktika.info import Info
            info = Info()
            try:
                url_secret = info.get_secret(Settings.SECRET_CI_DB_URL)
                user_secret = info.get_secret(Settings.SECRET_CI_DB_USER)
                passwd_secret = info.get_secret(Settings.SECRET_CI_DB_PASSWORD)
            except Exception:
                url_secret = user_secret = passwd_secret = None
            url_w = user_w = pwd_w = None
            if url_secret and user_secret and passwd_secret:
                url_w, user_w, pwd_w = url_secret.join_with(user_secret).join_with(passwd_secret).get_value()
            else:
                try:
                    url_w = os.environ.get("KEEPER_CIDB_URL", "").strip()
                    user_w = os.environ.get("KEEPER_CIDB_USER", "").strip()
                    pwd_w = os.environ.get("KEEPER_CIDB_PASSWORD", "").strip()
                except Exception:
                    url_w = user_w = pwd_w = None
            if url_w and user_w and pwd_w:
                if not Settings.CI_DB_TABLE_NAME:
                    Settings.CI_DB_TABLE_NAME = "checks"
                job_name = os.environ.get("JOB_NAME", "keeper-stress").strip() or "keeper-stress"
                prn = 0
                try:
                    prn = int(os.environ.get("PR_NUMBER", "0") or 0)
                except Exception:
                    prn = 0
                status = "success"
                tdur_ms = int(max(0, (time.time() - start_ts)) * 1000)
                ts_str = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(start_ts))
                row = {
                    "pull_request_number": prn,
                    "commit_sha": run_meta_eff.get("commit_sha", "local"),
                    "commit_url": "",
                    "check_name": job_name,
                    "check_status": status,
                    "check_duration_ms": tdur_ms,
                    "check_start_time": ts_str,
                    "report_url": "",
                    "pull_request_url": "",
                    "base_ref": "",
                    "base_repo": "",
                    "head_ref": "",
                    "head_repo": "",
                    "task_url": "",
                    "instance_type": "",
                    "instance_id": "",
                    "test_name": scenario.get("id", ""),
                    "test_status": "OK",
                    "test_duration_ms": tdur_ms,
                    "test_context_raw": json.dumps(summary),
                }
                CIDB(url=url_w, user=user_w, passwd=pwd_w).insert_rows([json.dumps(row)])
        except Exception:
            pass
    except Exception:
        # Emit minimal reproducible scenario to a file for debugging
        try:
            repro_path = f"/tmp/keeper_repro_{run_id}.yaml"
            with open(repro_path, "w", encoding="utf-8") as f:
                yaml.safe_dump(scenario, f, sort_keys=False)
            print(f"[keeper] reproducible scenario written: {repro_path}")
        except Exception:
            pass
        # Attempt to snapshot fail state as well
        try:
            sink_url=request.config.getoption("--sink-url")
            _snapshot_and_sink(nodes, "fail", scenario.get("id",""), topo, run_meta_eff, sink_url, run_id)
        except Exception:
            pass
        try:
            from ci.praktika.cidb import CIDB
            from ci.praktika.settings import Settings
            from ci.praktika.info import Info
            info = Info()
            url_secret = info.get_secret(Settings.SECRET_CI_DB_URL)
            user_secret = info.get_secret(Settings.SECRET_CI_DB_USER)
            passwd_secret = info.get_secret(Settings.SECRET_CI_DB_PASSWORD)
            url_w = user_w = pwd_w = None
            if url_secret and user_secret and passwd_secret:
                url_w, user_w, pwd_w = url_secret.join_with(user_secret).join_with(passwd_secret).get_value()
            else:
                try:
                    url_w = os.environ.get("KEEPER_CIDB_URL", "").strip()
                    user_w = os.environ.get("KEEPER_CIDB_USER", "").strip()
                    pwd_w = os.environ.get("KEEPER_CIDB_PASSWORD", "").strip()
                except Exception:
                    url_w = user_w = pwd_w = None
            if url_w and user_w and pwd_w:
                if not Settings.CI_DB_TABLE_NAME:
                    Settings.CI_DB_TABLE_NAME = "checks"
                job_name = os.environ.get("JOB_NAME", "keeper-stress").strip() or "keeper-stress"
                prn = 0
                try:
                    prn = int(os.environ.get("PR_NUMBER", "0") or 0)
                except Exception:
                    prn = 0
                status = "error"
                tdur_ms = int(max(0, (time.time() - start_ts)) * 1000)
                ts_str = time.strftime("%Y-%m-%d %H:%M:%S", time.gmtime(start_ts))
                row = {
                    "pull_request_number": prn,
                    "commit_sha": run_meta_eff.get("commit_sha", "local"),
                    "commit_url": "",
                    "check_name": job_name,
                    "check_status": status,
                    "check_duration_ms": tdur_ms,
                    "check_start_time": ts_str,
                    "report_url": "",
                    "pull_request_url": "",
                    "base_ref": "",
                    "base_repo": "",
                    "head_ref": "",
                    "head_repo": "",
                    "task_url": "",
                    "instance_type": "",
                    "instance_id": "",
                    "test_name": scenario.get("id", ""),
                    "test_status": "ERROR",
                    "test_duration_ms": tdur_ms,
                    "test_context_raw": getattr(request.node, "longreprtext", ""),
                }
                CIDB(url=url_w, user=user_w, passwd=pwd_w).insert_rows([json.dumps(row)])
        except Exception:
            pass
        try:
            setattr(request.node, "keeper_failed", True)
        except Exception:
            pass
        raise
    finally:
        try:
            if 'sampler' in locals() and sampler:
                sampler.stop(); sampler.flush()
        except Exception:
            pass
        # Close any pooled KeeperClient resources
        try:
            if ctx.get("_kc_pool"):
                ctx["_kc_pool"].close()
        except Exception:
            pass
        try:
            clients = ctx.get("_kc_clients") or {}
            for c in clients.values():
                try:
                    c.stop()
                except Exception:
                    pass
        except Exception:
            pass
        # Keep containers on fail (for debugging) if requested
        try:
            keep = bool(request.config.getoption("--keep-containers-on-fail"))
            failed = getattr(request.node, "keeper_failed", False)
            if keep and failed:
                return
        except Exception:
            pass
        cluster.shutdown()
        # Optional cleanup of generated artifacts if run succeeded
        try:
            failed = getattr(request.node, "keeper_failed", False)
            clean = os.environ.get("KEEPER_CLEAN_ARTIFACTS", "").strip().lower() in ("1","true","yes","on")
            if clean and not failed:
                try:
                    inst_dir = pathlib.Path(getattr(cluster, "instances_dir", ""))
                    if inst_dir and inst_dir.exists():
                        shutil.rmtree(inst_dir, ignore_errors=True)
                except Exception:
                    pass
                try:
                    base_dir = pathlib.Path(getattr(cluster, "base_dir", ""))
                    conf_dir = base_dir / "configs"
                    if conf_dir.exists():
                        shutil.rmtree(conf_dir, ignore_errors=True)
                except Exception:
                    pass
        except Exception:
            pass

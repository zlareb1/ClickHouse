import os, pathlib, shutil
from helpers.cluster import ClickHouseCluster
from .settings import (
    RAFT_PORT,
    CLIENT_PORT,
    CONTROL_PORT,
    PROM_PORT,
    ID_BASE,
    S3_LOG_ENDPOINT,
    S3_SNAPSHOT_ENDPOINT,
    S3_REGION,
    MINIO_ENDPOINT,
    MINIO_ACCESS_KEY,
    MINIO_SECRET_KEY,
)

class ClusterBuilder:
    def __init__(self, file_anchor: str):
        self.file_anchor = file_anchor

    def _render_embedded_xml(self, names, sid, start_sid=ID_BASE):
        peers = "\n".join(
            [f"        <server><id>{i}</id><hostname>{n}</hostname><port>{RAFT_PORT}</port></server>" for i, n in enumerate(names, start=start_sid)]
        )
        http_ctrl = (
            f"<http_control><port>{CONTROL_PORT}</port><readiness><endpoint>/ready</endpoint></readiness></http_control>"
            if CONTROL_PORT
            else ""
        )
        return f"""<clickhouse>
  <keeper_server>
    <tcp_port>{CLIENT_PORT}</tcp_port>
    <server_id>{sid}</server_id>
    <log_storage_path>/var/lib/clickhouse/coordination/log</log_storage_path>
    <snapshot_storage_path>/var/lib/clickhouse/coordination/snapshots</snapshot_storage_path>
    {http_ctrl}
    <coordination_settings>
      <operation_timeout_ms>10000</operation_timeout_ms>
      <session_timeout_ms>30000</session_timeout_ms>
      <heart_beat_interval_ms>500</heart_beat_interval_ms>
      <election_timeout_lower_bound_ms>1000</election_timeout_lower_bound_ms>
      <election_timeout_upper_bound_ms>2000</election_timeout_upper_bound_ms>
      <force_sync>true</force_sync>
      <quorum_reads>false</quorum_reads>
      <shutdown_timeout>5000</shutdown_timeout>
      <startup_timeout>30000</startup_timeout>
    </coordination_settings>
    <raft_configuration>
{peers}
    </raft_configuration>
  </keeper_server>
</clickhouse>"""

    def build(self, topology:int, backend:str, opts:dict):
        feature_flags = opts.get("feature_flags", {})
        coord_overrides_xml = opts.get("coord_overrides_xml", "")
        use_minio = bool(MINIO_ENDPOINT)
        # Allow explicit override via env: KEEPER_DISABLE_S3=1 to force local disks
        # or KEEPER_USE_S3=1 to force S3 if endpoints/minio are configured
        if os.environ.get("KEEPER_DISABLE_S3", "").strip().lower() in ("1","true","yes","on"):
            use_minio = False
        if os.environ.get("KEEPER_USE_S3", "").strip().lower() in ("1","true","yes","on"):
            use_minio = True

        cluster = ClickHouseCluster(self.file_anchor, name=os.environ.get("KEEPER_CLUSTER_NAME", "keeper"))
        base_dir = pathlib.Path(cluster.base_dir)
        # Use a unique configs subdir per cluster name to avoid xdist collisions
        cname = os.environ.get("KEEPER_CLUSTER_NAME", "keeper").strip() or "keeper"
        conf_dir = base_dir / "configs" / cname
        try:
            if conf_dir.exists():
                shutil.rmtree(conf_dir, ignore_errors=True)
        except Exception:
            pass
        conf_dir.mkdir(parents=True, exist_ok=True)

        # Precompute names and server ids
        names = [f"keeper{i}" for i in range(1, topology + 1)]

        # Shared configs
        # keeper_flags.xml
        flags = "<keeper_server>"
        if backend == "rocksdb":
            flags += "<coordination_settings><experimental_use_rocksdb>1</experimental_use_rocksdb></coordination_settings>"
        flags += "<digest_enabled>true</digest_enabled>"
        ff = {"check_not_exists": 1, "create_if_not_exists": 1, "remove_recursive": 1}
        ff.update(feature_flags or {})
        flags += "<feature_flags>" + "".join(f"<{k}>{1 if v else 0}</{k}>" for k, v in ff.items()) + "</feature_flags>"
        flags += (
            "<coordination_settings>"
            "<async_replication>1</async_replication>"
            "<compress_logs>false</compress_logs>"
            "<max_log_file_size>209715200</max_log_file_size>"
            "<max_requests_append_size>300</max_requests_append_size>"
            "<max_requests_batch_bytes_size>307200</max_requests_batch_bytes_size>"
            "<max_requests_batch_size>300</max_requests_batch_size>"
            "<raft_limits_reconnect_limit>10</raft_limits_reconnect_limit>"
            "<raft_logs_level>trace</raft_logs_level>"
            "<reserved_log_items>500000</reserved_log_items>"
            "</coordination_settings>"
        )
        if coord_overrides_xml:
            flags += coord_overrides_xml
        use_s3 = bool(use_minio or S3_LOG_ENDPOINT or S3_SNAPSHOT_ENDPOINT)
        if use_s3:
            flags += (
                "<latest_log_storage_disk>local_log_disk</latest_log_storage_disk>"
                "<latest_snapshot_storage_disk>local_snapshot_disk</latest_snapshot_storage_disk>"
                "<old_log_storage_disk>local_log_disk</old_log_storage_disk>"
                "<old_snapshot_storage_disk>local_snapshot_disk</old_snapshot_storage_disk>"
                "<log_storage_disk>s3_keeper_log_disk</log_storage_disk>"
                "<snapshot_storage_disk>s3_keeper_snapshot_disk</snapshot_storage_disk>"
                "<storage_path>/var/lib/clickhouse/coordination</storage_path>"
            )
        else:
            flags += (
                "<latest_log_storage_disk>local_log_disk</latest_log_storage_disk>"
                "<latest_snapshot_storage_disk>local_snapshot_disk</latest_snapshot_storage_disk>"
                "<old_log_storage_disk>local_log_disk</old_log_storage_disk>"
                "<old_snapshot_storage_disk>local_snapshot_disk</old_snapshot_storage_disk>"
                "<log_storage_disk>local_log_disk</log_storage_disk>"
                "<snapshot_storage_disk>local_snapshot_disk</snapshot_storage_disk>"
                "<storage_path>/var/lib/clickhouse/coordination</storage_path>"
            )
        flags += "</keeper_server>"
        (conf_dir / "keeper_flags.xml").write_text(f"<clickhouse>{flags}</clickhouse>")

        # prometheus.xml
        (conf_dir / "prometheus.xml").write_text(
            f"<clickhouse><prometheus><endpoint>/metrics</endpoint><port>{PROM_PORT}</port><metrics>true</metrics><events>true</events><asynchronous_metrics>true</asynchronous_metrics></prometheus></clickhouse>"
        )

        # zookeeper.xml
        zk_nodes = "".join(f"<node><host>{h}</host><port>{CLIENT_PORT}</port></node>" for h in names)
        (conf_dir / "zookeeper.xml").write_text(f"<clickhouse><zookeeper>{zk_nodes}</zookeeper></clickhouse>")

        # keeper_disks.xml: always define local disks, optionally S3 disks
        disks_xml = [
            "<local_log_disk><type>local</type><path>/var/lib/clickhouse/coordination/log/</path></local_log_disk>",
            "<local_snapshot_disk><type>local</type><path>/var/lib/clickhouse/coordination/snapshots/</path></local_snapshot_disk>",
        ]
        if use_s3:
            ep = (MINIO_ENDPOINT or "").rstrip("/") if use_minio else None
            ak = MINIO_ACCESS_KEY
            sk = MINIO_SECRET_KEY
            s3_log = S3_LOG_ENDPOINT
            s3_snap = S3_SNAPSHOT_ENDPOINT
            s3_region = S3_REGION
            if s3_log or s3_snap:
                region_tag = (lambda r: f"<region>{r}</region>" if r else "")(s3_region)
                disks_xml += [
                    f"<s3_keeper_log_disk><type>s3_plain</type><endpoint>{s3_log or ''}</endpoint>{region_tag}<use_environment_credentials>true</use_environment_credentials></s3_keeper_log_disk>",
                    f"<s3_keeper_snapshot_disk><type>s3_plain</type><endpoint>{s3_snap or ''}</endpoint>{region_tag}<use_environment_credentials>true</use_environment_credentials></s3_keeper_snapshot_disk>",
                ]
            else:
                disks_xml += [
                    f"<s3_keeper_log_disk><type>s3_plain</type><endpoint>{ep}/logs/</endpoint><access_key_id>{ak}</access_key_id><secret_access_key>{sk}</secret_access_key></s3_keeper_log_disk>",
                    f"<s3_keeper_snapshot_disk><type>s3_plain</type><endpoint>{ep}/snapshots/</endpoint><access_key_id>{ak}</access_key_id><secret_access_key>{sk}</secret_access_key></s3_keeper_snapshot_disk>",
                ]
        (conf_dir / "keeper_disks.xml").write_text(
            "<clickhouse><storage_configuration><disks>" + "\n".join(disks_xml) + "</disks></storage_configuration></clickhouse>"
        )

        # Per-instance configs and add instances
        nodes = []
        # Use 1-based server ids by default for raft members
        start_sid = 1 if ID_BASE <= 0 else ID_BASE
        for i, name in enumerate(names, start=start_sid):
            # keeper_embedded for this node
            (conf_dir / f"keeper_embedded_{name}.xml").write_text(
                self._render_embedded_xml(names, i, start_sid=start_sid)
            )
            # macros for this node
            (conf_dir / f"macros_{name}.xml").write_text(
                f"<clickhouse><macros><replica>{name}</replica><shard>1</shard></macros></clickhouse>"
            )
            # Reference files under configs/<cname>/... to avoid collisions across workers
            cfgs = [
                f"configs/{cname}/keeper_embedded_{name}.xml",
                f"configs/{cname}/keeper_flags.xml",
                f"configs/{cname}/prometheus.xml",
                f"configs/{cname}/zookeeper.xml",
                f"configs/{cname}/macros_{name}.xml",
            ]
            # Always include disks config so disk names are known
            cfgs.append(f"configs/{cname}/keeper_disks.xml")
            inst = cluster.add_instance(name, main_configs=cfgs, with_zookeeper=False, stay_alive=True)
            nodes.append(inst)

        # Ensure a clean instances dir to avoid create_dir collisions
        inst_dir = pathlib.Path(cluster.instances_dir)
        if inst_dir.exists():
            try:
                shutil.rmtree(inst_dir, ignore_errors=True)
            except Exception:
                pass

        cluster.start()
        return cluster, nodes

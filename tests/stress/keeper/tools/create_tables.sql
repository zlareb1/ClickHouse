CREATE DATABASE IF NOT EXISTS keeper_metrics;
USE keeper_metrics;

CREATE TABLE IF NOT EXISTS keeper_bench_runs
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  summary_json String
) ENGINE = MergeTree ORDER BY (run_id, scenario) TTL ts + INTERVAL 30 DAY DELETE;

CREATE TABLE IF NOT EXISTS keeper_fourlw
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  node String,
  stage String,
  mntr_json String,
  lgif_json String,
  srvr_text String
) ENGINE = MergeTree ORDER BY (run_id, node, stage, scenario) TTL ts + INTERVAL 30 DAY DELETE;

CREATE TABLE IF NOT EXISTS keeper_prom
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  node String,
  stage String,
  metrics_text String
) ENGINE = MergeTree ORDER BY (run_id, node, stage, scenario) TTL ts + INTERVAL 30 DAY DELETE;

CREATE TABLE IF NOT EXISTS keeper_ch_metrics
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  node String,
  stage String,
  name String,
  value Float64
) ENGINE = MergeTree ORDER BY (run_id, node, stage, scenario, name) TTL ts + INTERVAL 30 DAY DELETE;

CREATE TABLE IF NOT EXISTS keeper_ch_async_metrics
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  node String,
  stage String,
  name String,
  value Float64
) ENGINE = MergeTree ORDER BY (run_id, node, stage, scenario, name) TTL ts + INTERVAL 30 DAY DELETE;

CREATE TABLE IF NOT EXISTS keeper_trace_log
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  node String,
  stage String,
  trace_text String
) ENGINE = MergeTree ORDER BY (run_id, node, stage, scenario) TTL ts + INTERVAL 30 DAY DELETE;

CREATE TABLE IF NOT EXISTS keeper_prom_parsed
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  node String,
  stage String,
  name String,
  value Float64,
  labels_json String
) ENGINE = MergeTree ORDER BY (run_id, node, stage, scenario, name) TTL ts + INTERVAL 30 DAY DELETE;

-- Unified timeseries for Grafana-friendly queries
CREATE TABLE IF NOT EXISTS keeper_metrics_ts
(
  ts DateTime DEFAULT now(),
  run_id String,
  commit_sha String,
  backend String,
  scenario String,
  topology Int32,
  node String,
  stage String,
  source LowCardinality(String),
  name LowCardinality(String),
  value Float64,
  labels_json String DEFAULT '{}'
) ENGINE = MergeTree
ORDER BY (run_id, scenario, node, stage, name, ts)
TTL ts + INTERVAL 30 DAY DELETE;

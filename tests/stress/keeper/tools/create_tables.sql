CREATE DATABASE IF NOT EXISTS keeper_stress_tests;
USE keeper_stress_tests;

-- Unified time series for Keeper metrics (Grafana-friendly)
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

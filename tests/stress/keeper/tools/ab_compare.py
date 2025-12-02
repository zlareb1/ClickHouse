#!/usr/bin/env python3
import argparse, sys, requests, json, os

QUERY = (
    "WITH "
    "A AS (SELECT JSONExtractString(test_context_raw,'scenario') AS scenario, "
    "              JSONExtractString(test_context_raw,'backend') AS backend, "
    "              JSONExtractFloat(test_context_raw,'p95_ms') AS p95_ms, "
    "              JSONExtractFloat(test_context_raw,'p99_ms') AS p99_ms, "
    "              JSONExtractFloat(test_context_raw,'rps') AS rps, "
    "              JSONExtractFloat(test_context_raw,'error_rate') AS error_rate "
    "      FROM default.checks "
    "      WHERE check_name='keeper-stress' AND JSONExtractString(test_context_raw,'run_id') = {run_a:String}), "
    "B AS (SELECT JSONExtractString(test_context_raw,'scenario') AS scenario, "
    "              JSONExtractString(test_context_raw,'backend') AS backend, "
    "              JSONExtractFloat(test_context_raw,'p95_ms') AS p95_ms, "
    "              JSONExtractFloat(test_context_raw,'p99_ms') AS p99_ms, "
    "              JSONExtractFloat(test_context_raw,'rps') AS rps, "
    "              JSONExtractFloat(test_context_raw,'error_rate') AS error_rate "
    "      FROM default.checks "
    "      WHERE check_name='keeper-stress' AND JSONExtractString(test_context_raw,'run_id') = {run_b:String}) "
    "SELECT coalesce(A.scenario,B.scenario) AS scenario, coalesce(A.backend,B.backend) AS backend, "
    "A.p95_ms AS p95_a, B.p95_ms AS p95_b, (B.p95_ms - A.p95_ms) AS delta_p95, "
    "A.p99_ms AS p99_a, B.p99_ms AS p99_b, (B.p99_ms - A.p99_ms) AS delta_p99, "
    "A.rps AS rps_a, B.rps AS rps_b, (B.rps - A.rps) AS delta_rps, "
    "A.error_rate AS err_a, B.error_rate AS err_b, (B.error_rate - A.error_rate) AS delta_err "
    "FROM A FULL OUTER JOIN B USING (scenario, backend) ORDER BY scenario, backend"
)

def main():
    ap = argparse.ArgumentParser(description='Keeper A/B comparison using default.checks test_context_raw')
    ap.add_argument('--sink-url', required=True, help='ClickHouse HTTP URL, e.g. http://host:8123')
    ap.add_argument('--run-a', required=True, help='run_id for A (baseline)')
    ap.add_argument('--run-b', required=True, help='run_id for B (candidate)')
    args = ap.parse_args()

    q = QUERY + " FORMAT JSONEachRow"
    headers = {}
    u = os.environ.get("KEEPER_METRICS_CLICKHOUSE_USER", "").strip()
    p = os.environ.get("KEEPER_METRICS_CLICKHOUSE_PASSWORD", "").strip()
    if u and p:
        headers["X-ClickHouse-User"] = u
        headers["X-ClickHouse-Key"] = p
    r = requests.post(
        args.sink_url,
        params={
            'query': q,
            'param_run_a': args.run_a,
            'param_run_b': args.run_b,
        },
        headers=headers,
        timeout=30,
    )
    r.raise_for_status()
    lines = [json.loads(l) for l in r.text.splitlines() if l.strip()]
    print(json.dumps(lines, indent=2))

if __name__ == '__main__':
    main()

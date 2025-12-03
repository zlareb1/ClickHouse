ATTACH TABLE _ UUID '230e2dbf-5c3e-451b-ba57-a02d9034a571'
(
    `k` UInt32,
    `val` Float64 STATISTICS(TDigest)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS index_granularity = 8192

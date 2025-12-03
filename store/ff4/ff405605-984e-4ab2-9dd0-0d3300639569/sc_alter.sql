ATTACH TABLE _ UUID 'cf325218-11b6-413e-8f74-fe4182213c5c'
(
    `k` UInt32,
    `v` Float64 STATISTICS(TDigest)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

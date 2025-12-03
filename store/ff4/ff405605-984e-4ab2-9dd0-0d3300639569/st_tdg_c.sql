ATTACH TABLE _ UUID 'f22dc311-1e9e-49ce-8cff-4a099a6fbb71'
(
    `k` UInt32,
    `val` Float64 STATISTICS(TDigest)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

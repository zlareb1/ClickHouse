ATTACH TABLE _ UUID 'edd1233b-7fa4-4e59-ae02-fa07f46baba5'
(
    `k` UInt32,
    `v` Nullable(Float64) STATISTICS(TDigest)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 0, index_granularity = 8192

ATTACH TABLE _ UUID 'ee8a3b52-f662-4ab3-aa1e-c59160c5e361'
(
    `id` UInt32,
    `c1` Int64 STATISTICS(TDigest, Uniq),
    `c2` Float64 STATISTICS(TDigest, Uniq),
    `c3` UInt64 STATISTICS(CountMin)
)
ENGINE = MergeTree
ORDER BY id
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

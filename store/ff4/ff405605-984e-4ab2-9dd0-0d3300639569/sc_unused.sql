ATTACH TABLE _ UUID '42f432c8-052d-48f6-bf93-f3187c90742c'
(
    `k` UInt64,
    `val` UInt64 STATISTICS(MinMax)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 0, index_granularity = 8192

ATTACH TABLE _ UUID 'c360548e-e295-467d-8a2a-8c6aa1dba6fc'
(
    `k` UInt32,
    `x` UInt32 STATISTICS(MinMax)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

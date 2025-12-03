ATTACH TABLE _ UUID 'c0e83323-87dc-49a3-bc8a-064418f8e069'
(
    `k` UInt32,
    `x` UInt32 STATISTICS(MinMax)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS index_granularity = 8192

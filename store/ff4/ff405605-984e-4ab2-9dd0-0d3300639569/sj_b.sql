ATTACH TABLE _ UUID '78223608-1003-4f7c-a0e2-cbc2e813a785'
(
    `id` UInt32 STATISTICS(Uniq),
    `t` LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY id
SETTINGS refresh_statistics_interval = 0, index_granularity = 8192

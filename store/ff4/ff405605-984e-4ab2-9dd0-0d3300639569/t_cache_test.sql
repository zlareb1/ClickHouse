ATTACH TABLE _ UUID 'afb9cef4-0d92-4765-87ae-554bdd1fc5f5'
(
    `k` UInt64,
    `v` UInt64
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 5, index_granularity = 8192

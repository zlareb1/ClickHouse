ATTACH TABLE _ UUID '06662b07-1bb2-434c-bc2c-e0df8d6f6398'
(
    `id` UInt32 STATISTICS(Uniq),
    `p` UInt8
)
ENGINE = MergeTree
ORDER BY id
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

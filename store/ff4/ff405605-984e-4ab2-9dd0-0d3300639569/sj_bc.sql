ATTACH TABLE _ UUID 'e66d4f02-8fb0-49e2-a393-d3abcd4649d4'
(
    `id` UInt32 STATISTICS(Uniq),
    `t` String
)
ENGINE = MergeTree
ORDER BY id
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

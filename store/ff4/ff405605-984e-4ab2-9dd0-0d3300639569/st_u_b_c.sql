ATTACH TABLE _ UUID 'cdf12206-fd59-4797-a265-040a272c8c83'
(
    `id` UInt32 STATISTICS(Uniq),
    `t` String
)
ENGINE = MergeTree
ORDER BY id
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

ATTACH TABLE _ UUID 'a96f9675-6da5-44b3-ad41-8b66b7b1c50d'
(
    `id` UInt32 STATISTICS(Uniq),
    `p` UInt8
)
ENGINE = MergeTree
ORDER BY id
SETTINGS refresh_statistics_interval = 0, index_granularity = 8192

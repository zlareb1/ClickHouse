ATTACH TABLE _ UUID '43175c41-2002-44c1-8ef4-4659f1ad6c54'
(
    `id` UInt32 STATISTICS(Uniq),
    `p` UInt8
)
ENGINE = MergeTree
ORDER BY id
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

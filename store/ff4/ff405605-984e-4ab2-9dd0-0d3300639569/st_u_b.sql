ATTACH TABLE _ UUID 'c413f985-dac5-412c-8215-1c02b93cfd72'
(
    `id` UInt32 STATISTICS(Uniq),
    `t` String
)
ENGINE = MergeTree
ORDER BY id
SETTINGS index_granularity = 8192

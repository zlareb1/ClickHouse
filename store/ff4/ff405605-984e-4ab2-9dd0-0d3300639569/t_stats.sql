ATTACH TABLE _ UUID '5a617966-bd8f-4d8d-91d4-d7f2377655d5'
(
    `id` UInt32,
    `k` UInt32,
    `v` Float64
)
ENGINE = MergeTree
ORDER BY k
SETTINGS auto_statistics_types = 'uniq,countmin,tdigest', index_granularity = 8192

ATTACH TABLE _ UUID 'e6536260-40a2-49e6-83b8-0361f2f2428a'
(
    `p_partkey` UInt32,
    `p_type` LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY p_partkey
SETTINGS refresh_statistics_interval = 5, auto_statistics_types = 'uniq,countmin,tdigest', index_granularity = 8192

ATTACH TABLE _ UUID '1d87e180-850b-4c4c-9fe7-bfdcef35935a'
(
    `p_partkey` UInt32,
    `p_type` LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY p_partkey
SETTINGS refresh_statistics_interval = 0, index_granularity = 8192

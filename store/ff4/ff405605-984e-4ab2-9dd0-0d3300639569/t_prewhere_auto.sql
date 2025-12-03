ATTACH TABLE _ UUID 'd1df1941-b141-4ccd-a8dd-6b5e76be7cc1'
(
    `d` Date,
    `k` UInt32,
    `s` LowCardinality(String)
)
ENGINE = MergeTree
ORDER BY (d, k)
SETTINGS refresh_statistics_interval = 5, auto_statistics_types = 'uniq,countmin,tdigest', index_granularity = 8192

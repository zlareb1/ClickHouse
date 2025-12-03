ATTACH TABLE _ UUID '17760f5e-290e-4850-a9b8-d903a5aa4b54'
(
    `k` UInt32,
    `cat` String STATISTICS(CountMin)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

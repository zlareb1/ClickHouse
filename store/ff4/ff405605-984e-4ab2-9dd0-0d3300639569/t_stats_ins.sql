ATTACH TABLE _ UUID '3ff188f9-0334-4a4c-b0c2-0752b258f1b0'
(
    `d` Date,
    `k` UInt32 STATISTICS(TDigest, Uniq)
)
ENGINE = MergeTree
ORDER BY (d, k)
SETTINGS refresh_statistics_interval = 1, index_granularity = 8192

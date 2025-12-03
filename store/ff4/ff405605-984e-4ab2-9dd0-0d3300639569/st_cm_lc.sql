ATTACH TABLE _ UUID 'a08141c1-9435-494e-a0ab-fa03f2dc3c1f'
(
    `k` UInt32,
    `cat` LowCardinality(String) STATISTICS(CountMin)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 0, index_granularity = 8192

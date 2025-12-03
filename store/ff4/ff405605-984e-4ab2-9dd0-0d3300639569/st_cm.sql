ATTACH TABLE _ UUID 'b681770e-c3f3-4c5d-86c3-c68d29096665'
(
    `k` UInt32,
    `cat` String STATISTICS(CountMin)
)
ENGINE = MergeTree
ORDER BY k
SETTINGS index_granularity = 8192

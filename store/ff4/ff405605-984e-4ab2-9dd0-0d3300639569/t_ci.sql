ATTACH TABLE _ UUID '51418a94-6690-41d2-b7ea-c6e6c25ddba4'
(
    `i` UInt8,
    `d` Dynamic
)
ENGINE = MergeTree
ORDER BY i
SETTINGS index_granularity = 8192

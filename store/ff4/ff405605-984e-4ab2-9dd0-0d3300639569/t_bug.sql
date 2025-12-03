ATTACH TABLE _ UUID 'fef6fca8-a94d-4d1d-b0ee-d3f9e959611a'
(
    `i` UInt8,
    `d` Dynamic
)
ENGINE = MergeTree
ORDER BY i
SETTINGS index_granularity = 8192

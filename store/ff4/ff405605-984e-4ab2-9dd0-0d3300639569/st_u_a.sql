ATTACH TABLE _ UUID 'e9a326a9-ad1a-4462-aa81-ff05fada91b7'
(
    `id` UInt32 STATISTICS(Uniq),
    `p` UInt8
)
ENGINE = MergeTree
ORDER BY id
SETTINGS index_granularity = 8192

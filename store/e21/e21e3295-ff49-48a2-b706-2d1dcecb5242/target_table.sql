ATTACH TABLE _ UUID '331d5153-accb-4cb8-9cbb-dc789e281b92'
(
    `SrcIp` UInt64,
    `SrcPort` UInt16,
    `DestIp` UInt64,
    `DestPort` UInt16,
    `SegmentValue` UInt8
)
ENGINE = MergeTree
ORDER BY (SrcIp, SrcPort)
SETTINGS index_granularity = 8192

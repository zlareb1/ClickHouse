ATTACH TABLE _ UUID 'a4abadcf-986b-47cb-8bff-6b074947cb58'
(
    `SrcIp` UInt64,
    `SrcPort` UInt16,
    `DestIp` UInt64,
    `DestPort` UInt16,
    `SegmentValue` UInt8
)
ENGINE = Buffer('testdb', 'target_table', 16, 10, 100, 10000, 1000000, 1048576, 10485760)

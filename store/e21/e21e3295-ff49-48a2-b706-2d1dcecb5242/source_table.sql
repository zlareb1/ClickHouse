ATTACH TABLE _ UUID '26af909e-e194-48fe-b933-17f920a7ff4d'
(
    `timestamp` UInt32,
    `SrcIp` UInt64,
    `SrcPort` UInt16,
    `DestIp` UInt64,
    `DestPort` UInt16,
    `SegmentValue` UInt8,
    `FlowDirection` UInt8
)
ENGINE = MergeTree
ORDER BY (timestamp, SrcIp, SrcPort)
SETTINGS index_granularity = 8192

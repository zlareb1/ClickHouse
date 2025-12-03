ATTACH TABLE _ UUID '94265170-3a19-40a8-8ac0-d63a81536238'
(
    `l_partkey` UInt32,
    `l_extendedprice` Float64,
    `l_discount` Float64,
    `l_shipdate` Date
)
ENGINE = MergeTree
ORDER BY (l_shipdate, l_partkey)
SETTINGS refresh_statistics_interval = 0, index_granularity = 8192

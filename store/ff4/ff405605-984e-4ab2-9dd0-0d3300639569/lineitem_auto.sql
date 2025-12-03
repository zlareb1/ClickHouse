ATTACH TABLE _ UUID '017680ce-86da-4046-8b6f-2e42098ba310'
(
    `l_partkey` UInt32,
    `l_extendedprice` Float64,
    `l_discount` Float64,
    `l_shipdate` Date
)
ENGINE = MergeTree
ORDER BY (l_shipdate, l_partkey)
SETTINGS refresh_statistics_interval = 5, auto_statistics_types = 'uniq,countmin,tdigest', index_granularity = 8192

ATTACH TABLE _ UUID '901d9f3e-b3bc-433d-a65d-fadfbcf631c6'
(
    `k` UInt32,
    `val` Float64,
    `cat` String,
    `r` UInt32
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 1, auto_statistics_types = 'tdigest,countmin,minmax,uniq', index_granularity = 8192

ATTACH TABLE _ UUID 'df738277-4042-431e-8d77-ae25ce9f07fa'
(
    `k` UInt32,
    `val` Nullable(Float64),
    `cat` LowCardinality(Nullable(String)),
    `r` UInt32
)
ENGINE = MergeTree
ORDER BY k
SETTINGS refresh_statistics_interval = 0, auto_statistics_types = 'tdigest,countmin,minmax,uniq', index_granularity = 8192

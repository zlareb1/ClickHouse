ATTACH TABLE _ UUID 'f2be9f4f-24c2-4f7c-ba4d-1d405458f247'
(
    `hostname` LowCardinality(String),
    `event_date` Date,
    `event_time` DateTime,
    `query_id` String,
    `path` String,
    `offset` UInt64,
    `size` Int64,
    `prefetch_submit_time` DateTime64(6),
    `priority` Int64,
    `prefetch_execution_start_time` DateTime64(6),
    `prefetch_execution_end_time` DateTime64(6),
    `prefetch_execution_time_us` UInt64,
    `state` String,
    `thread_id` UInt64,
    `reader_id` String
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains a history of all prefetches done during reading from MergeTables backed by a remote filesystem.\n\nIt is safe to truncate or drop this table at any time.'

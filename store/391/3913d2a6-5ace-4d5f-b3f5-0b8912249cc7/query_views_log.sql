ATTACH TABLE _ UUID '3dc44b0d-ab38-4bd3-8aad-b0716537737a'
(
    `hostname` LowCardinality(String) COMMENT 'Hostname of the server executing the query.',
    `event_date` Date COMMENT 'The date when the last event of the view happened.',
    `event_time` DateTime COMMENT 'The date and time when the view finished execution.',
    `event_time_microseconds` DateTime64(6) COMMENT 'The date and time when the view finished execution with microseconds precision.',
    `view_duration_ms` UInt64 COMMENT 'Duration of view execution (sum of its stages) in milliseconds.',
    `initial_query_id` String COMMENT 'ID of the initial query (for distributed query execution).',
    `view_name` String COMMENT 'Name of the view.',
    `view_uuid` UUID COMMENT 'UUID of the view.',
    `view_type` Enum8('Default' = 1, 'Materialized' = 2, 'Live' = 3, 'Window' = 4) COMMENT 'Type of the view. Values: \'Default\' = 1 — Default views. Should not appear in this log, \'Materialized\' = 2 — Materialized views, \'Live\' = 3 — Live views.',
    `view_query` String COMMENT 'The query executed by the view.',
    `view_target` String COMMENT 'The name of the view target table.',
    `read_rows` UInt64 COMMENT 'Number of read rows.',
    `read_bytes` UInt64 COMMENT 'Number of read bytes.',
    `written_rows` UInt64 COMMENT 'Number of written rows.',
    `written_bytes` UInt64 COMMENT 'Number of written bytes.',
    `peak_memory_usage` Int64 COMMENT 'The maximum difference between the amount of allocated and freed memory in context of this view.',
    `ProfileEvents` Map(LowCardinality(String), UInt64) COMMENT 'ProfileEvents that measure different metrics. The description of them could be found in the table system.events.',
    `status` Enum8('QueryStart' = 1, 'QueryFinish' = 2, 'ExceptionBeforeStart' = 3, 'ExceptionWhileProcessing' = 4) COMMENT 'Status of the view. Values: \'QueryStart\' = 1 — Successful start the view execution. Should not appear, \'QueryFinish\' = 2 — Successful end of the view execution, \'ExceptionBeforeStart\' = 3 — Exception before the start of the view execution., \'ExceptionWhileProcessing\' = 4 — Exception during the view execution.',
    `exception_code` Int32 COMMENT 'Code of an exception.',
    `exception` String COMMENT 'Exception message.',
    `stack_trace` String COMMENT 'Stack trace. An empty string, if the query was completed successfully.',
    `ProfileEvents.Names` Array(String) ALIAS mapKeys(ProfileEvents),
    `ProfileEvents.Values` Array(UInt64) ALIAS mapValues(ProfileEvents)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains information about the dependent views executed when running a query, for example, the view type or the execution time.\n\nIt is safe to truncate or drop this table at any time.'

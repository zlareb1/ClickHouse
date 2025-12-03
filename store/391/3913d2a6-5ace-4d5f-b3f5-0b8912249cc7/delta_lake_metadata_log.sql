ATTACH TABLE _ UUID '1b9532f4-9f41-4d73-934e-159be46cff6b'
(
    `event_date` Date COMMENT 'Date of the entry.',
    `event_time` DateTime COMMENT 'Event time.',
    `query_id` String COMMENT 'Query id.',
    `table_path` String COMMENT 'Table path.',
    `file_path` String COMMENT 'File path.',
    `content` String COMMENT 'Content in a JSON format.'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains content of Delta metadata files.\n\nIt is safe to truncate or drop this table at any time.'

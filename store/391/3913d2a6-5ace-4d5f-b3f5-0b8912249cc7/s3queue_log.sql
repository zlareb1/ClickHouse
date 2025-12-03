ATTACH TABLE _ UUID 'c9dac45e-15a7-4413-9b2e-5279ce95fd5c'
(
    `hostname` LowCardinality(String) COMMENT 'Hostname',
    `event_date` Date COMMENT 'Event date of writing this log row',
    `event_time` DateTime COMMENT 'Event time of writing this log row',
    `database` String COMMENT 'The name of a database where current S3Queue table lives.',
    `table` String COMMENT 'The name of S3Queue table.',
    `uuid` String COMMENT 'The UUID of S3Queue table',
    `file_name` String COMMENT 'File name of the processing file',
    `rows_processed` UInt64 COMMENT 'Number of processed rows',
    `status` Enum8('Processed' = 0, 'Failed' = 1) COMMENT 'Status of the processing file',
    `processing_start_time` Nullable(DateTime) COMMENT 'Time of the start of processing the file',
    `processing_end_time` Nullable(DateTime) COMMENT 'Time of the end of processing the file',
    `exception` String COMMENT 'Exception message if happened',
    `commit_id` UInt64 COMMENT 'Id of the transaction in which this file was committed',
    `commit_time` DateTime COMMENT 'Time of committing file in keeper (as either failed or processed)',
    `transaction_start_time` DateTime COMMENT 'Time when the whole processing transaction started',
    `get_object_time_ms` UInt64 COMMENT 'Time which took us to find the object in s3'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains logging entries with the information files processes by S3Queue engine.\n\nIt is safe to truncate or drop this table at any time.'

ATTACH TABLE _ UUID 'e4e65ee1-b300-46a4-afb8-3fe15cb14fd7'
(
    `hostname` LowCardinality(String) COMMENT 'Hostname',
    `event_date` Date COMMENT 'Event date',
    `event_time` DateTime COMMENT 'Event time',
    `query_id` String COMMENT 'Id of the query',
    `source_file_path` String COMMENT 'File segment path on filesystem',
    `file_segment_range` Tuple(UInt64, UInt64) COMMENT 'File segment range',
    `total_requested_range` Tuple(UInt64, UInt64) COMMENT 'Full read range',
    `key` String COMMENT 'File segment key',
    `offset` UInt64 COMMENT 'File segment offset',
    `size` UInt64 COMMENT 'Read size',
    `read_type` String COMMENT 'Read type: READ_FROM_CACHE, READ_FROM_FS_AND_DOWNLOADED_TO_CACHE, READ_FROM_FS_BYPASSING_CACHE',
    `read_from_cache_attempted` UInt8 COMMENT 'Whether reading from cache was attempted',
    `ProfileEvents` Map(LowCardinality(String), UInt64) COMMENT 'Profile events collected while reading this file segment',
    `read_buffer_id` String COMMENT 'Internal implementation read buffer id',
    `user_id` String COMMENT 'User id of the user which created the file segment'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains a history of all events occurred with filesystem cache for objects on a remote filesystem.\n\nIt is safe to truncate or drop this table at any time.'

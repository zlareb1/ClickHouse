ATTACH TABLE _ UUID 'b42f073c-00cb-4685-ad14-44fd5babadab'
(
    `hostname` LowCardinality(String) COMMENT 'Hostname of the server executing the query.',
    `event_date` Date COMMENT 'Date of the event.',
    `event_time` DateTime COMMENT 'Time of the event.',
    `event_time_microseconds` DateTime64(6) COMMENT 'Time of the event with microseconds precision.',
    `event_type` Enum8('Upload' = 1, 'Delete' = 2, 'MultiPartUploadCreate' = 3, 'MultiPartUploadWrite' = 4, 'MultiPartUploadComplete' = 5, 'MultiPartUploadAbort' = 6) COMMENT 'Type of the event. Possible values: \'Upload\', \'Delete\', \'MultiPartUploadCreate\', \'MultiPartUploadWrite\', \'MultiPartUploadComplete\', \'MultiPartUploadAbort\'',
    `query_id` String COMMENT 'Identifier of the query associated with the event, if any.',
    `thread_id` UInt64 COMMENT 'Identifier of the thread performing the operation.',
    `thread_name` String COMMENT 'Name of the thread performing the operation.',
    `disk_name` LowCardinality(String) COMMENT 'Name of the associated disk.',
    `bucket` String COMMENT 'Name of the bucket.',
    `remote_path` String COMMENT 'Path to the remote resource.',
    `local_path` String COMMENT 'Path to the metadata file on the local system, which references the remote resource.',
    `data_size` UInt64 COMMENT 'Size of the data involved in the upload event.',
    `error` String COMMENT 'Error message associated with the event, if any.'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
TTL event_date + toIntervalDay(30)
SETTINGS index_granularity = 8192
COMMENT 'Contains logging entries with information about various blob storage operations such as uploads and deletes.\n\nIt is safe to truncate or drop this table at any time.'

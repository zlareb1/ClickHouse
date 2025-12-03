ATTACH TABLE _ UUID '632b6d89-a0b8-4c7c-80c1-25ca28383234'
(
    `hostname` LowCardinality(String) COMMENT 'Hostname of the server executing the query.',
    `event_date` Date COMMENT 'The date when the async insert happened.',
    `event_time` DateTime COMMENT 'The date and time when the async insert finished execution.',
    `event_time_microseconds` DateTime64(6) COMMENT 'The date and time when the async insert finished execution with microseconds precision.',
    `query` String COMMENT 'Query string.',
    `database` LowCardinality(String) COMMENT 'The name of the database the table is in.',
    `table` LowCardinality(String) COMMENT 'Table name.',
    `format` LowCardinality(String) COMMENT 'Format name.',
    `query_id` String COMMENT 'ID of the initial query.',
    `bytes` UInt64 COMMENT 'Number of inserted bytes.',
    `rows` UInt64 COMMENT 'Number of inserted rows.',
    `exception` String COMMENT 'Exception message.',
    `status` Enum8('Ok' = 0, 'ParsingError' = 1, 'FlushError' = 2) COMMENT 'Status of the view. Values: \'Ok\' = 1 — Successful insert, \'ParsingError\' = 2 — Exception when parsing the data, \'FlushError\' = 3 — Exception when flushing the data',
    `data_kind` Enum8('Parsed' = 0, 'Preprocessed' = 1) COMMENT 'The status of the data. Value: \'Parsed\' and \'Preprocessed\'.',
    `flush_time` DateTime COMMENT 'The date and time when the flush happened.',
    `flush_time_microseconds` DateTime64(6) COMMENT 'The date and time when the flush happened with microseconds precision.',
    `flush_query_id` String COMMENT 'ID of the flush query.',
    `timeout_milliseconds` UInt64 COMMENT 'The adaptive timeout calculated for this entry.'
)
ENGINE = MergeTree
PARTITION BY event_date
ORDER BY (database, `table`, event_date, event_time)
TTL event_date + toIntervalDay(3)
SETTINGS index_granularity = 8192
COMMENT 'Contains a history for all asynchronous inserts executed on current server.\n\nIt is safe to truncate or drop this table at any time.'

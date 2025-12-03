ATTACH TABLE _ UUID '8afc3412-2efa-45b0-8a28-c1e619fd2586'
(
    `hostname` LowCardinality(String) COMMENT 'The hostname where transaction was executed.',
    `type` Enum8('Begin' = 1, 'Commit' = 2, 'Rollback' = 3, 'AddPart' = 10, 'LockPart' = 11, 'UnlockPart' = 12) COMMENT 'The type of the transaction. Possible values: Begin, Commit, Rollback, AddPart, LockPart, UnlockPart.',
    `event_date` Date COMMENT 'Date of the entry.',
    `event_time` DateTime64(6) COMMENT 'Time of the entry',
    `thread_id` UInt64 COMMENT 'The identifier of a thread.',
    `query_id` String COMMENT 'The ID of a query executed in a scope of transaction.',
    `tid` Tuple(UInt64, UInt64, UUID) COMMENT 'The identifier of a transaction.',
    `tid_hash` UInt64 COMMENT 'The hash of the identifier.',
    `csn` UInt64 COMMENT 'The Commit Sequence Number',
    `database` String COMMENT 'The name of the database the transaction was executed against.',
    `table` String COMMENT 'The name of the table the transaction was executed against.',
    `uuid` UUID COMMENT 'The uuid of the table the transaction was executed against.',
    `part` String COMMENT 'The name of the part participated in the transaction.'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains information about all transactions executed on a current server.\n\nIt is safe to truncate or drop this table at any time.'

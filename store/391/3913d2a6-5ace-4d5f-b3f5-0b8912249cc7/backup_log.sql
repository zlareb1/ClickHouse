ATTACH TABLE _ UUID 'aab411fc-ca9b-4e34-9bde-5e202c7e631f'
(
    `hostname` LowCardinality(String) COMMENT 'Hostname of the server executing the query.',
    `event_date` Date COMMENT 'Date of the entry.',
    `event_time` DateTime COMMENT 'Time of the entry.',
    `event_time_microseconds` DateTime64(6) COMMENT 'Time of the entry with microseconds precision.',
    `id` String COMMENT 'Identifier of the backup or restore operation.',
    `name` String COMMENT 'Name of the backup storage (the contents of the FROM or TO clause).',
    `base_backup_name` String COMMENT 'The name of base backup in case incremental one.',
    `query_id` String COMMENT 'The ID of a query associated with a backup operation.',
    `status` Enum8('CREATING_BACKUP' = 0, 'BACKUP_CREATED' = 1, 'BACKUP_FAILED' = 2, 'RESTORING' = 3, 'RESTORED' = 4, 'RESTORE_FAILED' = 5, 'BACKUP_CANCELLED' = 6, 'RESTORE_CANCELLED' = 7) COMMENT 'Operation status.',
    `error` String COMMENT 'Error message of the failed operation (empty string for successful operations).',
    `start_time` DateTime64(6) COMMENT 'Start time of the operation.',
    `end_time` DateTime64(6) COMMENT 'End time of the operation.',
    `num_files` UInt64 COMMENT 'Number of files stored in the backup.',
    `total_size` UInt64 COMMENT 'Total size of files stored in the backup.',
    `num_entries` UInt64 COMMENT 'Number of entries in the backup, i.e. the number of files inside the folder if the backup is stored as a folder, or the number of files inside the archive if the backup is stored as an archive. It is not the same as num_files if it\'s an incremental backup or if it contains empty files or duplicates. The following is always true: num_entries <= num_files.',
    `uncompressed_size` UInt64 COMMENT 'Uncompressed size of the backup.',
    `compressed_size` UInt64 COMMENT 'Compressed size of the backup. If the backup is not stored as an archive it equals to uncompressed_size.',
    `files_read` UInt64 COMMENT 'Number of files read during the restore operation.',
    `bytes_read` UInt64 COMMENT 'Total size of files read during the restore operation.'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains logging entries with the information about BACKUP and RESTORE operations.\n\nIt is safe to truncate or drop this table at any time.'

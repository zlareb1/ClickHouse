ATTACH TABLE _ UUID '1874ae78-a346-4768-9049-bc18b3c849cd'
(
    `event_date` Date COMMENT 'Date of the entry.',
    `event_time` DateTime COMMENT 'Event time.',
    `query_id` String COMMENT 'Query id.',
    `content_type` Enum8('None' = 0, 'Metadata' = 1, 'ManifestListMetadata' = 2, 'ManifestListEntry' = 3, 'ManifestFileMetadata' = 4, 'ManifestFileEntry' = 5) COMMENT 'Content type.',
    `table_path` String COMMENT 'Table path.',
    `file_path` String COMMENT 'File path.',
    `content` String COMMENT 'Content in a JSON format (json file content, avro metadata or avro entry).',
    `row_in_file` Nullable(UInt64) COMMENT 'Row in file.',
    `pruning_status` Nullable(Enum8('NotPruned' = 0, 'PartitionPruned' = 1, 'MinMaxIndexPruned' = 2)) COMMENT 'Status of partition pruning or min-max index pruning for the file.'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
SETTINGS index_granularity = 8192
COMMENT 'Contains content of Iceberg metadata files.\n\nIt is safe to truncate or drop this table at any time.'

ATTACH TABLE _ UUID '682a398e-6928-4f20-84b0-276d66fcdb41'
(
    `id` UInt32,
    `d` Dynamic(max_types = 0)
)
ENGINE = MergeTree
ORDER BY id
SETTINGS dynamic_serialization_version = 'v3', object_shared_data_serialization_version = 'advanced', object_shared_data_serialization_version_for_zero_level_parts = 'advanced', index_granularity = 8192

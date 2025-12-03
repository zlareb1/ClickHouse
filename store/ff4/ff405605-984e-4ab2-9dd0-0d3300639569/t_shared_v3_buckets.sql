ATTACH TABLE _ UUID '71924058-a41c-4fb5-955d-9b68a4feab75'
(
    `id` UInt32,
    `d` Dynamic(max_types = 0)
)
ENGINE = MergeTree
ORDER BY id
SETTINGS dynamic_serialization_version = 'v3', object_shared_data_serialization_version = 'map_with_buckets', object_shared_data_serialization_version_for_zero_level_parts = 'map_with_buckets', object_shared_data_buckets_for_compact_part = 16, object_shared_data_buckets_for_wide_part = 4, index_granularity = 8192

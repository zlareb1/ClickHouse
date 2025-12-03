ATTACH TABLE _ UUID '3aa2d36a-b262-4756-b7ab-04bcfa3b00f7'
(
    `id` UInt32,
    `d` Dynamic(max_types = 0)
)
ENGINE = MergeTree
ORDER BY id
SETTINGS dynamic_serialization_version = 'v2', object_shared_data_serialization_version = 'map', object_shared_data_serialization_version_for_zero_level_parts = 'map', index_granularity = 8192

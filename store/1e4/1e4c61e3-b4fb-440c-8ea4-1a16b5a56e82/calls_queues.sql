ATTACH TABLE _ UUID '9db999bc-ab58-4252-95d1-29f286e262fc'
(
    `id` UInt64,
    `call_date` DateTime,
    `status` Nullable(String),
    `status_message` Nullable(String),
    `lock_time` Nullable(DateTime),
    `number_of_locks` UInt32 DEFAULT 0,
    `deleted_at` Nullable(DateTime)
)
ENGINE = MergeTree
ORDER BY (toDate(call_date), id)
SETTINGS enable_block_number_column = 1, enable_block_offset_column = 1, index_granularity = 8192

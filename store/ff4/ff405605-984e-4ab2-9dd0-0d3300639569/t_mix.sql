ATTACH TABLE _ UUID '70b8123d-8edf-4519-9c89-b0b5897ea1a0'
(
    `d` Dynamic
)
ENGINE = MergeTree
ORDER BY tuple()
SETTINGS index_granularity = 8192

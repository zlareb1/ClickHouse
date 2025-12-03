ATTACH TABLE _ UUID '4f4b3de1-8230-4015-b6b7-f2c3e452f519'
(
    `c0` Int32
)
ENGINE = MergeTree
PRIMARY KEY c0
ORDER BY c0
SETTINGS index_granularity = 8192, refresh_statistics_interval = 2

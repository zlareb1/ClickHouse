ATTACH TABLE _ UUID '681714ce-c8e4-484b-ab84-e531e9657f2b'
(
    `hostname` LowCardinality(String) COMMENT 'The hostname where this span was captured.',
    `trace_id` UUID COMMENT 'ID of the trace for executed query.',
    `span_id` UInt64 COMMENT 'ID of the trace span.',
    `parent_span_id` UInt64 COMMENT 'ID of the parent trace span.',
    `operation_name` LowCardinality(String) COMMENT 'The name of the operation.',
    `kind` Enum8('INTERNAL' = 0, 'SERVER' = 1, 'CLIENT' = 2, 'PRODUCER' = 3, 'CONSUMER' = 4) COMMENT 'The SpanKind of the span. INTERNAL — Indicates that the span represents an internal operation within an application. SERVER — Indicates that the span covers server-side handling of a synchronous RPC or other remote request. CLIENT — Indicates that the span describes a request to some remote service. PRODUCER — Indicates that the span describes the initiators of an asynchronous request. This parent span will often end before the corresponding child CONSUMER span, possibly even before the child span starts. CONSUMER - Indicates that the span describes a child of an asynchronous PRODUCER request.',
    `start_time_us` UInt64 COMMENT 'The start time of the trace span (in microseconds).',
    `finish_time_us` UInt64 COMMENT 'The finish time of the trace span (in microseconds).',
    `finish_date` Date COMMENT 'The finish date of the trace span.',
    `attribute` Map(LowCardinality(String), String) COMMENT 'Attribute depending on the trace span. They are filled in according to the recommendations in the OpenTelemetry standard.',
    `attribute.names` Array(LowCardinality(String)) ALIAS mapKeys(attribute),
    `attribute.values` Array(String) ALIAS mapValues(attribute)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(finish_date)
ORDER BY (finish_date, finish_time_us)
SETTINGS index_granularity = 8192
COMMENT 'Contains information about trace spans for executed queries.\n\nIt is safe to truncate or drop this table at any time.'

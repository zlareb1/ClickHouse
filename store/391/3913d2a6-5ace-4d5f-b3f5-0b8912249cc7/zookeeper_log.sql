ATTACH TABLE _ UUID 'c145b691-f51f-45e3-bf8e-bbc3e8cf43d8'
(
    `hostname` LowCardinality(String) COMMENT 'Hostname of the server executing the query.',
    `type` Enum8('Request' = 1, 'Response' = 2, 'Finalize' = 3) COMMENT 'Event type in the ZooKeeper client. Can have one of the following values: Request — The request has been sent, Response — The response was received, Finalize — The connection is lost, no response was received.',
    `event_date` Date COMMENT 'The date when the event happened.',
    `event_time` DateTime64(6) COMMENT 'The date and time when the event happened.',
    `thread_id` UInt64 COMMENT 'The ID of the thread executed this request.',
    `query_id` String COMMENT 'The ID of a query in scope of which this request was executed.',
    `address` IPv6 COMMENT 'IP address of ZooKeeper server that was used to make the request.',
    `port` UInt16 COMMENT 'The port of ZooKeeper server that was used to make the request.',
    `session_id` Int64 COMMENT 'The session ID that the ZooKeeper server sets for each connection.',
    `duration_microseconds` UInt64 COMMENT 'The time taken by ZooKeeper to execute the request.',
    `xid` Int64 COMMENT 'The ID of the request within the session. This is usually a sequential request number. It is the same for the request row and the paired response/finalize row.',
    `has_watch` UInt8 COMMENT 'The request whether the watch has been set.',
    `op_num` Enum16('Close' = -11, 'Error' = -1, 'Watch' = 0, 'Create' = 1, 'Remove' = 2, 'Exists' = 3, 'Get' = 4, 'Set' = 5, 'GetACL' = 6, 'SetACL' = 7, 'SimpleList' = 8, 'Sync' = 9, 'Heartbeat' = 11, 'List' = 12, 'Check' = 13, 'Multi' = 14, 'Reconfig' = 16, 'MultiRead' = 22, 'Auth' = 100, 'FilteredList' = 500, 'CheckNotExists' = 501, 'CreateIfNotExists' = 502, 'RemoveRecursive' = 503, 'CheckStat' = 504, 'SessionID' = 997) COMMENT 'The type of request or response.',
    `path` String COMMENT 'The path to the ZooKeeper node specified in the request, or an empty string if the request not requires specifying a path.',
    `data` String COMMENT 'The data written to the ZooKeeper node (for the SET and CREATE requests — what the request wanted to write, for the response to the GET request — what was read) or an empty string.',
    `is_ephemeral` UInt8 COMMENT 'Is the ZooKeeper node being created as an ephemeral.',
    `is_sequential` UInt8 COMMENT 'Is the ZooKeeper node being created as an sequential.',
    `version` Nullable(Int32) COMMENT 'The version of the ZooKeeper node that the request expects when executing. This is supported for CHECK, SET, REMOVE requests (is relevant -1 if the request does not check the version or NULL for other requests that do not support version checking).',
    `requests_size` UInt32 COMMENT 'The number of requests included in the multi request (this is a special request that consists of several consecutive ordinary requests and executes them atomically). All requests included in multi request will have the same xid.',
    `request_idx` UInt32 COMMENT 'The number of the request included in multi request (for multi request — 0, then in order from 1).',
    `zxid` Int64 COMMENT 'ZooKeeper transaction ID. The serial number issued by the ZooKeeper server in response to a successfully executed request (0 if the request was not executed/returned an error/the client does not know whether the request was executed).',
    `error` Nullable(Enum8('ZNOTREADONLY' = -119, 'ZSESSIONMOVED' = -118, 'ZNOTHING' = -117, 'ZCLOSING' = -116, 'ZAUTHFAILED' = -115, 'ZINVALIDACL' = -114, 'ZINVALIDCALLBACK' = -113, 'ZSESSIONEXPIRED' = -112, 'ZNOTEMPTY' = -111, 'ZNODEEXISTS' = -110, 'ZNOCHILDRENFOREPHEMERALS' = -108, 'ZBADVERSION' = -103, 'ZNOAUTH' = -102, 'ZNONODE' = -101, 'ZAPIERROR' = -100, 'ZINVALIDSTATE' = -9, 'ZBADARGUMENTS' = -8, 'ZOPERATIONTIMEOUT' = -7, 'ZUNIMPLEMENTED' = -6, 'ZMARSHALLINGERROR' = -5, 'ZCONNECTIONLOSS' = -4, 'ZDATAINCONSISTENCY' = -3, 'ZRUNTIMEINCONSISTENCY' = -2, 'ZSYSTEMERROR' = -1, 'ZOK' = 0)) COMMENT 'Error code. Can have many values, here are just some of them: ZOK — The request was executed successfully, ZCONNECTIONLOSS — The connection was lost, ZOPERATIONTIMEOUT — The request execution timeout has expired, ZSESSIONEXPIRED — The session has expired, NULL — The request is completed.',
    `watch_type` Nullable(Enum8('NOTWATCHING' = -2, 'SESSION' = -1, 'CREATED' = 1, 'DELETED' = 2, 'CHANGED' = 3, 'CHILD' = 4)) COMMENT 'The type of the watch event (for responses with op_num = Watch), for the remaining responses: NULL.',
    `watch_state` Nullable(Enum16('AUTH_FAILED' = -113, 'EXPIRED_SESSION' = -112, 'CONNECTING' = 1, 'ASSOCIATING' = 2, 'CONNECTED' = 3, 'READONLY' = 5, 'NOTCONNECTED' = 999)) COMMENT 'The status of the watch event (for responses with op_num = Watch), for the remaining responses: NULL.',
    `path_created` String COMMENT 'The path to the created ZooKeeper node (for responses to the CREATE request), may differ from the path if the node is created as a sequential.',
    `stat_czxid` Int64 COMMENT 'The zxid of the change that caused this ZooKeeper node to be created.',
    `stat_mzxid` Int64 COMMENT 'The zxid of the change that last modified this ZooKeeper node.',
    `stat_pzxid` Int64 COMMENT 'The transaction ID of the change that last modified children of this ZooKeeper node.',
    `stat_version` Int32 COMMENT 'The number of changes to the data of this ZooKeeper node.',
    `stat_cversion` Int32 COMMENT 'The number of changes to the children of this ZooKeeper node.',
    `stat_dataLength` Int32 COMMENT 'The length of the data field of this ZooKeeper node.',
    `stat_numChildren` Int32 COMMENT 'The number of children of this ZooKeeper node.',
    `children` Array(String) COMMENT 'The list of child ZooKeeper nodes (for responses to LIST request).'
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(event_date)
ORDER BY (event_date, event_time)
TTL event_date + toIntervalWeek(1)
SETTINGS index_granularity = 8192
COMMENT 'This table contains information about the parameters of the request to the ZooKeeper server and the response from it.\n\nIt is safe to truncate or drop this table at any time.'

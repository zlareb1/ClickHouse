-- Test: insert_deduplication_token should enable deduplication for INSERT SELECT
-- even when SELECT is not stable (no ORDER BY ALL), since the user is explicitly
-- providing their own idempotency key.

DROP TABLE IF EXISTS t_dedup_token_select;
CREATE TABLE t_dedup_token_select (k UInt64)
ENGINE = ReplicatedMergeTree('/clickhouse/{database}/t_dedup_token_select', 'r1')
ORDER BY k;

-- Without token and non-stable SELECT: deduplication is disabled, so both inserts succeed.
INSERT INTO t_dedup_token_select SELECT number FROM numbers(5);
INSERT INTO t_dedup_token_select SELECT number FROM numbers(5);
SELECT count() FROM t_dedup_token_select; -- 10 (no dedup without token)

TRUNCATE TABLE t_dedup_token_select;

-- With explicit insert_deduplication_token and non-stable SELECT:
-- Deduplication SHOULD be enabled (token overrides SELECT stability check).
INSERT INTO t_dedup_token_select SELECT number FROM numbers(5) SETTINGS insert_deduplication_token = 'my_token';
INSERT INTO t_dedup_token_select SELECT number FROM numbers(5) SETTINGS insert_deduplication_token = 'my_token';
SELECT count() FROM t_dedup_token_select; -- 5 (dedup via user token)

-- Different token = different insert, should NOT be deduplicated.
INSERT INTO t_dedup_token_select SELECT number FROM numbers(5) SETTINGS insert_deduplication_token = 'other_token';
SELECT count() FROM t_dedup_token_select; -- 10

-- Same token, different data: still deduplicated by token.
INSERT INTO t_dedup_token_select SELECT number + 100 FROM numbers(5) SETTINGS insert_deduplication_token = 'my_token';
SELECT count() FROM t_dedup_token_select; -- still 10, second insert with 'my_token' is deduped

-- Explicit disable should still disable even with token.
INSERT INTO t_dedup_token_select SELECT number FROM numbers(3)
SETTINGS insert_deduplication_token = 'tok3', deduplicate_insert_select = 'disable';
INSERT INTO t_dedup_token_select SELECT number FROM numbers(3)
SETTINGS insert_deduplication_token = 'tok3', deduplicate_insert_select = 'disable';
SELECT count() FROM t_dedup_token_select; -- 16 (no dedup when explicitly disabled)

DROP TABLE t_dedup_token_select;

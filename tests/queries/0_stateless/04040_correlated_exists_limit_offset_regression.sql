-- Regression test: Correlated EXISTS with LIMIT/OFFSET where offset>0 or limit=0
-- should return 0 for all rows, but throws NOT_IMPLEMENTED after PR #99005 (gh-88722).
-- LimitStep is preserved in the plan but decorrelateQueryPlan does not handle it.

DROP TABLE IF EXISTS t_outer;
DROP TABLE IF EXISTS t_inner;

CREATE TABLE t_outer (x UInt64) ENGINE = MergeTree() ORDER BY x;
CREATE TABLE t_inner (x UInt64) ENGINE = MergeTree() ORDER BY x;

INSERT INTO t_outer VALUES (1), (2), (3);
INSERT INTO t_inner VALUES (1), (1), (1), (2), (2);

-- offset skips all matching rows, EXISTS should return 0 for all outer rows
SELECT x, EXISTS (SELECT 1 FROM t_inner WHERE t_inner.x = t_outer.x LIMIT 3 OFFSET 10) FROM t_outer ORDER BY x;

-- LIMIT 0 always yields empty set, EXISTS should return 0 for all outer rows
SELECT x, EXISTS (SELECT 1 FROM t_inner WHERE t_inner.x = t_outer.x LIMIT 0) FROM t_outer ORDER BY x;

-- sanity check: offset=0, limit>0 works correctly
SELECT x, EXISTS (SELECT 1 FROM t_inner WHERE t_inner.x = t_outer.x LIMIT 3) FROM t_outer ORDER BY x;

DROP TABLE t_outer;
DROP TABLE t_inner;

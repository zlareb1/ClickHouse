-- Regression test: Correlated EXISTS with LIMIT/OFFSET where offset>0 or limit=0
-- throws NOT_IMPLEMENTED after PR #99005 (gh-88722).
-- optimizePlanForExists preserves LimitStep in these cases, but
-- decorrelateQueryPlan does not handle LimitStep and throws.

DROP TABLE IF EXISTS t_outer;
DROP TABLE IF EXISTS t_inner;

CREATE TABLE t_outer (x UInt64) ENGINE = MergeTree() ORDER BY x;
CREATE TABLE t_inner (x UInt64) ENGINE = MergeTree() ORDER BY x;

INSERT INTO t_outer VALUES (1), (2), (3);
INSERT INTO t_inner VALUES (1), (1), (1), (2), (2);

-- Correlated EXISTS with offset>0: offset skips all matching rows, should return 0.
-- Currently throws NOT_IMPLEMENTED because LimitStep is not removed from the plan.
SELECT x, EXISTS (SELECT 1 FROM t_inner WHERE t_inner.x = t_outer.x LIMIT 3 OFFSET 10) FROM t_outer ORDER BY x; -- { serverError NOT_IMPLEMENTED }

-- Correlated EXISTS with LIMIT 0: always empty, should return 0.
-- Currently throws NOT_IMPLEMENTED for the same reason.
SELECT x, EXISTS (SELECT 1 FROM t_inner WHERE t_inner.x = t_outer.x LIMIT 0) FROM t_outer ORDER BY x; -- { serverError NOT_IMPLEMENTED }

-- Correlated EXISTS with offset=0, limit>0: LimitStep is stripped correctly, works fine.
SELECT x, EXISTS (SELECT 1 FROM t_inner WHERE t_inner.x = t_outer.x LIMIT 3) FROM t_outer ORDER BY x;

DROP TABLE t_outer;
DROP TABLE t_inner;

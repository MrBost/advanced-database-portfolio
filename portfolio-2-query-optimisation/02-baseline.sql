-- One discarded warm-up then five timed executions per query, in this session.
-- Times are server EXPLAIN execution time, not pgAdmin/network elapsed time.
-- Check dependencies before creating benchmark objects.
DO $$
DECLARE q integer; view_name text;
BEGIN
    FOR q IN 1..7 LOOP
        view_name := 'p2_q' || lpad(q::text,2,'0');
        IF to_regclass('pg_temp.' || view_name) IS NULL THEN
            RAISE EXCEPTION 'Missing temporary view %. Execute all CREATE TEMP VIEW statements in 01-queries.sql in this same Query Tool connection first.', view_name;
        END IF;
    END LOOP;
END $$;

CREATE TEMP TABLE p2_measurement (
    stage text NOT NULL CHECK (stage IN ('baseline','indexed')),
    query_id text NOT NULL, run integer NOT NULL,
    execution_ms numeric NOT NULL, planning_ms numeric NOT NULL,
    shared_hits integer NOT NULL, shared_reads integer NOT NULL,
    plan jsonb NOT NULL, PRIMARY KEY(stage, query_id, run)
);
CREATE TEMP TABLE p2_result (
    stage text NOT NULL, query_id text NOT NULL, result_rows jsonb NOT NULL,
    PRIMARY KEY(stage, query_id)
);

CREATE FUNCTION pg_temp.p2_measure(stage_name text) RETURNS void LANGUAGE plpgsql AS $$
DECLARE q integer; r integer; query_name text; query_id text; plan_doc jsonb; rows_doc jsonb;
BEGIN
    IF stage_name NOT IN ('baseline','indexed') THEN RAISE EXCEPTION 'Invalid benchmark stage'; END IF;
    FOR q IN 1..7 LOOP
        query_name := 'p2_q' || lpad(q::text,2,'0');
        IF to_regclass('pg_temp.' || query_name) IS NULL THEN
            RAISE EXCEPTION 'Missing temporary view %. Execute 01-queries.sql in this same Query Tool connection before measuring.', query_name;
        END IF;
    END LOOP;
    FOR q IN 1..7 LOOP
        query_id := 'Q' || lpad(q::text,2,'0');
        query_name := 'p2_q' || lpad(q::text,2,'0');
        -- Default planner choices retained; no forced indexes or disabled sequential scans.
        EXECUTE format('EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT * FROM pg_temp.%I', query_name) INTO plan_doc;
        FOR r IN 1..5 LOOP
            EXECUTE format('EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) SELECT * FROM pg_temp.%I', query_name) INTO plan_doc;
            INSERT INTO p2_measurement VALUES (
                stage_name, query_id, r,
                (plan_doc->0->>'Execution Time')::numeric,
                (plan_doc->0->>'Planning Time')::numeric,
                COALESCE((plan_doc->0->'Plan'->>'Shared Hit Blocks')::integer,0),
                COALESCE((plan_doc->0->'Plan'->>'Shared Read Blocks')::integer,0), plan_doc
            );
        END LOOP;
        -- Canonical ordering compares complete row multisets, preserving duplicates.
        EXECUTE format('SELECT COALESCE(jsonb_agg(to_jsonb(x) ORDER BY to_jsonb(x)::text), ''[]''::jsonb) FROM (SELECT * FROM pg_temp.%I) x', query_name)
            INTO rows_doc;
        INSERT INTO p2_result VALUES (stage_name, query_id, rows_doc);
        RAISE NOTICE 'Captured %: % (five runs)', stage_name, query_id;
    END LOOP;
END $$;

SELECT pg_temp.p2_measure('baseline');
SELECT query_id, count(*) AS runs,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY execution_ms) AS median_execution_ms,
       min(execution_ms) AS min_ms, max(execution_ms) AS max_ms,
       percentile_cont(0.5) WITHIN GROUP (ORDER BY shared_hits + shared_reads) AS median_buffer_accesses
FROM p2_measurement WHERE stage = 'baseline' GROUP BY query_id ORDER BY query_id;

-- Run individually for readable baseline plan screenshots BEFORE 03-indexes.sql.
-- EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM p2_q02;
-- EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM p2_q07;

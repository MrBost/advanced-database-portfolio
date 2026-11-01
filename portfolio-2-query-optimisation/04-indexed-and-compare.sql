-- Same session and definitions, one warm-up + five runs again.
SELECT pg_temp.p2_measure('indexed');

DO $$
BEGIN
    IF (SELECT count(*) FROM p2_measurement) <> 70 OR
       (SELECT count(*) FROM p2_result) <> 14 THEN
        RAISE EXCEPTION 'FAIL: incomplete before/after measurements';
    END IF;
    IF EXISTS (
        SELECT 1 FROM p2_result b JOIN p2_result a USING(query_id)
        WHERE b.stage = 'baseline' AND a.stage = 'indexed' AND b.result_rows <> a.result_rows
    ) THEN RAISE EXCEPTION 'FAIL: indexing changed query results'; END IF;
    RAISE NOTICE 'PASS: all seven result sets identical before/after indexing; 70 measured plans captured';
END $$;

WITH medians AS (
    SELECT stage, query_id,
           percentile_cont(0.5) WITHIN GROUP (ORDER BY execution_ms) AS median_ms,
           percentile_cont(0.5) WITHIN GROUP (ORDER BY shared_hits + shared_reads) AS median_buffers
    FROM p2_measurement GROUP BY stage, query_id
)
SELECT b.query_id, round(b.median_ms::numeric,3) AS baseline_ms,
       round(a.median_ms::numeric,3) AS indexed_ms,
       round((100*(b.median_ms-a.median_ms)/NULLIF(b.median_ms,0))::numeric,2) AS reduction_percent,
       b.median_buffers AS baseline_buffers, a.median_buffers AS indexed_buffers
FROM medians b JOIN medians a USING(query_id)
WHERE b.stage = 'baseline' AND a.stage = 'indexed' ORDER BY b.query_id;

SELECT b.query_id, jsonb_array_length(b.result_rows) AS result_count,
       b.result_rows = a.result_rows AS identical_results
FROM p2_result b JOIN p2_result a USING(query_id)
WHERE b.stage = 'baseline' AND a.stage = 'indexed' ORDER BY b.query_id;

-- Select these individually to capture readable indexed plan screenshots.
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM p2_q02;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM p2_q07;

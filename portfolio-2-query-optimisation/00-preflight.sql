-- Run on the Portfolio 1 dataset before collecting the baseline.
-- No data is inserted, updated or deleted by Portfolio 2.
SET TIME ZONE 'Africa/Lagos';
SET search_path TO bookmania, public;
SELECT current_database() AS database_name, version() AS server_version;
SELECT name, setting, unit FROM pg_settings
WHERE name IN ('shared_buffers','work_mem','random_page_cost','seq_page_cost',
               'max_parallel_workers_per_gather','jit','enable_seqscan') ORDER BY name;

DO $$
BEGIN
    IF (SELECT count(*) FROM bookmania.customer) <> 1000 OR
       (SELECT count(*) FROM bookmania.book) <> 500 OR
       (SELECT count(*) FROM bookmania.customer_order) <> 10000 OR
       (SELECT count(*) FROM bookmania.order_item) <> 30000 OR
       (SELECT count(*) FROM bookmania.payment) <> 8000 THEN
        RAISE EXCEPTION 'Use the unchanged Portfolio 1 seed dataset for this comparison';
    END IF;
    IF EXISTS (
        SELECT 1 FROM pg_index i JOIN pg_class t ON t.oid = i.indrelid
        JOIN pg_namespace n ON n.oid = t.relnamespace
        WHERE n.nspname = 'bookmania'
          AND NOT EXISTS (SELECT 1 FROM pg_constraint c WHERE c.conindid = i.indexrelid)
    ) THEN
        RAISE EXCEPTION 'Baseline requires only Portfolio 1 constraint indexes; use a fresh benchmark database';
    END IF;
    RAISE NOTICE 'PASS: expected dataset and constraint-only baseline indexes';
END $$;
ANALYZE bookmania.book;
ANALYZE bookmania.customer_order;
ANALYZE bookmania.order_item;
ANALYZE bookmania.payment;
SELECT tablename, indexname, indexdef FROM pg_indexes
WHERE schemaname = 'bookmania' ORDER BY tablename, indexname;

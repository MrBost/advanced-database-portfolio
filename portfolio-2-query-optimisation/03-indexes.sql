-- Run only AFTER baseline capture. These two non-unique B-tree indexes persist.
-- No existing constraint indexes are dropped, and no business data is changed.
BEGIN;
CREATE INDEX p2_orders_customer_date_idx
ON bookmania.customer_order (customer_id, ordered_at DESC, order_id DESC);

-- The existing (order_id, book_id) primary key leads with order_id.
-- A book-first index supports Q07 without scanning all 30,000 order lines.
CREATE INDEX p2_order_item_book_idx ON bookmania.order_item (book_id);
COMMIT;

-- Statistics were collected before the baseline. With no row changes, retain
-- those same statistics here to isolate index creation as the intervention.
SELECT indexname, indexdef FROM pg_indexes
WHERE schemaname = 'bookmania' AND indexname LIKE 'p2_%' ORDER BY indexname;
SELECT c.relname AS index_name, pg_relation_size(c.oid) AS size_bytes
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'bookmania' AND c.relname IN ('p2_orders_customer_date_idx','p2_order_item_book_idx')
ORDER BY c.relname;

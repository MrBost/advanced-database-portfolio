-- Temporary views keep identical query definitions for both benchmark stages.
-- Run all Portfolio 2 files in ONE pgAdmin Query Tool tab / psql session.

-- Q01: Affordable technology books matching a catalogue search (up to 20).
CREATE TEMP VIEW p2_q01 AS
SELECT b.book_id, b.title, c.name AS category, b.unit_price, b.stock_quantity
FROM bookmania.book b JOIN bookmania.category c USING(category_id)
WHERE b.category_id = 1 AND b.unit_price <= 5000 AND b.title ILIKE '%Book%'
ORDER BY b.unit_price, b.book_id LIMIT 20;

-- Q02: Order history for customer 42, newest first.
CREATE TEMP VIEW p2_q02 AS
SELECT order_id, ordered_at, status, delivery_city
FROM bookmania.customer_order
WHERE customer_id = 42
ORDER BY ordered_at DESC, order_id DESC LIMIT 20;

-- Q03: Total for one order; uses historical purchase prices, not current prices.
CREATE TEMP VIEW p2_q03 AS
SELECT order_id, total_amount
FROM bookmania.order_total WHERE order_id = 1255;

-- Q04: Ten best-selling books, counting only orders with a successful payment.
CREATE TEMP VIEW p2_q04 AS
SELECT b.book_id, b.title, SUM(oi.quantity) AS copies_sold,
       SUM(oi.quantity * oi.unit_price_at_purchase) AS sales_value
FROM bookmania.book b JOIN bookmania.order_item oi USING(book_id)
JOIN bookmania.payment p USING(order_id)
GROUP BY b.book_id, b.title
ORDER BY copies_sold DESC, b.book_id LIMIT 10;

-- Q05: Monthly paid sales; one Payment row per order prevents double counting.
-- Explicit Lagos time makes month boundaries independent of connection settings.
CREATE TEMP VIEW p2_q05 AS
SELECT date_trunc('month', paid_at AT TIME ZONE 'Africa/Lagos')::date AS sales_month,
       COUNT(*) AS paid_orders, SUM(amount) AS paid_sales
FROM bookmania.payment GROUP BY 1 ORDER BY 1;

-- Q06: Low-stock catalogue report, threshold 105 for this synthetic dataset.
CREATE TEMP VIEW p2_q06 AS
SELECT book_id, title, stock_quantity
FROM bookmania.book WHERE stock_quantity < 105
ORDER BY stock_quantity, book_id;

-- Q07: Paid order lines for one book; tests a selective book-first lookup.
CREATE TEMP VIEW p2_q07 AS
SELECT oi.order_id, oi.book_id, oi.quantity, oi.unit_price_at_purchase,
       p.reference AS payment_reference
FROM bookmania.order_item oi JOIN bookmania.payment p USING(order_id)
WHERE oi.book_id = 42 ORDER BY oi.order_id;

-- Select one statement at a time in pgAdmin to inspect its result grid.
SELECT * FROM p2_q01;
SELECT * FROM p2_q02;
SELECT * FROM p2_q03;
SELECT * FROM p2_q04;
SELECT * FROM p2_q05;
SELECT * FROM p2_q06;
SELECT * FROM p2_q07;

-- For a visual plan in pgAdmin, select one query and use Explain Analyze.
-- Or execute: EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM p2_q02;

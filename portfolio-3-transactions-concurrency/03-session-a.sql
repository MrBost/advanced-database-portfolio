-- Run in Query Tool A. Leave this connection open and DO NOT commit yet.
BEGIN ISOLATION LEVEL READ COMMITTED;
SET LOCAL application_name = 'BookMania_P3_A';
SELECT pg_backend_pid() AS session_a_pid, current_setting('transaction_isolation') AS isolation;
SELECT bookmania.place_order(
    (SELECT customer_id FROM bookmania.customer WHERE email='portfolio3@example.com'),
    (SELECT book_id FROM bookmania.book WHERE isbn='9789999000003'), 1
) AS session_a_order_id;
SELECT stock_quantity AS a_uncommitted_stock FROM bookmania.book WHERE isbn='9789999000003';
-- Expected: 0 inside A. A holds the book row lock until its transaction ends.
-- Next: start 04-session-b.sql in another tab, then observe from tab C.
-- ONLY AFTER recording B's lock wait, execute COMMIT; manually in THIS tab.

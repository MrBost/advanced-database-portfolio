-- Run in Query Tool B: a different connection to the SAME database as A.
BEGIN ISOLATION LEVEL READ COMMITTED;
SET LOCAL application_name = 'BookMania_P3_B';
SET LOCAL lock_timeout = '5min';
SELECT pg_backend_pid() AS session_b_pid, current_setting('transaction_isolation') AS isolation;

-- Waits while A holds the lock. While it waits, use 05-observe.sql in tab C.
SELECT bookmania.place_order(
    (SELECT customer_id FROM bookmania.customer WHERE email='portfolio3@example.com'),
    (SELECT book_id FROM bookmania.book WHERE isbn='9789999000003'), 1
) AS session_b_order_id;

-- After A commits, B reads updated stock 0 and raises:
-- Insufficient stock: requested 1, available 0
-- Execute ROLLBACK; manually in THIS tab after capturing the expected error.
-- A lock-timeout error means A was not released in time; it is not the intended result.

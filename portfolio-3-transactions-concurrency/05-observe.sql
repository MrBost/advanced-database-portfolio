-- Query Tool C, same database/role. Run while A is open and B is waiting.
-- Leave C in auto-commit mode: these are ordinary, non-locking reads.
SELECT pg_backend_pid() AS observer_pid, current_setting('transaction_isolation') AS isolation;

SELECT b.title,b.stock_quantity AS committed_stock,count(oi.order_id) AS committed_order_lines
FROM bookmania.book b LEFT JOIN bookmania.order_item oi USING(book_id)
WHERE b.isbn='9789999000003' GROUP BY b.book_id;
-- BEFORE A commits: committed_stock 1, lines 0, even though A sees stock 0.
-- AFTER A commits: rerun and expect committed_stock 0, lines 1.

SELECT pid,application_name,state,wait_event_type,wait_event,
       pg_blocking_pids(pid) AS blocking_pids
FROM pg_stat_activity
WHERE datname=current_database() AND application_name IN ('BookMania_P3_A','BookMania_P3_B')
ORDER BY application_name;
-- While B waits, B has wait_event_type Lock and blocking_pids contains A's PID.

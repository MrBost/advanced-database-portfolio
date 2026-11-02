-- Run on STANDBY (localhost:55436), database bookmania.
SELECT current_database(),pg_is_in_recovery() AS is_standby,
       current_setting('transaction_read_only') AS transaction_read_only;
SELECT status,sender_host,sender_port,latest_end_lsn FROM pg_stat_wal_receiver;
SELECT book_id,isbn,title,unit_price,stock_quantity
FROM bookmania.book WHERE isbn='9789999500001';
-- Expect true, on, streaming, and the same inserted book as the primary.
-- Asynchronous replay can lag: rerun the SELECT if the row is not yet visible.

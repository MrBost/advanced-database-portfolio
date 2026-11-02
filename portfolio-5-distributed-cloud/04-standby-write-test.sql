-- Run on STANDBY ONLY. Expected SQLSTATE 25006: read-only transaction.
DO $$
BEGIN
    IF NOT pg_is_in_recovery() THEN RAISE EXCEPTION 'Wrong server: connect to standby on port 55436'; END IF;
END $$;

UPDATE bookmania.book SET stock_quantity=stock_quantity
WHERE isbn='9789999500001';
-- This no-op UPDATE is still a write command and must be rejected on standby.
-- If pgAdmin reports an aborted transaction afterward, execute ROLLBACK;
-- then rerun the SELECT from 03-standby-read.sql to confirm stock remains 7.

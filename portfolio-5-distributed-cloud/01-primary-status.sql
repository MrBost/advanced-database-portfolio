-- Run on PRIMARY (localhost:55435), database bookmania.
SELECT version(), current_database(), pg_is_in_recovery() AS is_standby;
SHOW synchronous_standby_names;
SELECT application_name,state,sync_state,sent_lsn,write_lsn,flush_lsn,replay_lsn,
       pg_wal_lsn_diff(sent_lsn,replay_lsn) AS sent_to_replay_bytes
FROM pg_stat_replication;
-- Expect is_standby false, one streaming connection, sync_state async.

# BookMania replication and cloud discussion

## Replication and consistency

The primary handles BookMania writes. Its write-ahead log (WAL) is streamed to the standby, which replays those changes. The base backup creates the starting copy; ongoing streaming carries later changes. A standby in recovery serves SELECT queries but rejects the demonstrated UPDATE.

This setup is **asynchronous**: primary commits do not wait for standby replay. A customer may therefore read an older catalogue value from the standby immediately after a primary write. Stock checks, payments and immediate read-after-write confirmation should use the primary. The demo waits for the replicated record to become visible rather than claiming zero lag or cross-node serialisability.

`pg_stat_replication` shows the sender's state, asynchronous mode and WAL positions; `pg_stat_wal_receiver` shows the receiver. The demonstrated `sent_to_replay_bytes` measures the difference between WAL already sent and reported replayed, not end-to-end response latency or all possible outstanding writes. A zero observed difference is a snapshot, not a guarantee of permanent zero lag.

## Availability and backups

A standby offers another copy and a possible recovery target. **Automatic failover is not configured or tested.** A primary failure would require a controlled standby promotion and client reconnection; asynchronous replication can lose commits not yet received/replayed. The old primary must be prevented from returning as a competing writer. Restarting a long-disconnected standby can require rebuilding it if the needed WAL has been recycled; this small demo retains 64 MB of WAL and does not implement archive recovery or replication slots.

Both containers run on one host, so host failure affects both. This is a local distributed-database exercise, not production high availability across independent machines. Replication also propagates accidental changes; retain separate backups and test restoration. The initial base backup is used to bootstrap replication, not a complete ongoing backup policy.

## Sharding

Replication copies the same data; sharding partitions it. Customer-ID sharding could distribute customers and their orders if BookMania grew much larger. However, stock is shared across customers and orders can contain several books, making cross-shard stock coordination and reporting more complex. This small bookshop does not need that added complexity, so no sharding is implemented.

## Possible cloud deployment

A future managed PostgreSQL deployment could place a primary and replica across independent availability zones, with private networking, managed credentials, monitoring, backups and point-in-time recovery. Writes and stock-sensitive reads would use the primary endpoint, with suitable reporting/catalogue reads routed to a read-replica endpoint.

Provider-specific replication mode and failover guarantees must be checked before deployment; a read replica is not automatically a synchronous high-availability standby. BookMania would need to choose acceptable recovery time/data-loss targets, test failover/restore and account for cost. No cloud resources were provisioned for this exercise.

## References

- Miva Open University, MIT 8103 Advanced Database Systems CA, September Cohort 2026: Portfolio 5 distributed/cloud exercise.
- PostgreSQL 17: [Standby servers and streaming replication](https://www.postgresql.org/docs/17/warm-standby.html).
- PostgreSQL 17: [pg_basebackup](https://www.postgresql.org/docs/17/app-pgbasebackup.html).
- PostgreSQL 17: [Replication monitoring](https://www.postgresql.org/docs/17/monitoring-stats.html).

Documentation consulted 2 November 2026. Cloud deployment is a proposed design, not an executed setup.

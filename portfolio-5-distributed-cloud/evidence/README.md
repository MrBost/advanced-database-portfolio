# Portfolio 5 evidence

The retained evidence consists of the student's nine selected screenshots, the Compose/shell/SQL implementation and the [replication/cloud discussion](../discussion.md). The optional automated-test log and redundant blank synchronous-standby capture have been removed. The replication-status screenshot directly shows asynchronous mode.

## Student screenshot index

The student confirmed execution on **2 November 2026**. Nine selected screenshots are retained from that review. The PostgreSQL version is **17.10** and the database is **bookmania**, as shown in the primary information capture.

| Screenshot | What it demonstrates |
|---|---|
| [Container startup](screenshots/healthy-containers.png) | Project bookmania-p5 running two services; primary marked Healthy and standby Started. This image alone does not show the standby's health-check result; later SQL confirms it serves queries. |
| [Primary information](screenshots/postgres-info.png) | PostgreSQL 17.10, database bookmania and is_standby false. |
| [Replication status](screenshots/replication-stat.png) | bookmania_standby connected in streaming state, sync_state async and sent-to-replay difference zero at the captured moment. |
| [Primary record](screenshots/primary-insert.png) | Book 501, ISBN 9789999500001, BookMania Replication Demo, price 2500 and stock 7 on primary. |
| [Standby role](screenshots/standby.png) | Database bookmania, is_standby true and transaction_read_only on. |
| [Receiver status](screenshots/receiver-stat.png) | Receiver connected to host primary on container port 5432 with a received WAL position; the status text is horizontally truncated. |
| [Replicated record](screenshots/standby-data.png) | Matching book ID/ISBN, price and stock on standby. The long title is truncated, but identifying fields match the primary result. |
| [Rejected write](screenshots/standby-error.png) | Cannot execute UPDATE in a read-only transaction, SQLSTATE 25006. This error is the expected outcome. |
| [Unchanged stock](screenshots/stock-remains-7.png) | Subsequent standby result still shows stock 7 and the same book. |

## Attribution and interpretation

The student confirmed the project distinction: the startup capture shows **bookmania-p5**, while the connection timeout repair was applied to **bookmania-p5-student**. The SQL images do not independently show project/container identity, so they are not used to claim a particular project's startup sequence. Likewise, the startup image alone does not establish a fresh insert; the primary/standby result screenshots establish the matching visible record. The execution date is student-confirmed.

Taken together, the captures demonstrate primary/standby roles, asynchronous streaming, matching records and standby write rejection. The root/portfolio READMEs record the confirmed date, project context, connection difficulty and resolution. No extra implementation feature is required.

The zero byte difference is a point-in-time observation, not proof of permanent zero lag. LSNs and container names vary across runs. The primary and standby's host ports are 55435/55436; sender_port 5432 is the internal container port, not the pgAdmin connection port.

Do not include `.env`, passwords or resolved Compose environment output in screenshots. No passwords are visible in these reviewed captures.

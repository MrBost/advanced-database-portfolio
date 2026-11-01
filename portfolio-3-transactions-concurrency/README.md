# Portfolio 3 - BookMania transactions and concurrency

This activity demonstrates **commit, rollback, isolation and concurrency control** using BookMania orders and stock. Its scope is one-book order placement; payments, delivery workflows and extra isolation-level experiments are not required for this demonstration.

**Status:** implemented and student-reviewed, with ten screenshots, run details and a personal reflection documented. Commit, rollback, isolation visibility, blocking, buyer rejection and the expected final state are evidenced by the student's captures.

## Transaction design

`bookmania.place_order(customer_id, book_id, quantity)` locks the selected book with `SELECT ... FOR UPDATE`, checks the returned stock, inserts the order and line, then deducts stock. Price and address snapshots preserve history. The function runs inside the caller's transaction; it does not commit by itself.

Without coordination, two buyers could both act on the same availability check. Here B waits for A's row lock, then checks the updated stock after A commits. READ COMMITTED prevents the observer from reading A's uncommitted changes. Ordinary reads can still see the previously committed book row while a writer holds this row lock.

## Prepare once

Create a fresh database, such as `bookmania_p3_student`, and run Portfolio 1's `01-schema.sql` and `02-seed.sql` there. This preserves your reviewed Portfolio 1/2 database and original row counts. Portfolio 2 indexes are not required.

Run `00-setup.sql` once. It adds a dedicated synthetic customer, three demo books and the order-placement function. It does not reset/delete existing records. If fixtures already exist, inspect the existing state or use a new demo database; do not repeat successful purchases blindly.

In pgAdmin, keep auto-commit enabled and automatic rollback on error disabled so the explicit transaction commands control the exercise. Run the files in the order below, not as one combined batch.

## Run the demonstrations

### Commit

Run the entire `01-commit.sql` file together, once. After COMMIT, expect one pending order for two copies and stock **5 -> 3**. Capture the output. To display it again, execute only the final SELECT: repeating the purchase creates another order and deducts more stock.

### Rollback

Execute `02-rollback.sql` in **three separate selections in the same tab**:

1. Part 1: create an order inside BEGIN; observe stock 3 and one line.
2. Part 2: raise the intentional failure. The ERROR is expected.
3. Part 3: execute ROLLBACK; observe stock 5 and zero lines.

Do not rerun the whole file after the error. Execute Part 3 to finish. The order header is also undone, checked by final verification. Identity values may have gaps after rollback; gaps are not orphan records.

### Isolation and two-session concurrency

Open **three separate Query Tool connections to the same demo database**, using the same role. Unlike Portfolio 2's temporary-object workflow, this demonstration deliberately needs different connections. A and B should report different backend PIDs.

| Step | Connection | Action |
|---|---|---|
| 1 | A | Run `03-session-a.sql`. A sees stock 0 but its transaction stays open. **Do not commit yet.** |
| 2 | B | Run `04-session-b.sql`. The purchase SELECT waits for A's lock. |
| 3 | C | Run `05-observe.sql` while B waits. Capture committed stock 1, zero committed lines, and B's Lock wait with A's PID in blocking_pids. |
| 4 | A | Execute `COMMIT;` manually in A. |
| 5 | B | Capture `Insufficient stock: requested 1, available 0`, then execute `ROLLBACK;` manually in B. |
| 6 | C | Rerun the stock query from `05-observe.sql`: stock 0, one committed line. |

B has a five-minute lock timeout. A timeout is not the intended insufficient-stock result: roll back B, retry while A still holds the lock, then commit A promptly. Finish all open transactions after the demonstration.

### Final verification

Run `06-verify.sql` after A commits and B rolls back. Expect three PASS notices and:

| Book | Stock | Order lines | Copies ordered |
|---|---:|---:|---:|
| P3 Commit Demo | 3 | 1 | 2 |
| P3 Rollback Demo | 5 | 0 | 0 |
| P3 Last Copy Demo | 0 | 1 | 1 |

Exactly two orders should remain for the demo customer: the committed example and the last-copy sale. Use a fresh demo database for a new full run rather than changing stock manually.

## Evidence and student reflection

### My execution and observations

I executed the activity on **1 November 2026** using **PostgreSQL 17.5** and a fresh database, **bookmania_p3_retry**. My [evidence index](evidence/README.md) links ten pgAdmin screenshots. The committed example retained one order for two copies and stock 3. The rollback example returned stock to 5 and removed the temporary line. Session B waited on Session A's lock, then received an insufficient-stock error after A committed. The final grid matches the expected results for all three books.

The isolation evidence shows [A's uncommitted stock 0](evidence/uncommitted.png), while [the observer sees committed stock 1 and zero lines before commit](evidence/stock1-zero-line.png). The [after-commit observer capture](evidence/stock-query-rerun.png) then shows stock 0 and one line. This comparison supports the READ COMMITTED demonstration: another session does not see A's uncommitted purchase.

### My challenge and lesson

I initially ran the commit purchase more than once while trying to capture its result. Two successful purchases reduced stock from 5 to 3 and then to 1, so the next attempt failed with `Insufficient stock: requested 2, available 1` (SQLSTATE P0001). ROLLBACK could clear the failed transaction but could not undo the purchases that had already committed.

I resolved this by creating `bookmania_p3_retry` and repeating the setup and demonstrations in the required order. I learned to execute a purchase transaction once and rerun only its result SELECT when I need another screenshot. A fresh demo database also gives a predictable starting state for verification. The concurrency result shows why the stock check must happen after the row lock is acquired: B must check the stock left by A rather than act on an earlier availability value.

## Sources and AI assistance

- Miva Open University, MIT 8103 Advanced Database Systems CA, September Cohort 2026: commit, rollback, isolation, concurrency issue/control and supporting evidence.
- PostgreSQL 17: [Transaction isolation](https://www.postgresql.org/docs/17/transaction-iso.html) and [explicit locking](https://www.postgresql.org/docs/17/explicit-locking.html), consulted 1 November 2026.

Codex assisted with SQL, documentation, initial automated testing, troubleshooting and evidence review. I executed the demonstrations in pgAdmin, supplied the screenshots, including the complementary isolation capture, and described my repeated-purchase error and recovery. The submitted evidence relies on my screenshots; the optional automated-test log and development harness are not included. I remain responsible for understanding and explaining the work.

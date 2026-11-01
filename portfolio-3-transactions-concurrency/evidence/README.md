# Portfolio 3 evidence

## Student run

- Database: **bookmania_p3_retry**.
- PostgreSQL version: **17.5**.
- Execution date: **1 November 2026** (Africa/Lagos).
- Interface: pgAdmin Query Tool.
- Run details and recovery are based on the student's account in the [Portfolio 3 README](../README.md).

## Student screenshot index

| Screenshot | What it demonstrates |
|---|---|
| [Commit](commit.png) | Retained order 10001, quantity 2, purchase price NGN 2,000, pending status and remaining stock 3. |
| [Rollback: inside transaction](rollback-1.png) | Stock 3 and one temporary order line before the intentional failure. |
| [Rollback: intentional error](rollback-2.png) | The planned failure, SQLSTATE P0001. This is the demonstration error, not the earlier repeated-purchase mistake. |
| [Rollback: restored state](rollback-3.png) | After ROLLBACK, stock is 5 and no order line remains. |
| [A's uncommitted stock](uncommitted.png) | Session A sees stock 0 inside its open transaction. This image alone does not prove what another session can read. |
| [Observer before commit](stock1-zero-line.png) | Session C sees committed stock 1 and zero order lines before A commits, providing the complementary isolation comparison. |
| [Blocking sessions](stat-activity.png) | A has PID 2237; B has PID 2238, waits on a Lock and lists 2237 in blocking_pids. |
| [Rejected second buyer](insufficient-stock.png) | After A commits, B rejects the purchase: requested 1, available 0. |
| [Observer after commit](stock-query-rerun.png) | The committed last-copy state is stock 0 with one order line. |
| [Final verification grid](verify.png) | Commit demo: stock 3/one line/two copies; rollback demo: stock 5/no lines; last-copy demo: stock 0/one line/one copy. |

The ten screenshots support commit, rollback, isolation visibility and concurrency control. The final grid matches the expected state. Backend PIDs and order IDs vary by run. The optional waiting-screen image and automated-test log have been removed; the activity result provides direct evidence of blocking.

## Isolation comparison

The complementary [observer-before-commit capture](stock1-zero-line.png) shows **committed stock 1 and zero lines**. Alongside [A's uncommitted stock 0](uncommitted.png), it demonstrates that another session sees the previously committed state rather than A's uncommitted purchase.

The [observer-after-commit capture](stock-query-rerun.png) shows stock 0 and one committed line. The before/after states complete the direct visibility comparison. The SQL scripts explicitly request READ COMMITTED for A/B. The numbered scripts and student captures form the retained implementation evidence.

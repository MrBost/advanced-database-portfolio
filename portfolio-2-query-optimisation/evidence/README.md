# Portfolio 2 evidence

This folder contains **14 selected screenshots from my pgAdmin execution**. Together with SQL scripts `00`-`04` and the [performance analysis](../performance-analysis.md), they demonstrate the queries, results, execution plans, indexing and measured comparison. Optional automated benchmark exports and helper tools have been removed.

My [run record](student-run.md) documents PostgreSQL 17.5, database `bookmania` and execution date 1 November 2026. The [run summary](run-summary.md) provides the method and main findings.

## Query results, settings and measurements

| Screenshot | What it demonstrates |
|---|---|
| [PostgreSQL settings](screenshots/pg-settings.png) | Memory/planner settings, including enable_seqscan = on. |
| [Baseline indexes](screenshots/baseline-index.png) | The 14 original primary-key/unique indexes before adding the Portfolio 2 indexes. |
| [Q03 order total](screenshots/order-total-temp-view.png) | Order 1255 totals NGN 44,750. |
| [Q05 monthly sales](screenshots/sales-month-temp-view.png) | Five monthly totals covering 8,000 paid orders and NGN 300,610,250. |
| [Baseline medians](screenshots/baseline-metric.png) | Five measured runs per query, baseline medians/ranges and shared buffer accesses. |
| [New index definitions](screenshots/index-definition.png) | The customer/date and book_id B-tree index definitions. |
| [Index storage](screenshots/index-storage.png) | 221,184 bytes for the book index and 425,984 bytes for the customer/date index. |
| [Before/after medians](plans/indexed/median.png) | Seven timing comparisons, reduction percentages and buffer counts. |
| [Result equality](plans/indexed/result.png) | All seven result sets are identical before/after indexing, with expected row counts. |

## Before/after execution plans

| Query | Baseline screenshot | Indexed screenshot |
|---|---|---|
| Q02 | [Order history baseline](plans/baseline/baseline-q02.png) | [Order history indexed](plans/indexed/index-q02.png) |
| Q07 | [Book lines baseline](plans/baseline/baseline-q07.png) | [Book lines indexed: part A](plans/indexed/index-q07A.png) and [part B](plans/indexed/index-q07B.png) |

Q07 parts A and B cover plan rows 1-23: scans/join/buffers, followed by planning and execution times. Some long lines are horizontally truncated, but the index name, access methods, buffer totals and final timings are visible.

Individual plan screenshots are separate EXPLAIN executions, not the five-run medians. The complementary Q07 capture shows **21.122 ms**, while the earlier comparison grid records a **1.122 ms median**. Keep both values in context: the later screenshot demonstrates the access path and its variability, not a replacement median or a guarantee that every indexed execution is faster.

The comparison/equality grids cover all seven queries. `01-queries.sql` contains all seven executable queries, so their result grids can be reproduced. Selected query-result screenshots are provided for Q03 and Q05 rather than duplicating every result.

Use the required student prefix when preparing final upload files.

# Portfolio 2 - BookMania query processing and optimisation

This activity implements SQL reports for the same BookMania case study, inspects how PostgreSQL executes them, and measures the effect of two targeted indexes. It uses the unchanged Portfolio 1 synthetic dataset.

**Status:** implementation, student review, technical reflection and performance documentation are complete. The 14 selected screenshots are indexed, including complementary Q07 plan captures. The submitted evidence consists of SQL scripts, student screenshots and written analysis.

## Queries

| ID | Purpose | Expected output on the seed data |
|---|---|---|
| Q01 | Search affordable technology books | 20 books, ordered by price and book ID |
| Q02 | Retrieve customer 42's newest orders | 10 orders |
| Q03 | Calculate order 1255's historical total | One row: NGN 44,750 |
| Q04 | Report the ten best-selling books from paid orders | 10 books, ranked by copies sold with book ID as tie-breaker |
| Q05 | Summarise monthly successful payments | Five months; 8,000 paid orders totalling NGN 300,610,250 |
| Q06 | Find books with stock below 105 copies | 50 books |
| Q07 | Retrieve paid order lines for book 42 | 60 lines |

Q01-Q06 cover the implementation plan. Q07 adds a selective lookup to demonstrate when a book-first order-item index is useful. Payments represent successful payments under the Portfolio 1 business rules. Sales queries use those records rather than treating pending orders as sales.

## Files and execution order

| File | Action |
|---|---|
| `00-preflight.sql` | Check dataset and baseline indexes, record settings, collect planner statistics. |
| `01-queries.sql` | Define the seven queries as temporary views and display their results. |
| `02-baseline.sql` | Run each query once to warm up, then capture five timed execution plans; display baseline medians. |
| `03-indexes.sql` | Create the two persistent indexes and show their definitions/storage. |
| `04-indexed-and-compare.sql` | Repeat the measurements, assert unchanged results, and show comparisons and example plans. |
| [Performance analysis](performance-analysis.md) | Explain the measured improvements, unchanged plans and trade-offs. |
| [Evidence index](evidence/README.md) | Locate query-result screenshots, execution plans and timing evidence. |

## Run in pgAdmin

1. Create a **separate database**, such as `bookmania_p2_student`, to preserve your reviewed Portfolio 1 database. Run Portfolio 1's `01-schema.sql` and `02-seed.sql` there once. Do not recreate the schema inside your existing Portfolio 1 database.
2. Open **one Query Tool tab** connected to the new database. Keep this same tab/connection for all Portfolio 2 files: the query views, measurement tables and helper function are temporary session objects. Keep normal auto-commit enabled so you can inspect each step independently.
3. Execute `00-preflight.sql`, followed by `01-queries.sql`. To inspect each result grid, execute the individual `SELECT * FROM p2_q01;` through `SELECT * FROM p2_q07;` statements one at a time after the view definitions have run.
4. Execute `02-baseline.sql`. Save its median-results grid. **Before creating indexes**, execute and capture these plans individually:

   ```sql
   EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM p2_q02;
   EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM p2_q07;
   ```

5. Execute `03-indexes.sql`, then `04-indexed-and-compare.sql`. Capture the indexed plans and compare them with the baseline. The second script contains several result-producing statements; run its comparison SELECT and result-equality SELECT individually if pgAdmin only displays the last result grid.
6. Save your results before closing the connection: temporary measurements disappear when the session ends. The two indexes remain in that database.

Run the five numbered files in order, once each. If you lose the session or need a clean repeated comparison, use a fresh benchmark database with the original seed data. The preflight deliberately rejects additional non-constraint indexes so a previous indexed run cannot be mistaken for a baseline. It does not delete indexes automatically.

Do not compare pgAdmin's overall query-completion timer with the benchmark's server execution time. Record the timings from your own run. Do not manually force index usage or change settings/data between stages.

These are instructions for a fresh repeatable run. In the completed student run, the existing `bookmania` database was reused on PostgreSQL 17.5. Its business records were retained, and the two Portfolio 2 indexes were added there. Use a fresh seeded database for another constraint-only baseline rather than rerunning preflight against that indexed database.

### If a temporary query view is missing

`relation "pg_temp.p2_q01" does not exist` means the query views are absent from the current connection. This can happen if `01-queries.sql` ran in another tab/connection, the connection was restarted, or only its SELECT statements were executed.

In the Query Tool tab where the benchmark function exists, execute the complete `01-queries.sql` file, including all seven `CREATE TEMP VIEW` definitions. Then execute `SELECT pg_temp.p2_measure('baseline');` again. For this specific failure, the failed function call rolls back its work, so do not recreate the measurement tables/function if they already exist. If the transaction is marked aborted, execute `ROLLBACK;` first; if that removes the benchmark objects, restart files 00-02 in order in one connection.

To confirm the views are available before retrying:

```sql
SELECT to_regclass('pg_temp.p2_q01') AS first_query_view,
       to_regclass('pg_temp.p2_q07') AS last_query_view;
```

Both values should be non-null. If `03-indexes.sql` has already run, use a fresh benchmark database for a valid baseline instead of recording an indexed run as the baseline.

## Student review and reflection

### Execution and observations

I executed the activity on **1 November 2026** using **PostgreSQL 17.5** and the existing **bookmania** database from Portfolio 1. I captured the seven query results, baseline/indexed plans, index definitions/storage, baseline measurements and final comparison/equality grids in pgAdmin. The [evidence index](evidence/README.md) links the selected captures. My medians show Q02 falling from 0.713 to 0.028 ms and Q07 from 2.931 to 1.122 ms, with reduced buffer work and unchanged results. The [performance analysis](performance-analysis.md) explains why the other queries' small timing changes are not demonstrated index gains.

### Technical reflection

The important distinction is between a faster elapsed time and a demonstrably more efficient plan. Q02 and Q07 support the index choices because their access paths change and their buffer work falls. Other reports still need to scan or aggregate much of the dataset, so these indexes do not automatically improve them. The two indexes also consume 632 KiB and add maintenance work when indexed data changes.

### Reported challenge and recovery

I encountered `relation "pg_temp.p2_q01" does not exist` when calling the baseline function. I resolved the issue by ensuring that I ran the scripts in the same pgAdmin Query Tool session. This demonstrated why the temporary views and benchmark objects must be created and used within the same connection; using another connection makes those temporary objects unavailable.

My database name, server version and execution date are recorded in the [student run record](evidence/student-run.md). The indexed Q07 plan is documented in two complementary screenshots. Its separate execution time is distinguished from the comparison-grid median in the performance analysis.

## Sources and AI assistance

OpenAI Codex assisted with SQL development, documentation and initial automated benchmarking. I executed the scripts in pgAdmin and supplied my query results, before/after plans, measurements, equality checks and run details. I also troubleshooted the temporary-view error. Codex helped phrase the reflection using my account of the session issue and its resolution and reviewed the screenshots and calculations. Optional automated benchmark exports and helper tools were removed; the submitted performance analysis relies on my retained screenshots. I remain responsible for understanding and explaining the submitted work. The data is the locally generated BookMania dataset, not an external dataset.

References (accessed 31 October 2026):

- Miva Open University, MIT 8103 Advanced Database Systems CA, September Cohort 2026: Portfolio 2 deliverables.
- PostgreSQL 16: [Using EXPLAIN](https://www.postgresql.org/docs/16/using-explain.html).
- PostgreSQL 16: [Multicolumn indexes](https://www.postgresql.org/docs/16/indexes-multicolumn.html).
- PostgreSQL 16: [ANALYZE](https://www.postgresql.org/docs/16/sql-analyze.html).

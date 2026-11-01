# Portfolio 2 execution summary

- Executor: student, using pgAdmin Query Tool.
- Database: `bookmania`, reused from Portfolio 1.
- PostgreSQL version: 17.5, as recorded in the student's updated Portfolio 2 README.
- Execution date: 1 November 2026 (Africa/Lagos).
- Dataset: BookMania's original synthetic records; no business records were changed by the query/index scripts.
- Baseline: 14 original primary-key/unique indexes, shown in the baseline screenshot.
- Method: one discarded warm-up plus five measured executions per query, before and after creating two indexes. The SQL uses the same query definitions in both stages and compares complete result sets.
- Indexes: CustomerOrder(customer_id, ordered_at DESC, order_id DESC) and OrderItem(book_id).
- Main result: Q02 median 0.713 -> 0.028 ms (96.07% reduction); Q07 median 2.931 -> 1.122 ms (61.72% reduction). Buffer accesses fall from 101 to 12 and from 271 to 141 respectively.
- Correctness: all seven equality checks are true; result counts are 20, 10, 1, 10, 5, 50 and 60.
- Example outputs: order 1255 totals NGN 44,750; five monthly payment totals cover 8,000 orders and NGN 300,610,250.
- Storage: two indexes total 647,168 bytes (632 KiB).
- Challenge: missing temporary query view, resolved by running the scripts in the same pgAdmin Query Tool session.
- Evidence: 14 selected screenshots indexed in [README.md](README.md); interpretation in [performance-analysis.md](../performance-analysis.md).

The complementary Q07 plan screenshots show a separate execution taking 21.122 ms. That timing is not the earlier five-run median and illustrates variability. The changed access path and reduced buffer work support the optimisation, while individual runtimes can vary.

This summary relies on the student's retained screenshots. Optional agent benchmark exports and automation files were removed to simplify the portfolio. Historical AI assistance remains acknowledged in the main README.

# Portfolio 2 performance analysis

## Method

I ran seven BookMania queries in pgAdmin, using one discarded warm-up followed by five measured executions per query before and after creating two indexes. The same query definitions and dataset were used in both stages. Original primary-key and unique indexes remained in place, and the planner was free to choose its access paths. Measurements and unchanged-result checks are documented in the selected screenshots.

## Student pgAdmin results

I executed the activity on **1 November 2026** using **PostgreSQL 17.5**, reusing the **bookmania** database from Portfolio 1. The [baseline grid](evidence/screenshots/baseline-metric.png), [comparison grid](evidence/plans/indexed/median.png) and [equality grid](evidence/plans/indexed/result.png) support the table below. Positive reduction means faster; negative means slower. Times are median server execution times in milliseconds, not pgAdmin's overall elapsed timer. Reduction is calculated as `(baseline - indexed) / baseline x 100`.

| Query | Baseline ms | Indexed ms | Reduction % | Shared buffer accesses before / after | Identical results |
|---|---:|---:|---:|---:|---|
| Q01: Catalogue search | 0.218 | 0.204 | 6.42 | 7 / 7 | Yes |
| Q02: Customer order history | 0.713 | 0.028 | 96.07 | 101 / 12 | Yes |
| Q03: Single order total | 0.022 | 0.024 | -9.09 | 3 / 3 | Yes |
| Q04: Best-selling books | 25.685 | 25.414 | 1.06 | 277 / 277 | Yes |
| Q05: Monthly paid sales | 5.668 | 6.212 | -9.60 | 79 / 79 | Yes |
| Q06: Low-stock books | 0.102 | 0.089 | 12.75 | 6 / 6 | Yes |
| Q07: Paid lines for one book | 2.931 | 1.122 | 61.72 | 271 / 141 | Yes |

Q02 shows the strongest improvement: the student plans change from a sequential scan filtering out 9,990 orders to a bitmap index/heap scan for ten orders. Buffer accesses fall from 101 to 12, supporting the measured 96.07% reduction. A small sort remains; index creation did not remove it in this plan.

Q07 improves by 61.72%. Its book_id lookup changes from scanning 30,000 order lines to bitmap access for 60 lines, while buffer accesses fall from 271 to 141. The payment table still receives a sequential scan and hash join, so indexing the order lines does not remove every source of work.

Q01, Q03, Q04, Q05 and Q06 have unchanged buffer counts and no demonstrated benefit from these two indexes. In the student run, Q03 and Q05 are slightly slower, while Q04 is slightly faster. These changes reinforce the need to distinguish timing variability from a changed access path. In particular, the 12.75% difference for Q06 is only 0.013 ms and is not evidence of a successful stock-index optimisation: no stock index was created.

All seven student equality checks are true, with output counts 20, 10, 1, 10, 5, 50 and 60. The query-result screenshots also show order 1255's NGN 44,750 total and the expected five monthly sales totals. The index-storage screenshot records a total size of 632 KiB. Student run metadata is tracked separately in [student-run.md](evidence/student-run.md).

## Index choices and trade-offs

`p2_orders_customer_date_idx` leads with customer_id, matching Q02's equality filter, followed by newest-first order columns. It supports the history access pattern, though this small dataset leads the planner to choose bitmap access plus sorting. `p2_order_item_book_idx` supports Q07's book filter because the original `(order_id, book_id)` primary key is ordered primarily by order_id.

The indexes use additional disk space and require maintenance on inserts, deletes and relevant updates. Their measured storage is listed in the comparison. They should be retained for these demonstrated lookups rather than added indiscriminately to every report column. No new index was added to the small book table or the full-history payment aggregation.

## Limits of the experiment

This is a local before/after experiment on a small synthetic dataset, not a production benchmark or a statistical significance test. Five repetitions reduce sensitivity to one unusual timing. Baseline runs precede indexed runs; cache and background scheduling can influence timings. Displayed plans show shared-buffer hits, so these results should not be treated as a measurement of physical disk I/O. Buffer hits/reads count accesses, not unique pages. EXPLAIN instrumentation adds overhead, and its server execution time excludes client rendering/network latency.

Individual plan screenshots come from separate EXPLAIN executions, so their times need not equal the five-run medians. The complementary indexed Q07 screenshots ([part A](evidence/plans/indexed/index-q07A.png) and [part B](evidence/plans/indexed/index-q07B.png)) show all 23 plan rows and a separate execution time of **21.122 ms**. This is slower than the baseline screenshot's separate 4.718 ms execution and is not the **1.122 ms** indexed median in the earlier comparison grid. The same bitmap access path and 141 buffer accesses remain visible. This later observation demonstrates timing variability; it does not establish a new median or show that every indexed execution is faster. Some long plan lines are horizontally truncated, but the key access methods, index name, buffers and final timings are readable.

The strongest evidence of improvement in the measured comparison is the changed access path and reduced buffer work for Q02 and Q07. Unchanged buffer counts for other queries mean their small timing fluctuations should not be claimed as index gains. Further optimisation of broad reports would require a separate experiment, such as assessing a summary/materialised view and its refresh costs.

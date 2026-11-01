# Student Portfolio 2 run record

## Confirmed from the supplied evidence

- Execution interface: pgAdmin Query Tool.
- Data: BookMania Portfolio 1 synthetic dataset; query screenshots show the expected totals/result counts.
- Baseline index capture: 14 original primary-key and unique indexes.
- Measurement evidence: baseline grid shows five measured runs per query; before/after medians and complete-result equality are captured separately.
- Planner settings: enable_seqscan on; jit on; max_parallel_workers_per_gather 2; random_page_cost 4; seq_page_cost 1; shared_buffers 16,384 x 8 kB (128 MiB); work_mem 4,096 kB (4 MiB).
- Timestamp display: the previously reviewed order-history capture used UTC (+00); that capture was omitted from the selected screenshot set. Display time zones change presentation of timestamptz values, not the stored instants. Q05 explicitly groups sales using Africa/Lagos time.
- New indexes: `p2_orders_customer_date_idx` and `p2_order_item_book_idx`.
- Storage: 425,984 and 221,184 bytes respectively; total 647,168 bytes (632 KiB).
- Outcome: Q02 and Q07 show reduced buffer work and faster medians; all seven result-equality checks are true.
- Sources: [screenshot index](README.md) and [before/after comparison](plans/indexed/median.png).

## Student-confirmed environment and recovery

- Database: `bookmania`, the same database used for Portfolio 1.
- PostgreSQL version: **17.5**, as corrected in the student's updated Portfolio 2 README.
- Execution date: **1 November 2026**, Africa/Lagos.
- Source: the student's explicit confirmation; these details are not visible in the cropped screenshots.

The student resolved `relation "pg_temp.p2_q01" does not exist` by running the scripts in the same pgAdmin Query Tool session. The technical lesson is that temporary views and benchmark objects belong to the connection that creates them and are unavailable in another connection.

The student reused `bookmania` rather than the separate database suggested in the run instructions. Creating the Portfolio 2 indexes changes that database's index structure without changing the business records. For a future clean baseline, use a fresh seeded benchmark database: the current `bookmania` database now contains the additional indexes. The original Portfolio 1 scripts and saved evidence still describe the earlier design state.

## Plan record

The indexed Q07 plan is captured in [part A](plans/indexed/index-q07A.png) and [part B](plans/indexed/index-q07B.png), covering all 23 plan rows. Some long lines are horizontally truncated. The new capture's 21.122 ms execution time is a separate observation from the earlier comparison-grid median of 1.122 ms. The portfolio retains SQL scripts, screenshots and written analysis; optional JSON/CSV exports and Python/psql helpers have been removed.

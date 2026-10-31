# Executed validation summary

- Date: 31 October 2026 (Africa/Lagos).
- Executor of this recorded run: OpenAI Codex agent. The student has subsequently confirmed completing their own review and running the scripts; see the review note below.
- Environment: isolated Docker container `bookmania-p1-validation`, image `postgres:16-alpine`.
- Server reported: PostgreSQL 16.14, Linux x86_64.
- Execution: psql with `ON_ERROR_STOP=1`; schema, seed and validation files ran in order.
- Outcome: exit code 0. All seven tables and the derived view were created.
- Dataset: 5 categories, 1,000 customers, 500 books, 10,000 orders, 30,000 order items, 8,000 payments and 8,000 deliveries.
- Checks: seed counts/business consistency; 16 expected constraint violations; preservation of historical price/address snapshots. All 18 PASS notices were returned.
- Mutation tests ended with ROLLBACK; seed records were retained.
- Full unabridged output: `validation-output.txt`.
- Container stopped after verification; database retained locally for later inspection.

This run validates Portfolio 1 design and seed data. It does not demonstrate concurrency, query optimisation, MongoDB or replication; those remain separate portfolio activities.

## Subsequent student review

The student confirmed running the scripts and verifying the outcome against the validation script, generated the main ER diagram in pgAdmin and supplied eight screenshots of the schema, tables and constraints. These are indexed in [the evidence README](README.md). The original run's executor, environment and results above have been retained without reattributing them to the student. No separate student execution log has been supplied in this folder.

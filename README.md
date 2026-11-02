# BookMania - MIT 8103 Advanced Database Portfolio

This repository contains my individual practical portfolio for MIT 8103 Advanced Database Systems in the Master of Information Technology programme at Miva Open University.

The case study is **BookMania**, a simulated online bookshop that manages books, customers, orders, stock, payments and deliveries. The same case study will be used across all five portfolio activities. All data is synthetic.

| Activity | Status |
|---|---|
| [Portfolio 1: Database design and modelling](portfolio-1-database-design/README.md) | Completed, reviewed and validated; screenshots and technical reflection included |
| [Portfolio 2: Query processing and optimisation](portfolio-2-query-optimisation/README.md) | Completed and reviewed; student results, screenshots, run details and technical reflection documented |
| [Portfolio 3: Transactions and concurrency](portfolio-3-transactions-concurrency/README.md) | Completed and reviewed; transaction, isolation and concurrency evidence and reflection documented |
| [Portfolio 4: NoSQL and advanced models](portfolio-4-nosql/README.md) | Completed and reviewed; document model, CRUD/index evidence, verification and reflection documented |
| Portfolio 5: Distributed and cloud databases | Planned |

Portfolio 1 includes the ER diagram, relational schema, normalisation explanation, PostgreSQL scripts, sample data and validation evidence. I executed the scripts using pgAdmin's Query Tool and captured screenshots of the database structure, row counts and validation results.

See the [Portfolio 1 README](portfolio-1-database-design/README.md) for setup instructions, script execution order, design decisions and my technical reflection. The [evidence index](portfolio-1-database-design/evidence/README.md) links to the screenshots and saved validation output. 

Portfolio 2 adds seven SQL queries, before/after execution plans, two targeted indexes and a measured performance analysis. I executed the activity on 1 November 2026 using PostgreSQL 17.5 and the existing `bookmania` database. My pgAdmin screenshots show the query results, plans, indexes and before/after comparisons, including identical results for all seven queries. The [README](portfolio-2-query-optimisation/README.md) documents my run details and technical reflection, including how I resolved the temporary-view issue by using the same Query Tool session. The [evidence index](portfolio-2-query-optimisation/evidence/README.md) links my selected screenshots and measurements, including the complementary Q07 plan captures.

Portfolio 3 demonstrates commit, rollback, isolation and stock locking for two competing buyers. I ran it on 1 November 2026 using PostgreSQL 17.5 and `bookmania_p3_retry`. Its [evidence index](portfolio-3-transactions-concurrency/evidence/README.md) links ten screenshots, including the observer's before/after committed state, lock wait, rejected buyer and expected final state. My reflection records the repeated-purchase error and recovery.

Portfolio 4 implements a MongoDB document catalogue with embedded authors, variable book attributes, indexes and create/read/update/delete examples. I executed it on 2 November 2026 using MongoDB 8.3.4 and `bookmania_p4`, running the script contents directly in mongosh after file loading failed. All seven verification checks passed. Its [README](portfolio-4-nosql/README.md) records the model, execution steps and reflection; the [evidence index](portfolio-4-nosql/evidence/README.md) links nine screenshots, including the index definitions and final catalogue.

OpenAI Codex assisted with planning, schema design, SQL and MongoDB script development, documentation, automated validation, troubleshooting and evidence review. I reviewed and ran the Portfolio 1 scripts, checked their results and generated the ER diagram in pgAdmin. I also supplied the Portfolio 2 and Portfolio 3 pgAdmin evidence, the Portfolio 4 MongoDB screenshots, and my accounts of challenges and resolutions. Portfolios 2 and 3 retain my SQL scripts, screenshots and written analysis; optional automated outputs and helper tools have been removed. Portfolio 4 separately attributes the original automated test and my own execution. I remain responsible for understanding and explaining the work submitted. The final AI-use declaration will cover the assistance used throughout the completed portfolio.


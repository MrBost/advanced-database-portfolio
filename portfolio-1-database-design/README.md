# Portfolio 1 - BookMania database design and modelling

## Case study

**Organisation:** BookMania Online Bookshop, a simulated retailer of printed books.  
**Users:** customers browse and order books; staff maintain the catalogue, stock, payments and deliveries; the database administrator maintains access and the database. These are business roles, not implemented login accounts in Portfolio 1.  
**Data:** categories, books, customers, orders, order lines, successful payments and deliveries.  
**Operations:** search books, place orders, calculate totals, update stock, record payment, track delivery and report sales.

## Business rules and scope

1. Each book belongs to one category and has one credited author name. Multiple authors, publishers and category memberships are outside this initial scope.
2. A customer may place many orders. Each order belongs to one customer and should have at least one order item.
3. An order can contain many books; each book occurs once per order, with a positive quantity. OrderItem resolves this many-to-many relationship.
4. Prices use Nigerian naira (NGN); quantities and stock are whole numbers. Zero-price books are allowed; successful payments must be positive. No tax, discounts or shipping charges are modelled.
5. Each order has zero or one successful payment and zero or one delivery. Split payments, payment attempts, refunds and partial deliveries are outside scope. Unique foreign keys enforce the maximum of one.
6. Purchase price and shipping address are snapshots taken when an order is placed. Later catalogue/customer updates must not alter historical orders.
7. Referenced records cannot be deleted while dependent rows remain. Cancel orders using status rather than deleting sales history.
8. The database enforces keys, required fields, uniqueness, allowed statuses, quantities, amounts and delivery chronology. It checks the shape of an ISBN, not its checksum; the seed generator does calculate a checksum. Email validation checks basic format, not whether an address exists.

**Transaction-level rules:** at least one item per order, sufficient stock, payment equal to the calculated order total, payment before dispatch and valid status transitions require transaction/service logic. Basic table constraints do not enforce these cross-table rules. Portfolio 1 checks seed consistency; Portfolio 3 will implement order placement and stock locking. Seed stock represents opening remaining stock, not a replay of historical stock movements.

## Design files

- [Student-generated pgAdmin ER diagram (PNG)](er-diagram.png): the main implementation diagram, exported from the student's database.
- [Relational schema and data dictionary](relational-schema.md).
- [Normalisation explanation](normalisation.md).
- `01-schema.sql`: seven tables, constraints and an order-total view.
- `02-seed.sql`: repeatable synthetic dataset on a fresh schema.
- `03-validate.sql`: row counts, seed consistency, 16 constraint checks and historical snapshot checks.
- [Evidence index](evidence/README.md): validation records and eight student-captured screenshots, with descriptions of what each demonstrates.

## Run in PostgreSQL

Requires PostgreSQL 16 or later and psql, or pgAdmin. Use a **new, dedicated database** named `bookmania`; do not run against an existing project database. The scripts create a separate `bookmania` schema and fail safely if it already exists. No DROP/TRUNCATE commands are included. Seed data is intended for one execution per fresh schema.

From a terminal in this folder, after creating the database:

```powershell
psql -U postgres -d bookmania -v ON_ERROR_STOP=1 -f 01-schema.sql
psql -U postgres -d bookmania -v ON_ERROR_STOP=1 -f 02-seed.sql
psql -U postgres -d bookmania -v ON_ERROR_STOP=1 -f 03-validate.sql
```

Supply credentials using your local PostgreSQL configuration or prompt, not a committed password. In pgAdmin, open the Query Tool for the new database and execute the three files separately, in order. Messages contain PASS results; the validation file intentionally rolls back temporary changes. It does not remove the sample data.

Expected row counts: category **5**, customer **1,000**, book **500**, customer_order **10,000**, order_item **30,000**, payment **8,000**, delivery **8,000**. Expect 16 constraint PASS notices plus seed consistency and snapshot PASS notices. A failure raises an error; psql must exit successfully for the run to count as passed.

## Local Docker validation

The agent uses an isolated container named `bookmania-p1-validation` with the existing `postgres:16-alpine` image. No host port or existing database volume is used. Docker supplies an ephemeral password via an environment file outside Git; no application credentials are recorded in the portfolio. The saved run records the database version and results. Use the psql instructions above for your own reproducible run; Docker is optional for this activity.

The validation container has been stopped to free resources; its sample database is retained locally. To inspect the existing database without rerunning schema/seed creation:

```powershell
docker start bookmania-p1-validation
docker exec -it bookmania-p1-validation psql -U postgres -d bookmania
```

In psql, run `SET search_path TO bookmania, public;` before selecting tables. To repeat only the validation from a terminal:

```powershell
docker exec bookmania-p1-validation psql -X -U postgres -d bookmania -v ON_ERROR_STOP=1 -f /tmp/03-validate.sql
docker stop bookmania-p1-validation
```

The local container is not a submission artifact or a replacement for the SQL scripts. It has no host port, so it is not directly accessible to pgAdmin unless a separate connection setup is provided.

## Student review and technical reflection

### Completed student review

I ran the scripts and verified the outcome against the validation script. I also generated the ER diagram from pgAdmin and captured screenshots of the schema, tables and constraints.

### Design rationale

OrderItem uses the composite key `(order_id, book_id)` to prevent a book from appearing twice as separate lines in the same order; quantity records the number of copies. The purchase price and delivery address are stored as historical snapshots so later catalogue or customer updates do not change past orders. Unique `order_id` foreign keys limit each order to one payment and one delivery, matching the chosen scope. Keys and checks enforce the basic data rules, while stock availability and payment-total matching require transaction logic across tables.

### Personal experience

I could not run the psql scripts from PowerShell, so I used the Query Tool in pgAdmin to execute all the scripts. This allowed me to complete the implementation and check the results against the validation script. I learned that pgAdmin's Query Tool provides an alternative way to execute the SQL scripts when I cannot run them through psql in PowerShell. I did not establish the cause of the PowerShell issue during this activity.

## Sources and AI assistance

- Miva Open University, MIT 8103 Advanced Database Systems CA, September Cohort 2026: Portfolio 1 deliverables.
- PostgreSQL documentation: constraints, identity columns and aggregate functions (links in `references.md`).
- Seed data is generated locally; no external dataset is used. ISBN-shaped values and names are synthetic and must not be treated as real catalogue entries.
- OpenAI Codex assisted with planning, SQL implementation, design documentation, the supplementary diagrams, automated validation and the subsequent documentation review. I reviewed and ran the scripts, checked the outcome against the validation script, generated the main ER diagram in pgAdmin and captured the supporting screenshots. The saved agent validation log is identified separately from my review evidence.

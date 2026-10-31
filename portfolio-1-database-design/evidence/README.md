# Portfolio 1 evidence

The original agent-executed PostgreSQL run is saved in [validation-output.txt](validation-output.txt), with a [run summary](run-summary.md). It includes the server version, row counts, 18 PASS notices, sample joined orders and constraint metadata. The student subsequently confirmed running and reviewing the scripts and provided the pgAdmin evidence below. The original log remains attributed to the agent; it is not presented as a log of the student's separate run.

The validation SQL rolls back its temporary updates. Constraint tests assert SQLSTATEs, so an unrelated error does not count as a pass. Source scripts and logs should be kept together.

## Student-captured screenshot index

| Evidence                                                               | What it demonstrates                                                                                                                               |
|------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| [pgAdmin ER diagram](../er-diagram.png)                                | All seven implemented entities and their database relationships.                                                                                   |
| [Schema and tables](screenshots/schema-tables.png)                     | The BookMania schema and its seven tables in pgAdmin.                                                                                              |
| [Category](screenshots/category-table.png)                             | Category columns, primary key, unique name and name check.                                                                                         |
| [Book](screenshots/book-table.png)                                     | Book columns, primary/foreign keys, unique ISBN and price/stock checks.                                                                            |
| [Customer](screenshots/customer-table.png)                             | Customer columns, primary key, email uniqueness/format and nonblank checks.                                                                        |
| [Customer order](screenshots/customer-order.png)                       | Order columns, customer foreign key, primary key and status/address checks.                                                                        |
| [Order item](screenshots/order-item.png)                               | Line-item columns, primary-key constraint, two foreign keys and quantity/price checks. The SQL schema shows the two-column primary-key definition. |
| [Payment](screenshots/payment.png)                                     | Payment columns, order foreign key, unique order/reference and amount/method checks.                                                               |
| [Delivery](screenshots/delivery.png)                                   | Delivery columns, order foreign key, unique order/tracking number and date/status checks.                                                          |
| [Seeded row counts](screenshots/validation-output/row-count.png)       | Actual counts for all seven tables: 5 categories, 1,000 customers, 500 books, 10,000 orders, 30,000 order items, 8,000 payments and 8,000 deliveries. |
| [Validation PASS messages](screenshots/validation-output/validation-pass.png) | All 18 PASS notices: seed consistency, 16 constraint checks and preservation of historical price/address snapshots. Also shows ROLLBACK and successful query completion. |

The screenshots demonstrate the implemented structure, the presence of constraints, the actual seeded row counts and successful execution of the validation checks in the student's pgAdmin session. The original agent log remains available as separate execution evidence. ROLLBACK in the validation screenshot is intentional: it reverses temporary test changes while retaining the seeded data.

## Optional additional student evidence

The row-count and PASS-message screenshots have been supplied and reviewed. A screenshot of the five-order joined result may be added if useful for the final summary; it is already present in the original saved text log. A separate student execution log is also optional. Keep the original agent log unchanged.

Use the required student naming convention when preparing final upload files. Repository filenames here describe development evidence; the final LMS summary should link or refer to the selected evidence clearly.

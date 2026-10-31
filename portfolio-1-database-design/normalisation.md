# Normalisation: from an order record to 3NF

## Unnormalised starting point

A single sales record could contain customer name/email/address, order date, a repeated list of books (ISBN, title, category, current price, quantity, purchase price), payment details and delivery details. A repeated list makes individual books difficult to query and creates update, insertion and deletion anomalies.

## First normal form (1NF)

Use one value per field and move repeated books into individual OrderItem rows. Customer names and street addresses are treated as single values for this application's operations; city is separate for reporting. There are no author lists or multiple book columns in a row.

## Second normal form (2NF)

OrderItem has the composite key `(order_id, book_id)`. The quantity and price charged depend on the whole order/book pair. Book title, ISBN and current price depend only on book_id, so they belong in Book. Order date and customer depend only on order_id, so they belong in CustomerOrder. Other tables use single-column primary keys.

## Third normal form (3NF)

Remove dependencies between non-key attributes:

- Customer contact details belong in Customer, rather than being repeated on each order.
- Category name belongs in Category, rather than every Book row.
- Payment and Delivery are separate optional facts with their own identifiers and lifecycle.
- Order totals are calculated through a view, so a stored total cannot become inconsistent with its lines.

Principal functional dependencies are:

```text
category_id -> name
customer_id -> full_name, email, address_line, city, created_at
book_id -> category_id, isbn, title, author_name, unit_price, stock_quantity
order_id -> customer_id, ordered_at, status, delivery_address_line, delivery_city
(order_id, book_id) -> quantity, unit_price_at_purchase
payment_id -> order_id, reference, amount, method, paid_at
delivery_id -> order_id, tracking_number, status, dispatched_at, delivered_at
```

Unique category names, customer emails and ISBNs are alternate candidate keys. Payment order_id/reference and Delivery order_id/tracking_number are also alternate candidate keys. Under the stated business rules, non-key attributes depend on keys without partial or transitive dependencies, giving a 3NF design.

## Historical values and deliberate scope

The current customer address and an order's shipping address describe different facts: where the customer lives now versus where this order was addressed. Similarly, the current book price and the price charged on a particular order line differ in meaning. Keeping both preserves history; changing current data must not rewrite earlier orders.

One credited author name is stored per book because author profiles and multiple authors are outside scope. Repeated author-name text is not by itself a 3NF violation; no author identifier or author details introduce another dependency here. Add Author and BookAuthor tables if multi-author search or author profiles become requirements.

Normalisation alone cannot guarantee stock availability or correct payment workflows. These require transaction logic and concurrency controls in Portfolio 3.

-- Deterministic synthetic data; run once after 01-schema.sql.
BEGIN;
SET search_path TO bookmania, public;
INSERT INTO category(name) VALUES
('Technology'), ('Business'), ('Fiction'), ('Education'), ('Personal Development');

INSERT INTO customer(full_name, email, address_line, city, created_at)
SELECT 'Sample Customer ' || n, 'customer' || n || '@example.com',
       n || ' Example Street',
       (ARRAY['Lagos','Abuja','Ibadan','Enugu','Kano'])[1 + (n - 1) % 5],
       TIMESTAMPTZ '2026-01-01 09:00:00+01' + n * INTERVAL '1 minute'
FROM generate_series(1,1000) AS g(n);

-- EAN-13 check digit is calculated for each synthetic ISBN-shaped identifier.
WITH bases AS (
    SELECT n, '978' || lpad(n::text, 9, '0') AS base FROM generate_series(1,500) AS g(n)
), identifiers AS (
    SELECT n, base || ((10 - (
        SELECT SUM(substring(base FROM i FOR 1)::integer * CASE WHEN i % 2 = 0 THEN 3 ELSE 1 END)
        FROM generate_series(1,12) AS p(i)
    ) % 10) % 10)::text AS isbn FROM bases
)
INSERT INTO book(category_id, isbn, title, author_name, unit_price, stock_quantity)
SELECT 1 + (n - 1) % 5, isbn, 'Sample Book ' || lpad(n::text,3,'0'),
       'Sample Author ' || (1 + (n - 1) % 100),
       (1500 + (n % 40) * 250)::numeric(10,2), 100 + n % 50
FROM identifiers ORDER BY n;

INSERT INTO customer_order(customer_id, ordered_at, status, delivery_address_line, delivery_city)
SELECT c.customer_id,
       TIMESTAMPTZ '2026-02-01 09:00:00+01' + (n - 1) * INTERVAL '20 minutes',
       CASE WHEN n % 5 = 0 THEN 'pending' WHEN n % 5 = 1 THEN 'shipped' ELSE 'delivered' END,
       c.address_line, c.city
FROM generate_series(1,10000) AS g(n)
JOIN customer c ON c.customer_id = 1 + (n - 1) % 1000
ORDER BY n;

INSERT INTO order_item(order_id, book_id, quantity, unit_price_at_purchase)
SELECT o.order_id, b.book_id, 1 + (o.order_id + line.n) % 3, b.unit_price
FROM customer_order o CROSS JOIN generate_series(0,2) AS line(n)
JOIN book b ON b.book_id = 1 + ((o.order_id - 1) * 3 + line.n) % 500
ORDER BY o.order_id, line.n;

INSERT INTO payment(order_id, reference, amount, method, paid_at)
SELECT o.order_id, 'BM-PAY-' || lpad(o.order_id::text,6,'0'), t.total_amount,
       CASE WHEN o.order_id % 2 = 0 THEN 'card' ELSE 'bank_transfer' END,
       o.ordered_at + INTERVAL '5 minutes'
FROM customer_order o JOIN order_total t USING(order_id)
WHERE o.status <> 'pending' ORDER BY o.order_id;

INSERT INTO delivery(order_id, tracking_number, status, dispatched_at, delivered_at)
SELECT order_id, 'BM-TRACK-' || lpad(order_id::text,6,'0'),
       CASE WHEN status = 'delivered' THEN 'delivered' ELSE 'dispatched' END,
       ordered_at + INTERVAL '1 day',
       CASE WHEN status = 'delivered' THEN ordered_at + INTERVAL '3 days' ELSE NULL END
FROM customer_order WHERE status IN ('shipped','delivered') ORDER BY order_id;
COMMIT;
ANALYZE bookmania.category;
ANALYZE bookmania.customer;
ANALYZE bookmania.book;
ANALYZE bookmania.customer_order;
ANALYZE bookmania.order_item;
ANALYZE bookmania.payment;
ANALYZE bookmania.delivery;

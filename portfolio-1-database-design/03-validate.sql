-- All changes in constraint tests are rolled back. Any unexpected result aborts psql.
SET search_path TO bookmania, public;
SELECT version();
SELECT 'category' AS table_name, count(*) AS rows FROM category
UNION ALL SELECT 'customer', count(*) FROM customer
          UNION ALL SELECT 'book', count(*) FROM book
          UNION ALL SELECT 'customer_order', count(*) FROM customer_order
          UNION ALL SELECT 'order_item', count(*) FROM order_item
          UNION ALL SELECT 'payment', count(*) FROM payment
          UNION ALL SELECT 'delivery', count(*) FROM delivery;

DO $$
BEGIN
    IF (SELECT count(*) FROM category) <> 5 OR
       (SELECT count(*) FROM customer) <> 1000 OR
       (SELECT count(*) FROM book) <> 500 OR
       (SELECT count(*) FROM customer_order) <> 10000 OR
       (SELECT count(*) FROM order_item) <> 30000 OR
       (SELECT count(*) FROM payment) <> 8000 OR
       (SELECT count(*) FROM delivery) <> 8000 THEN
        RAISE EXCEPTION 'FAIL: unexpected seed counts';
END IF;
    IF EXISTS (SELECT 1 FROM payment p JOIN order_total t USING(order_id) WHERE p.amount <> t.total_amount)
       OR EXISTS (SELECT 1 FROM customer_order o LEFT JOIN order_total t USING(order_id) WHERE t.order_id IS NULL)
       OR EXISTS (SELECT 1 FROM customer_order o LEFT JOIN payment p USING(order_id)
                  WHERE (o.status = 'pending' AND p.order_id IS NOT NULL)
                     OR (o.status <> 'pending' AND p.order_id IS NULL))
       OR EXISTS (SELECT 1 FROM delivery d JOIN customer_order o USING(order_id) JOIN payment p USING(order_id)
                  WHERE d.dispatched_at < p.paid_at OR p.paid_at < o.ordered_at
                     OR (d.status = 'delivered') <> (o.status = 'delivered')) THEN
        RAISE EXCEPTION 'FAIL: inconsistent seed orders, payments or deliveries';
END IF;
    RAISE NOTICE 'PASS: expected row counts and seed business consistency';
END $$;

BEGIN;
-- Reusable helper compares the actual PostgreSQL SQLSTATE to the expected violation.
CREATE FUNCTION pg_temp.expect_error(label text, command text, expected_state text)
    RETURNS void LANGUAGE plpgsql AS $$
DECLARE actual_state text;
BEGIN
BEGIN
EXECUTE command;
EXCEPTION WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS actual_state = RETURNED_SQLSTATE;
END;
    IF actual_state IS DISTINCT FROM expected_state THEN
        RAISE EXCEPTION 'FAIL: % expected %, received %', label, expected_state, coalesce(actual_state,'no error');
END IF;
    RAISE NOTICE 'PASS: % (SQLSTATE %)', label, actual_state;
END $$;

SELECT pg_temp.expect_error('unique customer email',
                            'UPDATE customer SET email = ''customer1@example.com'' WHERE customer_id = 2', '23505');
SELECT pg_temp.expect_error('unique book ISBN',
                            'UPDATE book SET isbn = (SELECT isbn FROM book WHERE book_id = 1) WHERE book_id = 2', '23505');
SELECT pg_temp.expect_error('required book title',
                            'UPDATE book SET title = NULL WHERE book_id = 1', '23502');
SELECT pg_temp.expect_error('nonblank category name',
                            'UPDATE category SET name = '' '' WHERE category_id = 1', '23514');
SELECT pg_temp.expect_error('valid category foreign key',
                            'UPDATE book SET category_id = -1 WHERE book_id = 1', '23503');
SELECT pg_temp.expect_error('nonnegative stock',
                            'UPDATE book SET stock_quantity = -1 WHERE book_id = 1', '23514');
SELECT pg_temp.expect_error('nonnegative book price',
                            'UPDATE book SET unit_price = -1 WHERE book_id = 1', '23514');
SELECT pg_temp.expect_error('positive order quantity',
                            'UPDATE order_item SET quantity = 0 WHERE order_id = 1', '23514');
SELECT pg_temp.expect_error('nonnegative purchase price',
                            'UPDATE order_item SET unit_price_at_purchase = -1 WHERE order_id = 1', '23514');
SELECT pg_temp.expect_error('unique order and book pair',
                            'INSERT INTO order_item SELECT * FROM order_item WHERE order_id = 1 LIMIT 1', '23505');
SELECT pg_temp.expect_error('valid order status',
                            'UPDATE customer_order SET status = ''unknown'' WHERE order_id = 1', '23514');
SELECT pg_temp.expect_error('one payment per order',
                            'INSERT INTO payment(order_id,reference,amount,method,paid_at) SELECT order_id,''BM-DUPLICATE'',amount,method,paid_at FROM payment WHERE order_id = 1', '23505');
SELECT pg_temp.expect_error('positive payment amount',
                            'UPDATE payment SET amount = 0 WHERE order_id = 1', '23514');
SELECT pg_temp.expect_error('one delivery per order',
                            'INSERT INTO delivery(order_id,tracking_number,status,dispatched_at,delivered_at) SELECT order_id,''BM-DUPLICATE'',status,dispatched_at,delivered_at FROM delivery WHERE order_id = 1', '23505');
SELECT pg_temp.expect_error('valid delivery chronology',
                            'UPDATE delivery SET delivered_at = dispatched_at - interval ''1 day'' WHERE order_id = 2', '23514');
SELECT pg_temp.expect_error('preserve referenced customer',
                            'DELETE FROM customer WHERE customer_id = 1', '23503');

DO $$
DECLARE original_price numeric; original_address text;
BEGIN
SELECT unit_price_at_purchase INTO original_price FROM order_item WHERE order_id = 1 AND book_id = 1;
UPDATE book SET unit_price = unit_price + 100 WHERE book_id = 1;
IF (SELECT unit_price_at_purchase FROM order_item WHERE order_id = 1 AND book_id = 1) <> original_price THEN
        RAISE EXCEPTION 'FAIL: historical purchase price changed';
END IF;
SELECT delivery_address_line INTO original_address FROM customer_order WHERE order_id = 1;
UPDATE customer SET address_line = 'New Example Street' WHERE customer_id = 1;
IF (SELECT delivery_address_line FROM customer_order WHERE order_id = 1) <> original_address THEN
        RAISE EXCEPTION 'FAIL: historical order address changed';
END IF;
    RAISE NOTICE 'PASS: catalogue price and customer address changes preserve order snapshots';
END $$;
ROLLBACK;

SELECT o.order_id, c.full_name, o.status, t.total_amount, p.amount AS paid_amount,
       d.status AS delivery_status
FROM bookmania.customer_order o JOIN bookmania.customer c USING(customer_id)
                                JOIN bookmania.order_total t USING(order_id)
                                LEFT JOIN bookmania.payment p USING(order_id) LEFT JOIN bookmania.delivery d USING(order_id)
ORDER BY o.order_id LIMIT 5;

SELECT table_name, constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'bookmania' AND constraint_type IN ('PRIMARY KEY','FOREIGN KEY','UNIQUE','CHECK')
ORDER BY table_name, constraint_type, constraint_name;

-- In pgAdmin, execute PART 1, PART 2 and PART 3 separately, in the SAME tab.
-- PART 2 intentionally fails; do not omit PART 3 after the error.

-- PART 1: Changes are visible inside this transaction, but are not committed.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT bookmania.place_order(
    (SELECT customer_id FROM bookmania.customer WHERE email='portfolio3@example.com'),
    (SELECT book_id FROM bookmania.book WHERE isbn='9789999000002'), 2
) AS temporary_order_id;
SELECT b.title,b.stock_quantity,count(oi.order_id) AS order_lines
FROM bookmania.book b LEFT JOIN bookmania.order_item oi USING(book_id)
WHERE b.isbn='9789999000002' GROUP BY b.book_id;
-- Expected inside transaction: stock 3, order_lines 1.

-- PART 2: Execute this statement separately. An error here is expected.
DO $$ BEGIN RAISE EXCEPTION 'Intentional Portfolio 3 failure: roll back this transaction'; END $$;

-- PART 3: Execute separately AFTER the expected error.
ROLLBACK;
SELECT b.title,b.stock_quantity,count(oi.order_id) AS order_lines
FROM bookmania.book b LEFT JOIN bookmania.order_item oi USING(book_id)
WHERE b.isbn='9789999000002' GROUP BY b.book_id;
-- Expected after rollback: stock 5, order_lines 0; inserted order is also undone.

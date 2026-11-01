-- Run AFTER A COMMIT and B ROLLBACK, following the commit/rollback examples.
DO $$
DECLARE demo_customer integer;
BEGIN
    SELECT customer_id INTO demo_customer FROM bookmania.customer WHERE email='portfolio3@example.com';
    IF demo_customer IS NULL THEN RAISE EXCEPTION 'FAIL: run setup first'; END IF;
    IF (SELECT stock_quantity FROM bookmania.book WHERE isbn='9789999000001') IS DISTINCT FROM 3
       OR (SELECT count(*) FROM bookmania.order_item oi JOIN bookmania.book b USING(book_id)
           WHERE b.isbn='9789999000001' AND oi.quantity=2) <> 1 THEN
        RAISE EXCEPTION 'FAIL: committed order/stock incorrect';
    END IF;
    RAISE NOTICE 'PASS: committed order retained; stock 5 -> 3';

    IF (SELECT stock_quantity FROM bookmania.book WHERE isbn='9789999000002') IS DISTINCT FROM 5
       OR EXISTS (SELECT 1 FROM bookmania.order_item oi JOIN bookmania.book b USING(book_id)
                  WHERE b.isbn='9789999000002') THEN
        RAISE EXCEPTION 'FAIL: rollback did not restore stock/order lines';
    END IF;
    RAISE NOTICE 'PASS: rollback restored stock 5 and removed temporary order line';

    IF (SELECT stock_quantity FROM bookmania.book WHERE isbn='9789999000003') IS DISTINCT FROM 0
       OR (SELECT count(*) FROM bookmania.order_item oi JOIN bookmania.book b USING(book_id)
           WHERE b.isbn='9789999000003') <> 1
       OR (SELECT sum(oi.quantity) FROM bookmania.order_item oi JOIN bookmania.book b USING(book_id)
           WHERE b.isbn='9789999000003') IS DISTINCT FROM 1::bigint
       OR (SELECT count(*) FROM bookmania.customer_order WHERE customer_id=demo_customer) <> 2 THEN
        RAISE EXCEPTION 'FAIL: last-copy result or total demo orders incorrect';
    END IF;
    RAISE NOTICE 'PASS: exactly one last-copy sale; two demo orders total; no overselling or orphan rollback order';
END $$;

SELECT b.title,b.stock_quantity,count(oi.order_id) AS order_lines,
       COALESCE(sum(oi.quantity),0) AS copies_ordered
FROM bookmania.book b LEFT JOIN bookmania.order_item oi USING(book_id)
WHERE b.isbn IN ('9789999000001','9789999000002','9789999000003')
GROUP BY b.book_id ORDER BY b.isbn;

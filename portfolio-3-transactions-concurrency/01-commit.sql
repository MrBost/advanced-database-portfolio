-- Expected: one pending order for two copies, with stock 5 -> 3 after COMMIT.
BEGIN ISOLATION LEVEL READ COMMITTED;
SELECT bookmania.place_order(
    (SELECT customer_id FROM bookmania.customer WHERE email='portfolio3@example.com'),
    (SELECT book_id FROM bookmania.book WHERE isbn='9789999000001'), 2
) AS committed_order_id;
COMMIT;

SELECT b.title,b.stock_quantity,oi.order_id,oi.quantity,oi.unit_price_at_purchase,o.status
FROM bookmania.book b JOIN bookmania.order_item oi USING(book_id)
JOIN bookmania.customer_order o USING(order_id)
WHERE b.isbn='9789999000001';

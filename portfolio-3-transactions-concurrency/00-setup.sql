-- Run once after Portfolio 1 schema + seed, preferably in a fresh demo database.
-- Adds a dedicated synthetic customer and three books; no existing rows reset.
BEGIN;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM bookmania.customer WHERE email = 'portfolio3@example.com')
       OR EXISTS (SELECT 1 FROM bookmania.book WHERE isbn IN ('9789999000001','9789999000002','9789999000003')) THEN
        RAISE EXCEPTION 'Portfolio 3 fixtures already exist. Use the existing run state or a fresh demo database; setup does not reset data.';
    END IF;
END $$;

INSERT INTO bookmania.customer(full_name,email,address_line,city)
VALUES ('Portfolio 3 Demo Customer','portfolio3@example.com','3 Example Street','Lagos');

INSERT INTO bookmania.book(category_id,isbn,title,author_name,unit_price,stock_quantity)
VALUES
((SELECT min(category_id) FROM bookmania.category),'9789999000001','P3 Commit Demo','Demo Author',2000,5),
((SELECT min(category_id) FROM bookmania.category),'9789999000002','P3 Rollback Demo','Demo Author',2000,5),
((SELECT min(category_id) FROM bookmania.category),'9789999000003','P3 Last Copy Demo','Demo Author',2000,1);

-- One-book order placement: all changes belong to the caller's transaction.
CREATE FUNCTION bookmania.place_order(p_customer_id integer, p_book_id integer, p_quantity integer)
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE
    v_customer bookmania.customer%ROWTYPE;
    v_book bookmania.book%ROWTYPE;
    v_order_id integer;
BEGIN
    IF p_quantity IS NULL OR p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be positive';
    END IF;
    SELECT * INTO v_customer FROM bookmania.customer WHERE customer_id = p_customer_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Customer not found'; END IF;

    -- Lock first, then check the returned stock. A competing buyer waits here.
    SELECT * INTO v_book FROM bookmania.book WHERE book_id = p_book_id FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Book not found'; END IF;
    IF v_book.stock_quantity < p_quantity THEN
        RAISE EXCEPTION 'Insufficient stock: requested %, available %', p_quantity, v_book.stock_quantity;
    END IF;

    INSERT INTO bookmania.customer_order(customer_id,status,delivery_address_line,delivery_city)
    VALUES (p_customer_id,'pending',v_customer.address_line,v_customer.city)
    RETURNING order_id INTO v_order_id;
    INSERT INTO bookmania.order_item(order_id,book_id,quantity,unit_price_at_purchase)
    VALUES (v_order_id,p_book_id,p_quantity,v_book.unit_price);
    UPDATE bookmania.book SET stock_quantity = stock_quantity - p_quantity WHERE book_id = p_book_id;
    RETURN v_order_id;
END $$;
COMMIT;

SELECT isbn,title,stock_quantity FROM bookmania.book
WHERE isbn IN ('9789999000001','9789999000002','9789999000003') ORDER BY isbn;

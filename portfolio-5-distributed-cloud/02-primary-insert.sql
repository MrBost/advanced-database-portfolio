-- Run once on PRIMARY. Inserts only a dedicated synthetic catalogue record.
BEGIN;
DO $$
BEGIN
    IF pg_is_in_recovery() THEN RAISE EXCEPTION 'Connect to the primary for this script'; END IF;
    IF EXISTS (SELECT 1 FROM bookmania.book WHERE isbn='9789999500001') THEN
        RAISE EXCEPTION 'Replication demo book already exists. Rerun only the final SELECT to inspect it.';
    END IF;
END $$;
INSERT INTO bookmania.book(category_id,isbn,title,author_name,unit_price,stock_quantity)
VALUES ((SELECT category_id FROM bookmania.category WHERE name='Technology'),
        '9789999500001','BookMania Replication Demo','Demo Author',2500,7);
COMMIT;

SELECT book_id,isbn,title,unit_price,stock_quantity
FROM bookmania.book WHERE isbn='9789999500001';

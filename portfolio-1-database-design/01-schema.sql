-- Run against a dedicated empty BookMania database. No destructive reset is included.
BEGIN;
CREATE SCHEMA bookmania;
SET search_path TO bookmania, public;

CREATE TABLE category (
    category_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(80) NOT NULL UNIQUE CHECK (btrim(name) <> '')
);

CREATE TABLE customer (
    customer_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name varchar(120) NOT NULL CHECK (btrim(full_name) <> ''),
    email varchar(254) NOT NULL UNIQUE,
    address_line varchar(200) NOT NULL CHECK (btrim(address_line) <> ''),
    city varchar(80) NOT NULL CHECK (btrim(city) <> ''),
    created_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT customer_email_format CHECK (
        email = lower(email) AND email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
    )
);

CREATE TABLE book (
    book_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id integer NOT NULL REFERENCES category(category_id),
    isbn varchar(13) NOT NULL UNIQUE CHECK (isbn ~ '^[0-9]{13}$'),
    title varchar(200) NOT NULL CHECK (btrim(title) <> ''),
    author_name varchar(120) NOT NULL CHECK (btrim(author_name) <> ''),
    unit_price numeric(10,2) NOT NULL CHECK (unit_price BETWEEN 0 AND 99999999.99),
    stock_quantity integer NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE customer_order (
    order_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customer(customer_id),
    ordered_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status varchar(15) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled')),
    delivery_address_line varchar(200) NOT NULL CHECK (btrim(delivery_address_line) <> ''),
    delivery_city varchar(80) NOT NULL CHECK (btrim(delivery_city) <> '')
);

CREATE TABLE order_item (
    order_id integer NOT NULL REFERENCES customer_order(order_id),
    book_id integer NOT NULL REFERENCES book(book_id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price_at_purchase numeric(10,2) NOT NULL
        CHECK (unit_price_at_purchase BETWEEN 0 AND 99999999.99),
    PRIMARY KEY (order_id, book_id)
);

CREATE TABLE payment (
    payment_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id integer NOT NULL UNIQUE REFERENCES customer_order(order_id),
    reference varchar(80) NOT NULL UNIQUE CHECK (btrim(reference) <> ''),
    amount numeric(12,2) NOT NULL CHECK (amount BETWEEN 0.01 AND 9999999999.99),
    method varchar(20) NOT NULL CHECK (method IN ('card', 'bank_transfer')),
    paid_at timestamptz NOT NULL
);

CREATE TABLE delivery (
    delivery_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id integer NOT NULL UNIQUE REFERENCES customer_order(order_id),
    tracking_number varchar(80) NOT NULL UNIQUE CHECK (btrim(tracking_number) <> ''),
    status varchar(15) NOT NULL CHECK (status IN ('dispatched', 'delivered')),
    dispatched_at timestamptz NOT NULL,
    delivered_at timestamptz,
    CONSTRAINT delivery_dates CHECK (
        (status = 'dispatched' AND delivered_at IS NULL) OR
        (status = 'delivered' AND delivered_at IS NOT NULL AND delivered_at >= dispatched_at)
    )
);

-- Derived totals avoid maintaining duplicate order-total values.
CREATE VIEW order_total AS
SELECT order_id, SUM(quantity * unit_price_at_purchase) AS total_amount
FROM order_item GROUP BY order_id;
COMMIT;

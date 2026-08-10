-- Illustrative Aurora-side DDL after SCT. Not a full schema dump.

CREATE TABLE customers (
    customer_id   bigint PRIMARY KEY,
    external_ref  varchar(64) NOT NULL UNIQUE,
    display_name  text NOT NULL,
    status        varchar(16) NOT NULL DEFAULT 'active',
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    order_id      bigint PRIMARY KEY,
    customer_id   bigint NOT NULL REFERENCES customers(customer_id),
    order_status  varchar(24) NOT NULL,
    currency      char(3) NOT NULL DEFAULT 'USD',
    amount_cents  bigint NOT NULL CHECK (amount_cents >= 0),
    placed_at     timestamptz NOT NULL,
    oracle_rowid  varchar(32)  -- keep during dual-write validation, drop later
);

CREATE INDEX orders_customer_placed_idx ON orders (customer_id, placed_at DESC);

-- Bump sequences after DMS full load (example)
-- SELECT setval('customers_customer_id_seq', (SELECT max(customer_id) FROM customers));
-- SELECT setval('orders_order_id_seq', (SELECT max(order_id) FROM orders));

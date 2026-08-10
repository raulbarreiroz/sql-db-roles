-- Row-count + spot checksum helpers used during cutover.

-- 1) Counts (run on both sides; compare in a spreadsheet)
SELECT 'customers' AS table_name, count(*) FROM customers
UNION ALL
SELECT 'orders', count(*) FROM orders;

-- 2) Lightweight checksum for a PK window
SELECT
    count(*) AS n,
    sum(amount_cents) AS sum_amount,
    md5(string_agg(order_id::text || ':' || amount_cents::text, ',' ORDER BY order_id)) AS fingerprint
FROM orders
WHERE order_id BETWEEN 100000 AND 110000;

-- 3) Orphan check after FK enable
SELECT o.order_id
FROM orders o
LEFT JOIN customers c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
LIMIT 50;

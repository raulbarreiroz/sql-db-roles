-- Ten slow-ish queries we kept hitting in the CRM + logs lab.
-- Run each block twice: once BEFORE applying perf/indexes_after.sql, once AFTER.
-- Capture plans with: EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)

\timing on

-- Q1: open opportunities for a rep (seq scan without owner+stage index)
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, name, amount, stage
FROM opportunities
WHERE owner_id = 1 AND stage NOT IN ('closed_won', 'closed_lost');

-- Q2: closed-won in a date range
EXPLAIN (ANALYZE, BUFFERS)
SELECT account_id, sum(amount)
FROM opportunities
WHERE stage = 'closed_won'
  AND close_date BETWEEN '2024-10-01' AND '2024-12-31'
GROUP BY account_id;

-- Q3: lead lookup by email (often missing index on contact_email)
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM leads
WHERE lower(contact_email) = lower('diego@nortetech.example');

-- Q4: account list for a region via owner join
EXPLAIN (ANALYZE, BUFFERS)
SELECT a.legal_name, r.full_name
FROM accounts a
JOIN sales_reps r ON r.id = a.owner_id
WHERE r.region = 'LATAM';

-- Q5: recent error logs for one service (partition prune + filter)
EXPLAIN (ANALYZE, BUFFERS)
SELECT logged_at, message
FROM app_logs
WHERE service = 'billing-api'
  AND level = 'error'
  AND logged_at >= '2025-02-01'
  AND logged_at <  '2025-03-01'
ORDER BY logged_at DESC
LIMIT 50;

-- Q6: jsonb containment on payload
EXPLAIN (ANALYZE, BUFFERS)
SELECT id, message
FROM app_logs
WHERE logged_at >= '2025-02-01'
  AND logged_at <  '2025-03-01'
  AND payload @> '{"http_status": 500}';

-- Q7: activities for an opportunity ordered by time
EXPLAIN (ANALYZE, BUFFERS)
SELECT activity_type, notes, happened_at
FROM activities
WHERE opportunity_id = 4
ORDER BY happened_at DESC;

-- Q8: monthly revenue fact filtered by region
EXPLAIN (ANALYZE, BUFFERS)
SELECT year_month, sum(revenue)
FROM sales_fact_monthly
WHERE region = 'NA'
  AND year_month >= '2024-01-01'
GROUP BY year_month
ORDER BY year_month;

-- Q9: contacts primary-only for an account
EXPLAIN (ANALYZE, BUFFERS)
SELECT first_name, last_name, email
FROM contacts
WHERE account_id = 2 AND is_primary;

-- Q10: count leads by source last 60 days
EXPLAIN (ANALYZE, BUFFERS)
SELECT source, count(*)
FROM leads
WHERE created_at >= now() - interval '60 days'
GROUP BY source
ORDER BY count(*) DESC;

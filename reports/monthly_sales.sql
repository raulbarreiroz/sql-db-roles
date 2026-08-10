-- Monthly sales pack. Swap the month filter at the top as needed.

\set report_month '''2024-11-01'''

-- 1) Won revenue by rep for the month (from opportunities)
SELECT
    r.full_name,
    r.region,
    count(*) FILTER (WHERE o.stage = 'closed_won') AS deals_won,
    coalesce(sum(o.amount) FILTER (WHERE o.stage = 'closed_won'), 0) AS won_revenue,
    coalesce(sum(o.amount) FILTER (WHERE o.stage = 'closed_lost'), 0) AS lost_revenue
FROM sales_reps r
LEFT JOIN opportunities o
    ON o.owner_id = r.id
   AND date_trunc('month', o.close_date)::date = :report_month::date
WHERE r.is_active
GROUP BY r.id, r.full_name, r.region
ORDER BY won_revenue DESC;

-- 2) Pipeline still open at month-end (snapshot-ish)
SELECT
    o.stage,
    count(*) AS opps,
    sum(o.amount) AS pipeline_amount
FROM opportunities o
WHERE o.stage NOT IN ('closed_won', 'closed_lost')
GROUP BY o.stage
ORDER BY pipeline_amount DESC;

-- 3) Region scoreboard using the pre-built fact table
SELECT
    f.region,
    sum(f.deals_won) AS deals,
    sum(f.revenue) AS revenue
FROM sales_fact_monthly f
WHERE f.year_month = :report_month::date
GROUP BY f.region
ORDER BY revenue DESC;

-- 4) Conversion: leads created in month → won later (simple view)
SELECT
    date_trunc('month', l.created_at)::date AS lead_month,
    count(*) AS leads_created,
    count(*) FILTER (WHERE l.status = 'won') AS marked_won,
    round(
        100.0 * count(*) FILTER (WHERE l.status = 'won') / nullif(count(*), 0),
        1
    ) AS win_pct
FROM leads l
GROUP BY 1
ORDER BY 1;

-- 5) Top accounts by closed-won ARR (trailing 90 days from report month)
SELECT
    a.legal_name,
    r.full_name AS owner,
    sum(o.amount) AS trailing_won
FROM opportunities o
JOIN accounts a ON a.id = o.account_id
JOIN sales_reps r ON r.id = o.owner_id
WHERE o.stage = 'closed_won'
  AND o.close_date >= (:report_month::date - interval '90 days')
  AND o.close_date < (:report_month::date + interval '1 month')
GROUP BY a.legal_name, r.full_name
ORDER BY trailing_won DESC
LIMIT 10;

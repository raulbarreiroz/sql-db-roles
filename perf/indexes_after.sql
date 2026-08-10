-- Apply after capturing "before" plans from explain_before_after.sql
-- Prefer CONCURRENTLY in shared environments; lab can use regular CREATE INDEX.

BEGIN;

-- Q1 / Q2
CREATE INDEX IF NOT EXISTS opportunities_owner_open_idx
    ON opportunities (owner_id)
    WHERE stage NOT IN ('closed_won', 'closed_lost');

CREATE INDEX IF NOT EXISTS opportunities_won_close_idx
    ON opportunities (close_date, account_id)
    WHERE stage = 'closed_won';

-- Q3 — expression index matches lower(email) lookups
CREATE INDEX IF NOT EXISTS leads_email_lower_idx
    ON leads (lower(contact_email));

-- Q4 — helps the join filter from sales_reps.region
CREATE INDEX IF NOT EXISTS sales_reps_region_idx
    ON sales_reps (region)
    WHERE is_active;

-- Q6 — GIN on jsonb payload (partitioned parent gets it on children)
CREATE INDEX IF NOT EXISTS app_logs_payload_gin
    ON app_logs USING gin (payload jsonb_path_ops);

-- Q7
CREATE INDEX IF NOT EXISTS activities_opp_time_idx
    ON activities (opportunity_id, happened_at DESC);

-- Q8
CREATE INDEX IF NOT EXISTS sales_fact_region_month_idx
    ON sales_fact_monthly (region, year_month);

-- Q9
CREATE INDEX IF NOT EXISTS contacts_account_primary_idx
    ON contacts (account_id)
    WHERE is_primary;

-- Q10
CREATE INDEX IF NOT EXISTS leads_created_source_idx
    ON leads (created_at, source);

COMMIT;

ANALYZE opportunities;
ANALYZE leads;
ANALYZE accounts;
ANALYZE sales_reps;
ANALYZE activities;
ANALYZE sales_fact_monthly;
ANALYZE app_logs;

-- Lightweight CRM for a small B2B sales team.
-- Intentionally normalized enough to practice joins, not enterprise-grade.

BEGIN;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE sales_reps (
    id          serial PRIMARY KEY,
    full_name   text NOT NULL,
    email       citext,  -- may fail if citext missing; fallback below
    hire_date   date NOT NULL DEFAULT CURRENT_DATE,
    region      text NOT NULL CHECK (region IN ('NA', 'LATAM', 'EMEA', 'APAC')),
    is_active   boolean NOT NULL DEFAULT true
);

-- citext is nice but not always installed in student environments
DO $$
BEGIN
    CREATE EXTENSION IF NOT EXISTS citext;
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'citext unavailable, using text for email';
END$$;

ALTER TABLE sales_reps
    ALTER COLUMN email TYPE text;

ALTER TABLE sales_reps
    ADD CONSTRAINT sales_reps_email_uniq UNIQUE (email);

CREATE TABLE accounts (
    id            serial PRIMARY KEY,
    legal_name    text NOT NULL,
    trade_name    text,
    industry      text,
    website       text,
    country_code  char(2) NOT NULL DEFAULT 'US',
    owner_id      integer REFERENCES sales_reps(id),
    created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE contacts (
    id          serial PRIMARY KEY,
    account_id  integer NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    first_name  text NOT NULL,
    last_name   text NOT NULL,
    email       text,
    phone       text,
    title       text,
    is_primary  boolean NOT NULL DEFAULT false
);

CREATE TABLE leads (
    id            serial PRIMARY KEY,
    company_name  text NOT NULL,
    contact_email text,
    status        text NOT NULL DEFAULT 'new'
                  CHECK (status IN ('new', 'qualified', 'meeting', 'won', 'lost')),
    source        text,  -- webinar, inbound, cold_call, partner
    owner_id      integer REFERENCES sales_reps(id),
    estimated_arr numeric(12,2),
    created_at    timestamptz NOT NULL DEFAULT now(),
    converted_account_id integer REFERENCES accounts(id)
);

CREATE TABLE opportunities (
    id            serial PRIMARY KEY,
    account_id    integer NOT NULL REFERENCES accounts(id),
    owner_id      integer NOT NULL REFERENCES sales_reps(id),
    name          text NOT NULL,
    stage         text NOT NULL DEFAULT 'discovery'
                  CHECK (stage IN ('discovery', 'proposal', 'negotiation', 'closed_won', 'closed_lost')),
    amount        numeric(12,2) NOT NULL CHECK (amount >= 0),
    close_date    date,
    created_at    timestamptz NOT NULL DEFAULT now(),
    updated_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE activities (
    id               serial PRIMARY KEY,
    opportunity_id   integer REFERENCES opportunities(id) ON DELETE SET NULL,
    lead_id          integer REFERENCES leads(id) ON DELETE SET NULL,
    rep_id           integer NOT NULL REFERENCES sales_reps(id),
    activity_type    text NOT NULL CHECK (activity_type IN ('call', 'email', 'meeting', 'note')),
    notes            text,
    happened_at      timestamptz NOT NULL DEFAULT now()
);

-- Soft denormalized monthly rollup target for reporting practice
CREATE TABLE sales_fact_monthly (
    year_month    date NOT NULL, -- first day of month
    rep_id        integer NOT NULL REFERENCES sales_reps(id),
    region        text NOT NULL,
    deals_won     integer NOT NULL DEFAULT 0,
    revenue       numeric(14,2) NOT NULL DEFAULT 0,
    PRIMARY KEY (year_month, rep_id)
);

CREATE INDEX idx_opps_owner_stage ON opportunities (owner_id, stage);
CREATE INDEX idx_opps_close_date ON opportunities (close_date)
    WHERE stage IN ('closed_won', 'closed_lost');
CREATE INDEX idx_leads_status ON leads (status);
CREATE INDEX idx_accounts_owner ON accounts (owner_id);

COMMIT;

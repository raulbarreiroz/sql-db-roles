-- Application / audit log table split by month.
-- Parent is never queried directly in prod without a date filter.

BEGIN;

CREATE TABLE app_logs (
    id          bigserial,
    logged_at   timestamptz NOT NULL DEFAULT now(),
    service     text NOT NULL,
    level       text NOT NULL CHECK (level IN ('debug', 'info', 'warn', 'error')),
    trace_id    uuid,
    message     text NOT NULL,
    payload     jsonb,
    PRIMARY KEY (id, logged_at)
) PARTITION BY RANGE (logged_at);

-- Three months ahead is enough for the lab; automate the rest with pg_partman or a cron job.
CREATE TABLE app_logs_2025_01 PARTITION OF app_logs
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE app_logs_2025_02 PARTITION OF app_logs
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');

CREATE TABLE app_logs_2025_03 PARTITION OF app_logs
    FOR VALUES FROM ('2025-03-01') TO ('2025-04-01');

CREATE TABLE app_logs_2025_04 PARTITION OF app_logs
    FOR VALUES FROM ('2025-04-01') TO ('2025-05-01');

-- Default catch-all so inserts outside the window don't blow up during demos
CREATE TABLE app_logs_default PARTITION OF app_logs DEFAULT;

-- Local indexes (created on parent → applied to partitions)
CREATE INDEX app_logs_service_logged_idx ON app_logs (service, logged_at DESC);
CREATE INDEX app_logs_level_idx ON app_logs (level) WHERE level IN ('warn', 'error');
CREATE INDEX app_logs_trace_idx ON app_logs (trace_id) WHERE trace_id IS NOT NULL;

COMMIT;

-- Optional: attach a concurrent index later without locking the parent hard
-- CREATE INDEX ON ONLY app_logs (message text_pattern_ops);
-- CREATE INDEX CONCURRENTLY app_logs_2025_01_msg_idx ON app_logs_2025_01 (message text_pattern_ops);
-- ALTER INDEX app_logs_message_idx ATTACH PARTITION app_logs_2025_01_msg_idx;

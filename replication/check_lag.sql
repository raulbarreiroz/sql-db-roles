-- Run on primary unless noted.

-- Who is connected and how far behind?
SELECT
    pid,
    usename,
    application_name,
    client_addr,
    state,
    sync_state,
    write_lag,
    flush_lag,
    replay_lag
FROM pg_stat_replication
ORDER BY client_addr;

-- Slot health (restart_lsn falling behind = WAL retention risk)
SELECT
    slot_name,
    slot_type,
    active,
    restart_lsn,
    confirmed_flush_lsn,
    pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn) AS bytes_retained
FROM pg_replication_slots;

-- On the standby: is recovery still going?
-- SELECT pg_is_in_recovery(), now() - pg_last_xact_replay_timestamp() AS replay_delay;

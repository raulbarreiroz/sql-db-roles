# PITR checklist (Aurora PostgreSQL / self-managed Postgres)

Use this before declaring the migration "safe to delete Oracle backups".

## Prerequisites

- [ ] Automated backups enabled (Aurora: backup retention ≥ 7 days; prefer 14 during migration).
- [ ] For self-managed: `archive_mode = on` and a tested `archive_command` writing to durable storage.
- [ ] Base backup completed **before** any recovery target you care about.
- [ ] Named restore point created at cutover: `SELECT pg_create_restore_point('post_oracle_cutover');`

## Self-managed restore drill

1. Provision a new data directory; restore the base backup.
2. Configure recovery:

```conf
restore_command = 'cp /mnt/wal-archive/%f %p'
recovery_target_time = '2025-03-16 02:07:00+00'
recovery_target_action = 'promote'
```

Or by name:

```conf
restore_command = 'cp /mnt/wal-archive/%f %p'
recovery_target_name = 'post_oracle_cutover'
recovery_target_action = 'promote'
```

3. Start Postgres; confirm it stops at the target and promotes.
4. Run `migration/validation_checks.sql` against the restored instance.
5. Record wall-clock time to usable state.

## Aurora notes

- [ ] Practice restore to a **new** cluster from a backup + PITR timestamp in the console/CLI.
- [ ] Verify security groups / parameter groups on the restored cluster.
- [ ] Confirm Backtrack window (if enabled) vs PITR — they solve different problems.
- [ ] Document who can click "restore" in the account (break-glass role).

## Pass criteria

- [ ] Restored data matches expected cutover fingerprint for sample PK ranges.
- [ ] Time-to-recover ≤ agreed RTO.
- [ ] Runbook updated with actual commands that worked (not aspirational ones).

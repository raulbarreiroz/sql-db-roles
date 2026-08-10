# Oracle → Aurora PostgreSQL (zero-downtime-ish) migration runbook

Audience: DBA + app owners cutting over a mid-size OLTP schema (~800 GB) to Amazon Aurora PostgreSQL.
"Zero downtime" here means **seconds of write freeze**, not magic. Reads can stay on Oracle until DNS flips.

## 0. Decisions locked before kickoff

- Target: Aurora PostgreSQL 15.x (compatible parameter group already reviewed).
- CDC tool: AWS DMS (full load + CDC) **or** Oracle GoldenGate → Kafka → custom loader. This runbook assumes **DMS**.
- Cutover window: Sunday 02:00–04:00 local, change ticket opened Friday.
- Rollback: keep Oracle primary writable until T+48h; Aurora stays writable after cutover but apps can point back if we declare failure within 2h.

## 1. Schema conversion (T-21 days)

1. Run AWS SCT against Oracle, export assessment.
2. Hand-fix the usual landmines:
   - `NUMBER` without precision → `numeric` (not blindly `bigint`)
   - `DATE` (Oracle) → `timestamp` vs `date` — pick per column
   - `SYS_REFCURSOR` packages → application rewrite
   - Sequences: map `NEXTVAL` usage; recreate with `INCREMENT` matching Oracle cache behavior if apps care
3. Apply DDL to an empty Aurora cluster (`migration/oracle_to_aurora_ddl.sql` is a trimmed example).
4. Diff object counts: tables, indexes, FKs, views.

## 2. Initial load (T-14 → T-3)

1. Create DMS endpoints (Oracle source with `archive log` retention ≥ 7 days).
2. Full load task, parallel by large tables (hash on PK ranges where possible).
3. Validate row counts + checksum samples (`migration/validation_checks.sql`).
4. Enable CDC; leave it running. Lag target: **< 5 seconds** steady state.

## 3. Rehearsal cutover (T-7)

Dry-run on a clone:

1. Quiesce writers on Oracle (app feature flag).
2. Wait for DMS CDC lag = 0.
3. Stop DMS task.
4. Flip connection string on staging apps → Aurora.
5. Run smoke tests + row count parity.
6. Rollback practice: flip back to Oracle, resume CDC or rebuild.

Record timings. If full load + CDC catch-up > 90 minutes for the big tables, split the wave.

## 4. Production cutover

```
T-60m  Freeze noncritical batch jobs
T-30m  Announce maintenance; disable Oracle job scheduler
T-10m  Feature flag: writes → drain / queue
T-5m   Confirm DMS `CDCLatencySource` ≈ 0
T-0    Stop writers; final CDC apply; stop DMS
T+2m   SELECT pg_create_restore_point('post_oracle_cutover');
T+3m   Flip secrets / DNS / RDS proxy target to Aurora
T+5m   Enable writers; watch error budgets
T+30m  Compare checksums for top 20 tables
T+2h   Go / no-go for keeping Aurora as SoT
```

## 5. Post-cutover

- Rebuild stats: `ANALYZE;` on hot tables (or `vacuumdb --analyze-only`).
- Recreate extension-backed features (pg_trgm, pgcrypto) if SCT skipped them.
- Turn on Aurora backtrack / PITR window (see `migration/pitr_checklist.md`).
- Decommission DMS after T+7 days of clean metrics.

## Failure modes we actually hit in rehearsal

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| CDC lag climbs | Oracle UNDO / archivelog gap | Extend retention; pause heavy ETL |
| FK violations on apply | Load order / disabled FKs | Defer FKs until catch-up, then validate |
| Sequences collide | Apps insert explicit IDs | Set sequence > max(id) on Aurora |

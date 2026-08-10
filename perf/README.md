# Perf lab

1. Load CRM schema from the junior branch (or your own copy).
2. Create partitioned logs: `psql -f perf/partition_app_logs.sql`
3. Stuff `app_logs` with a few hundred thousand rows if you want realistic timings.
4. Run `perf/explain_before_after.sql`, save the output.
5. Apply `perf/indexes_after.sql`, `ANALYZE`, re-run step 4.

Look for: Seq Scan → Index Scan / Bitmap Heap Scan, and lower `shared read` counts.

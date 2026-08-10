# Citus sharding notes

Lab assumptions: 1 coordinator + 2 workers, Citus 12.x on Postgres 15.

## Why tenant_id everywhere

Joins across distributed tables only stay local when the distribution columns match **and** tables are colocated. Putting `tenant_id` on `invoice_lines` feels redundant until you watch a cross-shard join melt the coordinator.

## Useful checks

```sql
SELECT * FROM citus_tables;
SELECT * FROM citus_shards WHERE table_name = 'invoices'::regclass;
EXPLAIN SELECT * FROM invoices WHERE tenant_id = '…';
```

Single-tenant filters should show a one-shard plan.

## App habits that matter

- Always include `tenant_id` in WHERE clauses (RLS helps enforce this).
- Avoid multi-tenant `ORDER BY issued_on LIMIT 50` without a tenant filter — that fans out.
- Reference data (`plan_catalog`) stays small on purpose.

See `citus_tenant_schema.sql` for the distribute/reference calls.

# Reports

`monthly_sales.sql` is meant to be run interactively in `psql`.

```bash
psql -U postgres -d northwind_crm -v report_month='2024-11-01' -f reports/monthly_sales.sql
```

If `\set` bothers you, just replace `:report_month` with a literal date.

# CRM lab setup (PostgreSQL)

Quick path I used on a laptop Postgres 16 install.

## 1. Create the database

```bash
createdb -U postgres northwind_crm
psql -U postgres -d northwind_crm -f schema/01_crm_schema.sql
psql -U postgres -d northwind_crm -f schema/02_seed.sql
```

If you hit auth errors on Windows, check `pg_hba.conf` and use the password from the installer.

## 2. Excel → PostgreSQL (the messy part)

Sales people usually dump leads from Excel as `.xlsx`. Postgres wants CSV.

1. Open the sheet, keep headers in row 1.
2. File → Save As → CSV UTF-8 (`*.csv`).
3. Watch for:
   - dates like `03/15/2024` vs `15/03/2024`
   - empty cells that become empty strings (not NULL)
   - commas inside company names (Excel already quotes them; leave them alone)

### Option A — Python helper

```bash
pip install psycopg2-binary
python schema/import_excel_csv.py --csv ./data/leads_export.csv --table leads
```

The script trims whitespace, turns blank strings into NULL, and uses `COPY` under the hood.

### Option B — plain psql

```bash
psql -U postgres -d northwind_crm -c "\copy leads(company_name, contact_email, status, source, owner_id, created_at) FROM 'C:/tmp/leads_export.csv' WITH (FORMAT csv, HEADER true, NULL '')"
```

`\copy` runs on the client, so the path is local to your machine. Server-side `COPY` needs a path the postgres OS user can read.

## 3. Sanity checks

```sql
SELECT count(*) FROM accounts;
SELECT status, count(*) FROM leads GROUP BY 1;
```

Then open `reports/monthly_sales.sql` and run the queries for the month you care about.

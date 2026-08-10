#!/usr/bin/env python3
"""Load a CSV exported from Excel into the CRM leads table.

I kept this intentionally boring: no pandas, just csv + psycopg2.
Works with the columns we documented in SETUP.md.
"""

from __future__ import annotations

import argparse
import csv
import os
import sys
from pathlib import Path

try:
    import psycopg2
    from psycopg2.extras import execute_values
except ImportError:
    print("Install psycopg2-binary first: pip install psycopg2-binary", file=sys.stderr)
    raise SystemExit(1)


ALLOWED_TABLES = {
    "leads": (
        "company_name",
        "contact_email",
        "status",
        "source",
        "owner_id",
        "estimated_arr",
        "created_at",
    ),
}


def blank_to_none(value: str | None):
    if value is None:
        return None
    cleaned = value.strip()
    return cleaned if cleaned else None


def load_rows(csv_path: Path, columns: tuple[str, ...]):
    with csv_path.open(newline="", encoding="utf-8-sig") as fh:
        reader = csv.DictReader(fh)
        missing = [c for c in columns if c not in (reader.fieldnames or [])]
        if missing:
            raise SystemExit(f"CSV missing columns: {', '.join(missing)}")

        rows = []
        for i, raw in enumerate(reader, start=2):
            row = [blank_to_none(raw.get(col)) for col in columns]
            if row[0] is None:
                print(f"skipping line {i}: company_name empty")
                continue
            rows.append(tuple(row))
        return rows


def main() -> None:
    parser = argparse.ArgumentParser(description="Excel CSV → Postgres loader")
    parser.add_argument("--csv", required=True, type=Path)
    parser.add_argument("--table", default="leads", choices=sorted(ALLOWED_TABLES))
    parser.add_argument(
        "--dsn",
        default=os.environ.get("DATABASE_URL", "dbname=northwind_crm user=postgres"),
    )
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    columns = ALLOWED_TABLES[args.table]
    rows = load_rows(args.csv, columns)
    print(f"parsed {len(rows)} rows from {args.csv}")

    if args.dry_run or not rows:
        return

    cols_sql = ", ".join(columns)
    sql = f"INSERT INTO {args.table} ({cols_sql}) VALUES %s"

    with psycopg2.connect(args.dsn) as conn:
        with conn.cursor() as cur:
            execute_values(cur, sql, rows, page_size=200)
        conn.commit()

    print(f"inserted into {args.table}")


if __name__ == "__main__":
    main()

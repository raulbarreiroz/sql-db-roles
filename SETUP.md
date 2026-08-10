# Setup — Zero-downtime migration + Citus (senior)

Runbook Oracle → Aurora PostgreSQL multi-región, sharding Citus y checklist PITR.

## Requisitos
- Acceso de lectura a los markdown/SQL (no requiere cluster real para estudiar el flujo)
- Opcional: Aurora PostgreSQL / Citus lab para ejecutar los scripts

## Cómo recorrer el lab

1. Lee el runbook completo:
   ```bash
   # abre en el editor
   migration/runbook.md
   ```
2. Revisa DDL de destino:
   ```bash
   psql -f migration/oracle_to_aurora_ddl.sql   # contra un Postgres de prueba
   ```
3. Validaciones post-cutover:
   ```bash
   psql -f migration/validation_checks.sql
   ```
4. Checklist PITR: `migration/pitr_checklist.md`
5. Sharding: aplica ejemplos en `sharding/` sobre un cluster Citus (o léelos como referencia).

## Qué validar
- Orden de pasos zero-downtime (shadow writes → backfill → cutover).
- Que los checks de validación cubran conteos y checksums.
- Plan PITR (WAL archiving / retention).

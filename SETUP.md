# Setup — Logs perf + replication (semi-senior)

Scripts SQL para particionar logs, índices y análisis EXPLAIN; más notas de replicación maestro-esclavo.

## Requisitos
- PostgreSQL 14+ (local o cloud)
- `psql`

## Preparar DB

```bash
createdb -U postgres logs_lab
psql -U postgres -d logs_lab -f perf/partition_app_logs.sql
```

## Cómo probar rendimiento

```bash
# 1) Explicar queries lentas (antes)
psql -U postgres -d logs_lab -f perf/explain_before_after.sql

# 2) Crear índices
psql -U postgres -d logs_lab -f perf/indexes_after.sql

# 3) Volver a correr EXPLAIN y comparar buffers/tiempo
psql -U postgres -d logs_lab -f perf/explain_before_after.sql
```

## Replicación
Sigue `replication/README.md` para configurar streaming replication (primary/replica) en un lab.

Detalle adicional en `perf/README.md`.

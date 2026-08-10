# SQL / DB Admin - Semi Senior

## Definition
Optimiza el rendimiento de consultas analizando planes de ejecución, diseña esquemas normalizados/desnormalizados, implementa replicación y maneja usuarios/permisos en bases de datos cloud.

## Specific Project
Replicación maestro-esclavo con particionamiento por rango (fechas) para una tabla de 500M de registros de logs, más optimización de 10 consultas críticas que tardan > 5s.

## Core Concepts
EXPLAIN (ANALYZE, BUFFERS), índices parciales y compuestos, particionamiento (RANGE/LIST), replicación streaming (WAL sender/receiver), VACUUM y ANALYZE, gestión de deadlocks, AWS RDS Performance Insights / Azure Query Performance Insight.

## Recommended Modern Technologies
Aurora PostgreSQL, Redis Stack, TimescaleDB, Citus, AWS DMS, Percona Monitoring (PMM).

# SQL / DB Admin - Senior

## Definition
Arquitecta bases de datos distribuidas (sharding, multi-region), lidera migraciones con cero downtime, selecciona el motor adecuado (OLTP vs OLAP, NoSQL específico) y gestiona costos de almacenamiento y computación en la nube a gran escala.

## Specific Project
Migración zero-downtime de una base de datos on-premise (Oracle) a Aurora PostgreSQL multi-región (activo-activo) con sharding horizontal usando Citus y backups PITR.

## Core Concepts
Sharding (hash/range distribuido), Citus (distributed tables, reference tables), Multi-region (replicación síncrona/asíncrona, latencia), Migraciones online (gh-ost / pt-online-schema-change), PITR (WAL archiving), FinOps de almacenamiento (tiering a S3/Glacier), IAM y KMS para encriptación.

## Recommended Modern Technologies
CockroachDB o YugabyteDB, AlloyDB, Snowflake o BigQuery, Neon, FerretDB, Vault, S3 Express.

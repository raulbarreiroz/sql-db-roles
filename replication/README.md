# Streaming replication (primary → hot standby)

Notes from setting up a two-node lab on Postgres 16. Not a production runbook — more of a "what actually worked" dump.

## Topology

| Role    | Host (lab)     | Port |
|---------|----------------|------|
| primary | 10.0.10.11     | 5432 |
| standby | 10.0.10.12     | 5432 |

Both VMs share the same major version. Mixing 15/16 is asking for pain.

## Primary (`postgresql.conf`)

```conf
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
wal_keep_size = 1GB
hot_standby = on          # harmless on primary, required later if promoted
archive_mode = on
archive_command = 'test ! -f /var/lib/pgsql/archive/%f && cp %p /var/lib/pgsql/archive/%f'
```

`pg_hba.conf` — allow the repl user from the standby only:

```
host replication repl_user 10.0.10.12/32 scram-sha-256
```

Create the role + slot:

```sql
CREATE ROLE repl_user WITH REPLICATION LOGIN PASSWORD 'change-me';
SELECT * FROM pg_create_physical_replication_slot('standby_1', true);
```

The second arg (`immediately_reserve = true`) keeps WAL around before the standby connects. Useful when the base backup takes a while.

## Standby bootstrap

Stop postgres on the standby, wipe `data/`, then:

```bash
pg_basebackup -h 10.0.10.11 -U repl_user -D /var/lib/pgsql/16/data \
  -Fp -Xs -P -R -S standby_1
```

`-R` writes `postgresql.auto.conf` with `primary_conninfo` and marks the node as standby. Confirm:

```conf
primary_conninfo = 'host=10.0.10.11 port=5432 user=repl_user'
primary_slot_name = 'standby_1'
```

Start the standby. On the primary:

```sql
SELECT client_addr, state, sync_state, replay_lag
FROM pg_stat_replication;
```

You want `state = streaming`. Replay lag of a few hundred ms is normal under load.

## Failover drill (lab)

1. Stop primary (or `pg_ctl stop -m fast`).
2. On standby: `pg_ctl promote` (or `SELECT pg_promote();`).
3. Point apps at the new primary.
4. Rebuild the old primary as a *new* standby — do not just restart it and hope.

## Things that bit me

- Firewall left port 5432 closed → basebackup hung with no useful error.
- Slot created but never used → WAL piled up until disk filled. Drop unused slots.
- `wal_level = minimal` left over from a previous install — replication refused to start.

See also `replication/check_lag.sql` for ongoing monitoring queries.

-- Citus multi-tenant sketch for a billing SaaS.
-- Coordinator runs these after CREATE EXTENSION citus; and workers are added.

CREATE TABLE tenants (
    tenant_id   uuid PRIMARY KEY,
    name        text NOT NULL,
    plan_code   text NOT NULL,
    created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE invoices (
    tenant_id   uuid NOT NULL,
    invoice_id  bigserial,
    status      text NOT NULL,
    total_cents integer NOT NULL,
    issued_on   date NOT NULL,
    PRIMARY KEY (tenant_id, invoice_id)
);

CREATE TABLE invoice_lines (
    tenant_id   uuid NOT NULL,
    invoice_id  bigint NOT NULL,
    line_no     integer NOT NULL,
    sku         text NOT NULL,
    qty         integer NOT NULL,
    unit_cents  integer NOT NULL,
    PRIMARY KEY (tenant_id, invoice_id, line_no)
);

-- Small dimension table → reference (replicated to all workers)
CREATE TABLE plan_catalog (
    plan_code   text PRIMARY KEY,
    monthly_cents integer NOT NULL,
    features    jsonb NOT NULL DEFAULT '{}'
);

SELECT create_reference_table('plan_catalog');

-- Shard by tenant; keep related rows together
SELECT create_distributed_table('tenants', 'tenant_id');
SELECT create_distributed_table('invoices', 'tenant_id', colocate_with => 'tenants');
SELECT create_distributed_table('invoice_lines', 'tenant_id', colocate_with => 'invoices');

-- Hot tenant isolation example (run when one customer dominates a shard)
-- SELECT isolate_tenant_to_new_shard('invoices', '11111111-1111-1111-1111-111111111111', 'CASCADE');

-- Sample data so reports are not empty. Amounts are fake.

BEGIN;

INSERT INTO sales_reps (full_name, email, hire_date, region) VALUES
    ('Maya Chen',     'maya.chen@example.com',   '2022-03-01', 'NA'),
    ('Luis Ortega',   'luis.ortega@example.com', '2021-11-15', 'LATAM'),
    ('Priya Nair',    'priya.nair@example.com',  '2023-01-09', 'EMEA'),
    ('Tomás Silva',   'tomas.silva@example.com', '2020-07-20', 'LATAM'),
    ('Aiko Watanabe', 'aiko.w@example.com',      '2022-09-12', 'APAC');

INSERT INTO accounts (legal_name, trade_name, industry, country_code, owner_id) VALUES
    ('Brightline Logistics LLC', 'Brightline', 'logistics', 'US', 1),
    ('Norte Tech SA de CV',      'NorteTech',  'saas',      'MX', 2),
    ('Harbor Analytics Ltd',     'Harbor',     'fintech',   'GB', 3),
    ('Andes Retail SpA',         'Andes',      'retail',    'CL', 4),
    ('Sakura Health KK',         'Sakura',     'healthcare','JP', 5),
    ('Cascade Foods Inc',        'Cascade',    'cpg',       'US', 1);

INSERT INTO contacts (account_id, first_name, last_name, email, title, is_primary) VALUES
    (1, 'Jen',  'Park',    'jpark@brightline.example', 'VP Ops', true),
    (2, 'Diego','Ruiz',    'diego@nortetech.example',  'CTO', true),
    (3, 'Helen','Brooks',  'hbrooks@harbor.example',   'CFO', true),
    (4, 'Camila','Rojas',  'crojas@andes.example',     'Buyer', true),
    (5, 'Kenji','Sato',    'ksato@sakura.example',     'IT Dir', true);

INSERT INTO leads (company_name, contact_email, status, source, owner_id, estimated_arr, created_at) VALUES
    ('Orbital Pack',   'hi@orbital.example',  'qualified', 'webinar',   1, 48000, '2024-11-02'),
    ('Lumen Desk',     'sales@lumen.example', 'meeting',   'inbound',   3, 72000, '2024-12-10'),
    ('Rio Cargo',      NULL,                  'new',       'cold_call', 2, 15000, '2025-01-08'),
    ('Pacific Bites',  'ops@pb.example',      'won',       'partner',   5, 31000, '2024-10-21'),
    ('Greyline Media', 'a@grey.example',      'lost',      'inbound',   1, 90000, '2024-09-14');

INSERT INTO opportunities (account_id, owner_id, name, stage, amount, close_date, created_at) VALUES
    (1, 1, 'Brightline WMS expansion',  'closed_won',  125000, '2024-10-18', '2024-07-01'),
    (1, 1, 'Brightline API add-on',     'negotiation',  28000, '2025-03-30', '2025-01-05'),
    (2, 2, 'NorteTech annual renew',    'closed_won',   64000, '2024-11-02', '2024-08-12'),
    (3, 3, 'Harbor risk module',        'proposal',     91000, '2025-04-15', '2025-01-20'),
    (4, 4, 'Andes POS rollout',         'closed_won',   45500, '2024-12-09', '2024-09-01'),
    (5, 5, 'Sakura clinic portal',      'closed_won',  110000, '2025-01-22', '2024-10-03'),
    (6, 1, 'Cascade inventory sync',    'closed_lost',  38000, '2024-11-28', '2024-08-20'),
    (2, 2, 'NorteTech LatAm seats',     'discovery',    22000, NULL,         '2025-02-01'),
    (3, 3, 'Harbor SOC2 package',       'closed_won',   17500, '2024-09-30', '2024-06-11'),
    (4, 4, 'Andes loyalty pilot',       'meeting',      12000, '2025-05-01', '2025-02-10');

-- Pre-aggregated months (could also be built from opportunities)
INSERT INTO sales_fact_monthly (year_month, rep_id, region, deals_won, revenue) VALUES
    ('2024-09-01', 3, 'EMEA',  1, 17500),
    ('2024-10-01', 1, 'NA',    1, 125000),
    ('2024-11-01', 2, 'LATAM', 1, 64000),
    ('2024-11-01', 1, 'NA',    0, 0),
    ('2024-12-01', 4, 'LATAM', 1, 45500),
    ('2025-01-01', 5, 'APAC',  1, 110000);

INSERT INTO activities (opportunity_id, rep_id, activity_type, notes, happened_at) VALUES
    (1, 1, 'meeting', 'Signed SOW, kickoff next week', '2024-10-18 16:00+00'),
    (3, 2, 'call',    'Renewal confirmed, invoice sent', '2024-11-01 14:30+00'),
    (4, 3, 'email',   'Sent proposal v2 with discount', '2025-02-02 09:15+00');

COMMIT;

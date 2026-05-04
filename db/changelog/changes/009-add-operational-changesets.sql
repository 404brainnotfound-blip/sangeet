--liquibase formatted sql

--changeset aaryan.baidhya:009-add-patient-columns labels:schema,enhancement
USE zakipoint_db;

ALTER TABLE patients
    ADD COLUMN preferred_language  VARCHAR(50)  DEFAULT 'English' AFTER address,
    ADD COLUMN emergency_contact   VARCHAR(100) AFTER preferred_language,
    ADD COLUMN emergency_phone     VARCHAR(20)  AFTER emergency_contact;

--rollback ALTER TABLE patients DROP COLUMN emergency_phone;
--rollback ALTER TABLE patients DROP COLUMN emergency_contact;
--rollback ALTER TABLE patients DROP COLUMN preferred_language;


--changeset aaryan.baidhya:009-deployment-log labels:ops runAlways:true
-- runAlways:true — runs on EVERY liquibase update regardless of prior executions.
-- DATABASECHANGELOG records each run with EXECTYPE = 'RERAN'.
-- Use case: audit trail of deployments, updating a metadata record, refreshing config values.
USE zakipoint_db;

INSERT INTO audit_log (table_name, action, old_value, new_value, changed_by)
VALUES (
    'SYSTEM',
    'DEPLOYMENT',
    NULL,
    CONCAT('liquibase update at ', NOW(), ' | schema version: 009'),
    'liquibase-runner'
);

--rollback DELETE FROM audit_log WHERE table_name='SYSTEM' AND action='DEPLOYMENT' ORDER BY changed_at DESC LIMIT 1;


--changeset aaryan.baidhya:009-seed-patient-billing labels:billing,seed context:dev,test
USE zakipoint_db;

INSERT INTO patient_billing (patient_id, plan_id, effective_from, copay_paid, amount_billed, amount_paid, billing_status) VALUES
(1, 1, '2026-01-01', 20.00,  450.00, 430.00, 'Active'),
(2, 2, '2026-01-01', 30.00,  300.00, 300.00, 'Settled'),
(3, 3, '2026-02-01', 25.00,  800.00, 600.00, 'Active'),
(4, 4, '2026-01-15',  0.00,  150.00, 150.00, 'Settled'),
(5, 5, '2025-12-01', 10.00, 1200.00, 900.00, 'Overdue'),
(6, 1, '2026-03-01', 20.00,   75.00,  75.00, 'Settled');

--rollback DELETE FROM patient_billing WHERE patient_id IN (1,2,3,4,5,6);

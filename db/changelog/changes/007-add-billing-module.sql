--liquibase formatted sql

--changeset aaryan.baidhya:007-create-billing-plans labels:billing,schema
USE zakipoint_db;

CREATE TABLE IF NOT EXISTS billing_plans (
    plan_id         INT             PRIMARY KEY AUTO_INCREMENT,
    plan_code       VARCHAR(20)     UNIQUE NOT NULL,
    plan_name       VARCHAR(100)    NOT NULL,
    plan_type       ENUM('HMO','PPO','EPO','POS','HDHP') NOT NULL,
    monthly_premium DECIMAL(10,2)   NOT NULL,
    deductible      DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    copay_amount    DECIMAL(10,2)   NOT NULL DEFAULT 0.00,
    coverage_pct    TINYINT         NOT NULL DEFAULT 80,
    is_active       TINYINT(1)      DEFAULT 1,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--rollback DROP TABLE IF EXISTS billing_plans;


--changeset aaryan.baidhya:007-create-patient-billing labels:billing,schema
USE zakipoint_db;

CREATE TABLE IF NOT EXISTS patient_billing (
    billing_id      INT             PRIMARY KEY AUTO_INCREMENT,
    patient_id      INT             NOT NULL,
    plan_id         INT             NOT NULL,
    effective_from  DATE            NOT NULL,
    effective_to    DATE,
    copay_paid      DECIMAL(10,2)   DEFAULT 0.00,
    amount_billed   DECIMAL(10,2)   DEFAULT 0.00,
    amount_paid     DECIMAL(10,2)   DEFAULT 0.00,
    balance_due     DECIMAL(10,2)   GENERATED ALWAYS AS (amount_billed - amount_paid) STORED,
    billing_status  ENUM('Active','Settled','Overdue','Disputed') DEFAULT 'Active',
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_bill_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    CONSTRAINT fk_bill_plan    FOREIGN KEY (plan_id)    REFERENCES billing_plans(plan_id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_billing_patient    ON patient_billing(patient_id);
CREATE INDEX idx_billing_plan       ON patient_billing(plan_id);
CREATE INDEX idx_billing_status     ON patient_billing(billing_status);
CREATE INDEX idx_billing_effective  ON patient_billing(effective_from, effective_to);

--rollback DROP INDEX idx_billing_effective ON patient_billing;
--rollback DROP INDEX idx_billing_status    ON patient_billing;
--rollback DROP INDEX idx_billing_plan      ON patient_billing;
--rollback DROP INDEX idx_billing_patient   ON patient_billing;
--rollback DROP TABLE IF EXISTS patient_billing;


--changeset aaryan.baidhya:007-seed-billing-plans labels:billing,seed context:dev,test
USE zakipoint_db;

INSERT INTO billing_plans (plan_code, plan_name, plan_type, monthly_premium, deductible, copay_amount, coverage_pct) VALUES
('ZKP-HMO-BASIC',   'Zakipoint Basic HMO',      'HMO',  299.99, 1500.00, 20.00, 80),
('ZKP-PPO-PLUS',    'Zakipoint Plus PPO',        'PPO',  479.99,  500.00, 30.00, 85),
('ZKP-EPO-CORE',    'Zakipoint Core EPO',        'EPO',  389.99, 1000.00, 25.00, 80),
('ZKP-HDHP-SAVE',   'Zakipoint HSA-Compatible',  'HDHP', 199.99, 3000.00,  0.00, 70),
('ZKP-PPO-PREMIUM', 'Zakipoint Premium PPO',     'PPO',  699.99,    0.00, 10.00, 95);

--rollback DELETE FROM billing_plans WHERE plan_code IN ('ZKP-HMO-BASIC','ZKP-PPO-PLUS','ZKP-EPO-CORE','ZKP-HDHP-SAVE','ZKP-PPO-PREMIUM');

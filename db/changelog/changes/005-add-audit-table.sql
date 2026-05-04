--liquibase formatted sql

--changeset aaryan.baidhya:005-add-audit-table labels:audit,tracking
--comment: Add audit_log table for HIPAA-compliant change tracking

USE zakipoint_db;

CREATE TABLE IF NOT EXISTS audit_log (
    audit_id    INT             PRIMARY KEY AUTO_INCREMENT,
    table_name  VARCHAR(100)    NOT NULL,
    action      VARCHAR(50)     NOT NULL,
    record_id   INT,
    old_value   TEXT,
    new_value   TEXT,
    changed_by  VARCHAR(100),
    changed_at  TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    ip_address  VARCHAR(45)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_date  ON audit_log(changed_at);
CREATE INDEX idx_audit_action ON audit_log(action);

--rollback DROP INDEX idx_audit_action ON audit_log;
--rollback DROP INDEX idx_audit_date ON audit_log;
--rollback DROP INDEX idx_audit_table ON audit_log;
--rollback DROP TABLE IF EXISTS audit_log;

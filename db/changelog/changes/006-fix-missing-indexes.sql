--liquibase formatted sql

--changeset aaryan.baidhya:006-add-missing-indexes labels:performance,indexes
--comment: Add missing FK index on medical_records.doctor_id and composite indexes on appointments for common query patterns

USE zakipoint_db;

-- InnoDB does not auto-index FK referencing columns; without this, every doctor DELETE/UPDATE triggers a full scan of medical_records
CREATE INDEX idx_records_doctor ON medical_records(doctor_id);

-- Composite indexes for the two most common appointment queries: patient schedule and doctor schedule
CREATE INDEX idx_appt_patient_date ON appointments(patient_id, appointment_date);
CREATE INDEX idx_appt_doctor_date  ON appointments(doctor_id, appointment_date);

--rollback DROP INDEX idx_appt_doctor_date  ON appointments;
--rollback DROP INDEX idx_appt_patient_date ON appointments;
--rollback DROP INDEX idx_records_doctor    ON medical_records;

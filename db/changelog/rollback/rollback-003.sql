--liquibase formatted sql
-- Rollback script for changeset 003-add-indexes
-- Use: liquibase rollback-count 1 (if 003 was last applied)

USE zakipoint_db;

DROP INDEX IF EXISTS idx_records_patient       ON medical_records;
DROP INDEX IF EXISTS idx_records_visit_date    ON medical_records;
DROP INDEX IF EXISTS idx_appt_doctor           ON appointments;
DROP INDEX IF EXISTS idx_appt_patient          ON appointments;
DROP INDEX IF EXISTS idx_appt_status           ON appointments;
DROP INDEX IF EXISTS idx_appt_date             ON appointments;
DROP INDEX IF EXISTS idx_doctors_department    ON doctors;
DROP INDEX IF EXISTS idx_doctors_specialization ON doctors;
DROP INDEX IF EXISTS idx_patients_insurance    ON patients;
DROP INDEX IF EXISTS idx_patients_dob          ON patients;
DROP INDEX IF EXISTS idx_patients_last_name    ON patients;

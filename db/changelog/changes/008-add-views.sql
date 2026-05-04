--liquibase formatted sql

--changeset aaryan.baidhya:008-view-patient-summary labels:views runOnChange:true
-- runOnChange:true means Liquibase re-executes this changeset whenever its content changes.
-- This is the correct pattern for views and stored procedures — they are re-definable logic,
-- not structural state. A content change triggers RERAN instead of a checksum error.
USE zakipoint_db;

CREATE OR REPLACE VIEW v_patient_summary AS
SELECT
    p.patient_id,
    CONCAT(p.first_name, ' ', p.last_name)  AS full_name,
    p.date_of_birth,
    TIMESTAMPDIFF(YEAR, p.date_of_birth, CURDATE()) AS age,
    p.gender,
    p.insurance_id,
    p.phone,
    p.email,
    COUNT(DISTINCT a.appointment_id)         AS total_appointments,
    SUM(CASE WHEN a.status = 'Completed'
             THEN 1 ELSE 0 END)              AS completed_visits,
    SUM(CASE WHEN a.status = 'Scheduled'
             THEN 1 ELSE 0 END)              AS upcoming_visits,
    MAX(a.appointment_date)                  AS last_appointment,
    COALESCE(SUM(pb.balance_due), 0.00)      AS total_balance_due,
    bp.plan_name                             AS current_plan,
    p.is_active
FROM patients p
LEFT JOIN appointments   a  ON p.patient_id = a.patient_id
LEFT JOIN patient_billing pb ON p.patient_id = pb.patient_id AND pb.billing_status = 'Active'
LEFT JOIN billing_plans   bp ON pb.plan_id = bp.plan_id
GROUP BY
    p.patient_id, p.first_name, p.last_name, p.date_of_birth,
    p.gender, p.insurance_id, p.phone, p.email, p.is_active, bp.plan_name;

--rollback DROP VIEW IF EXISTS v_patient_summary;


--changeset aaryan.baidhya:008-view-doctor-workload labels:views runOnChange:true
USE zakipoint_db;

CREATE OR REPLACE VIEW v_doctor_workload AS
SELECT
    d.doctor_id,
    CONCAT(d.first_name, ' ', d.last_name)  AS doctor_name,
    d.specialization,
    d.department,
    COUNT(a.appointment_id)                  AS total_appointments,
    SUM(CASE WHEN a.status = 'Scheduled'
             THEN 1 ELSE 0 END)              AS scheduled,
    SUM(CASE WHEN a.status = 'Completed'
             THEN 1 ELSE 0 END)              AS completed,
    SUM(CASE WHEN a.status = 'Cancelled'
             THEN 1 ELSE 0 END)              AS cancelled,
    SUM(CASE WHEN a.status = 'No-Show'
             THEN 1 ELSE 0 END)              AS no_show,
    MIN(a.appointment_date)                  AS first_appointment,
    MAX(a.appointment_date)                  AS latest_appointment
FROM doctors d
LEFT JOIN appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization, d.department;

--rollback DROP VIEW IF EXISTS v_doctor_workload;

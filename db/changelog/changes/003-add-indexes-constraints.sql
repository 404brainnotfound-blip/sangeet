--liquibase formatted sql

--changeset aaryan.baidhya:003-add-indexes labels:performance,indexes
--comment: Add indexes for query optimization on frequently searched columns

USE zakipoint_db;

CREATE INDEX idx_patients_last_name    ON patients(last_name);
CREATE INDEX idx_patients_dob          ON patients(date_of_birth);
CREATE INDEX idx_patients_insurance    ON patients(insurance_id);

CREATE INDEX idx_doctors_specialization ON doctors(specialization);
CREATE INDEX idx_doctors_department     ON doctors(department);

CREATE INDEX idx_appt_date             ON appointments(appointment_date);
CREATE INDEX idx_appt_status           ON appointments(status);
CREATE INDEX idx_appt_patient          ON appointments(patient_id);
CREATE INDEX idx_appt_doctor           ON appointments(doctor_id);

CREATE INDEX idx_records_visit_date    ON medical_records(visit_date);
CREATE INDEX idx_records_patient       ON medical_records(patient_id);

--rollback DROP INDEX idx_records_patient      ON medical_records;
--rollback DROP INDEX idx_records_visit_date   ON medical_records;
--rollback DROP INDEX idx_appt_doctor          ON appointments;
--rollback DROP INDEX idx_appt_patient         ON appointments;
--rollback DROP INDEX idx_appt_status          ON appointments;
--rollback DROP INDEX idx_appt_date            ON appointments;
--rollback DROP INDEX idx_doctors_department   ON doctors;
--rollback DROP INDEX idx_doctors_specialization ON doctors;
--rollback DROP INDEX idx_patients_insurance   ON patients;
--rollback DROP INDEX idx_patients_dob         ON patients;
--rollback DROP INDEX idx_patients_last_name   ON patients;

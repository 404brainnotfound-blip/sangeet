--liquibase formatted sql

--changeset aaryan.baidhya:002-create-patients-table labels:schema,tables
--comment: Create patients table for storing patient demographic and contact data

USE zakipoint_db;

CREATE TABLE IF NOT EXISTS patients (
    patient_id      INT             PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(100)    NOT NULL,
    last_name       VARCHAR(100)    NOT NULL,
    date_of_birth   DATE            NOT NULL,
    gender          ENUM('M','F','Other') NOT NULL,
    email           VARCHAR(255)    UNIQUE,
    phone           VARCHAR(20),
    address         TEXT,
    insurance_id    VARCHAR(50),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active       TINYINT(1)      DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--rollback DROP TABLE IF EXISTS patients;

--changeset aaryan.baidhya:002-create-doctors-table labels:schema,tables
--comment: Create doctors table for provider information

USE zakipoint_db;

CREATE TABLE IF NOT EXISTS doctors (
    doctor_id       INT             PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(100)    NOT NULL,
    last_name       VARCHAR(100)    NOT NULL,
    specialization  VARCHAR(100)    NOT NULL,
    license_number  VARCHAR(50)     UNIQUE NOT NULL,
    email           VARCHAR(255)    UNIQUE,
    phone           VARCHAR(20),
    department      VARCHAR(100),
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    is_active       TINYINT(1)      DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--rollback DROP TABLE IF EXISTS doctors;

--changeset aaryan.baidhya:002-create-appointments-table labels:schema,tables
--comment: Create appointments table linking patients and doctors

USE zakipoint_db;

CREATE TABLE IF NOT EXISTS appointments (
    appointment_id      INT             PRIMARY KEY AUTO_INCREMENT,
    patient_id          INT             NOT NULL,
    doctor_id           INT             NOT NULL,
    appointment_date    DATETIME        NOT NULL,
    status              ENUM('Scheduled','Completed','Cancelled','No-Show') DEFAULT 'Scheduled',
    notes               TEXT,
    created_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_appt_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    CONSTRAINT fk_appt_doctor  FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--rollback DROP TABLE IF EXISTS appointments;

--changeset aaryan.baidhya:002-create-medical-records-table labels:schema,tables
--comment: Create medical_records table for clinical encounter data

USE zakipoint_db;

CREATE TABLE IF NOT EXISTS medical_records (
    record_id       INT             PRIMARY KEY AUTO_INCREMENT,
    patient_id      INT             NOT NULL,
    doctor_id       INT             NOT NULL,
    visit_date      DATE            NOT NULL,
    diagnosis       TEXT,
    treatment       TEXT,
    prescription    TEXT,
    follow_up_date  DATE,
    created_at      TIMESTAMP       DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rec_patient FOREIGN KEY (patient_id) REFERENCES patients(patient_id) ON DELETE RESTRICT,
    CONSTRAINT fk_rec_doctor  FOREIGN KEY (doctor_id)  REFERENCES doctors(doctor_id)  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--rollback DROP TABLE IF EXISTS medical_records;

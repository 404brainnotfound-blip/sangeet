--liquibase formatted sql

--changeset aaryan.baidhya:004-seed-doctors labels:data,seed context:dev,test
--comment: Insert sample doctor records for development and testing

USE zakipoint_db;

INSERT INTO doctors (first_name, last_name, specialization, license_number, email, phone, department) VALUES
('Rajesh',  'Kumar',    'Cardiology',        'MD-001-NY', 'r.kumar@zakipoint.com',   '555-0101', 'Cardiology'),
('Priya',   'Sharma',   'Internal Medicine', 'MD-002-NY', 'p.sharma@zakipoint.com',  '555-0102', 'Internal Medicine'),
('Michael', 'Johnson',  'Orthopedics',       'MD-003-NY', 'm.johnson@zakipoint.com', '555-0103', 'Orthopedics'),
('Sarah',   'Williams', 'Pediatrics',        'MD-004-NY', 's.williams@zakipoint.com','555-0104', 'Pediatrics'),
('David',   'Brown',    'Neurology',         'MD-005-NY', 'd.brown@zakipoint.com',   '555-0105', 'Neurology');

--rollback DELETE FROM doctors WHERE license_number IN ('MD-001-NY','MD-002-NY','MD-003-NY','MD-004-NY','MD-005-NY');

--changeset aaryan.baidhya:004-seed-patients labels:data,seed context:dev,test
--comment: Insert sample patient records for development and testing

USE zakipoint_db;

INSERT INTO patients (first_name, last_name, date_of_birth, gender, email, phone, address, insurance_id) VALUES
('John',    'Doe',      '1985-03-15', 'M',     'john.doe@email.com',     '555-1001', '123 Main St, New York, NY 10001', 'INS-10001'),
('Jane',    'Smith',    '1990-07-22', 'F',     'jane.smith@email.com',   '555-1002', '456 Oak Ave, Brooklyn, NY 11201', 'INS-10002'),
('Robert',  'Johnson',  '1978-11-08', 'M',     'r.johnson@email.com',    '555-1003', '789 Pine Rd, Queens, NY 11354',   'INS-10003'),
('Emily',   'Davis',    '1995-01-30', 'F',     'e.davis@email.com',      '555-1004', '321 Elm St, Bronx, NY 10451',     'INS-10004'),
('Michael', 'Wilson',   '1965-09-12', 'M',     'm.wilson@email.com',     '555-1005', '654 Maple Dr, Staten Island, NY', 'INS-10005'),
('Aaryan',  'Baidhya',  '2003-04-17', 'M',     'aaryan.baidhya@email.com','555-1006','100 Intern Blvd, New York, NY',   'INS-10006');

--rollback DELETE FROM patients WHERE insurance_id IN ('INS-10001','INS-10002','INS-10003','INS-10004','INS-10005','INS-10006');

--changeset aaryan.baidhya:004-seed-appointments labels:data,seed context:dev,test
--comment: Insert sample appointment records

USE zakipoint_db;

INSERT INTO appointments (patient_id, doctor_id, appointment_date, status, notes) VALUES
(1, 1, '2026-05-10 09:00:00', 'Scheduled',  'Annual cardiac checkup'),
(2, 2, '2026-05-11 10:30:00', 'Scheduled',  'Follow-up for hypertension'),
(3, 3, '2026-05-12 14:00:00', 'Scheduled',  'Knee pain consultation'),
(4, 4, '2026-04-20 11:00:00', 'Completed',  'Routine pediatric exam'),
(5, 5, '2026-04-25 15:30:00', 'Completed',  'Migraine evaluation'),
(6, 2, '2026-05-15 09:30:00', 'Scheduled',  'Intern health screening');

--rollback DELETE FROM appointments WHERE patient_id IN (1,2,3,4,5,6) AND doctor_id IN (1,2,3,4,5);

--liquibase formatted sql

--changeset aaryan.baidhya:001-create-schema labels:schema
--comment: Create zakipoint_db database and initial schema setup

CREATE DATABASE IF NOT EXISTS zakipoint_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE zakipoint_db;

--rollback DROP DATABASE IF EXISTS zakipoint_db;

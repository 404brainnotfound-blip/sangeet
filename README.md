# Liquibase MySQL Database Migration Project

**Organization:** Zakipoint Health  
**Intern:** Aaryan Baidhya  
**Mentor (Gurudev):** Shrawan Panthi  
**Date:** May 2026  
**Database:** MySQL 8.4 — `zakipoint_db`

---

## Table of Contents

1. [What is Liquibase?](#1-what-is-liquibase)
2. [How Liquibase Works Internally](#2-how-liquibase-works-internally)
3. [Key Concepts](#3-key-concepts)
4. [Project Structure](#4-project-structure)
5. [Prerequisites & Setup](#5-prerequisites--setup)
6. [Running Liquibase](#6-running-liquibase)
7. [Changeset Execution Attributes](#7-changeset-execution-attributes)
8. [What Was Demonstrated](#8-what-was-demonstrated)
9. [DATABASECHANGELOG Explained](#9-databasechangelog-explained)
10. [Verification Queries](#10-verification-queries)
11. [Rollback](#11-rollback)
12. [Pros and Cons](#12-pros-and-cons)
13. [Liquibase vs Flyway](#13-liquibase-vs-flyway)
14. [Troubleshooting](#14-troubleshooting)
15. [Command Reference](#15-command-reference)

---

## 1. What is Liquibase?

Liquibase is an **open-source database schema change management tool**. It solves one of the hardest problems in software teams: keeping the database in sync with application code across multiple developers, environments, and deployments.

### The problem it solves

Imagine a team of 5 developers. Each writes SQL scripts to add tables or columns. Without a tool:
- Developer A runs a script. Developer B doesn't know it exists.
- The dev database has 10 migrations. Staging has 7. Production has 6.
- No one knows which scripts ran where.
- Re-running a `CREATE TABLE` script crashes everything.

Liquibase fixes this by making every SQL change **versioned, tracked, and idempotent** — meaning it is safe to run `liquibase update` 100 times; it will only apply what hasn't been applied yet.

---

## 2. How Liquibase Works Internally

```
Developer writes a changeset (SQL file)
          │
          ▼
liquibase update is called
          │
          ▼
Liquibase acquires a lock in DATABASECHANGELOGLOCK
(prevents two processes from running simultaneously)
          │
          ▼
Liquibase reads the master changelog
(db.changelog-master.xml — the "playlist")
          │
          ▼
For each changeset in the playlist:
  → Compute MD5 checksum of changeset content
  → Check DATABASECHANGELOG table:
      - Not found?         → Execute it, record EXECUTED
      - Found, same hash?  → Skip it (already done)
      - Found, diff hash?  → ERROR (you modified a deployed changeset)
      - runOnChange=true?  → Re-execute if hash differs, record RERAN
      - runAlways=true?    → Always execute, record RERAN
          │
          ▼
Release the lock
          │
          ▼
Print summary: Run / Previously run / Filtered out
```

The two tables Liquibase creates automatically:

| Table | Purpose |
|---|---|
| `DATABASECHANGELOG` | Audit log of every changeset ever executed |
| `DATABASECHANGELOGLOCK` | Mutex lock — prevents concurrent `liquibase update` runs |

---

## 3. Key Concepts

### Changelog
The master file (`db.changelog-master.xml`) that lists all SQL files in order. Think of it as a playlist — it tells Liquibase which files to read and in what order.

### Changeset
A single atomic unit of change inside a SQL file. Identified by three things combined:
```
id + author + filename  →  must be globally unique
```
Example: `007-create-billing-plans` by `aaryan.baidhya` in `007-add-billing-module.sql`.

### Checksum (MD5SUM)
When a changeset first executes, Liquibase computes an MD5 hash of its content and stores it in `DATABASECHANGELOG.MD5SUM`. On every future run it re-computes the hash. If it differs, Liquibase throws a validation error — this is intentional protection against accidentally modifying already-deployed logic. **Never edit a changeset that has been deployed.**

### EXECTYPE
The `EXECTYPE` column in `DATABASECHANGELOG` tells you exactly how a changeset ran:

| EXECTYPE | Meaning |
|---|---|
| `EXECUTED` | Ran for the first time normally |
| `RERAN` | Re-ran due to `runAlways:true` or `runOnChange:true` |
| `FAILED` | The SQL failed — Liquibase rolled it back |
| `SKIPPED` | Filtered out by context or label |

---

## 4. Project Structure

```
sangeet/
├── liquibase.properties            # DB connection config (gitignored — contains password)
├── liquibase.properties.example    # Safe template — copy this and fill in credentials
├── .gitignore
├── db/
│   └── changelog/
│       ├── db.changelog-master.xml     # Root playlist — includes all SQL files in order
│       └── changes/
│           ├── 001-create-schema.sql               # CREATE DATABASE zakipoint_db
│           ├── 002-add-tables.sql                  # patients, doctors, appointments, medical_records
│           ├── 003-add-indexes-constraints.sql     # Indexes for query performance
│           ├── 004-seed-data.sql                   # Sample doctors, patients, appointments
│           ├── 005-add-audit-table.sql             # audit_log for HIPAA compliance
│           ├── 006-fix-missing-indexes.sql         # Composite + FK indexes (added in review)
│           ├── 007-add-billing-module.sql          # billing_plans + patient_billing tables
│           ├── 008-add-views.sql                   # v_patient_summary, v_doctor_workload (runOnChange)
│           └── 009-add-operational-changesets.sql  # ALTER TABLE + runAlways + context seed
├── lib/
│   └── mysql-connector-j-8.3.0.jar    # MySQL JDBC driver (required by Liquibase)
└── logs/
    └── liquibase-update.log           # Execution log (gitignored)
```

### Database Tables Created

| Table | Description |
|---|---|
| `patients` | Patient demographics and contact info |
| `doctors` | Provider information and specializations |
| `appointments` | Scheduled/completed visits linking patients and doctors |
| `medical_records` | Clinical encounter notes and prescriptions |
| `audit_log` | HIPAA-compliant change tracking |
| `billing_plans` | Insurance plan definitions |
| `patient_billing` | Patient-to-plan assignments with balance tracking |
| `v_patient_summary` | View: patient summary with appointment counts and balance |
| `v_doctor_workload` | View: per-doctor appointment breakdown by status |

---

## 5. Prerequisites & Setup

### Software Requirements

| Software | Version | Purpose |
|---|---|---|
| Java JDK | 11+ | Liquibase runs on the JVM |
| MySQL | 8.0+ | Target database |
| Liquibase | 4.27.0 | Schema change manager |
| MySQL Connector/J | 8.3.0 | JDBC driver for MySQL |

### Install Liquibase (Linux)

```bash
# Download the zip
wget https://github.com/liquibase/liquibase/releases/download/v4.27.0/liquibase-4.27.0.zip
unzip liquibase-4.27.0.zip -d ~/liquibase

# Add to PATH permanently
echo 'export PATH="$HOME/liquibase:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
liquibase --version
```

> **Why `liquibase --version` shows nothing on Ubuntu:**  
> Liquibase is not on the system `PATH`. The binary lives at `~/liquibase/liquibase` but the shell doesn't know to look there. Running `source ~/.bashrc` after adding the export line fixes it for the current session. New terminals will pick it up automatically.

### Configure Database Connection

Copy the example file and fill in your credentials:
```bash
cp liquibase.properties.example liquibase.properties
# Edit liquibase.properties with your MySQL credentials
```

The `liquibase.properties` file is gitignored to prevent credentials from being committed.

### MySQL 8.4 Note

MySQL 8.4 removed `mysql_native_password`. If root uses socket auth, fix it first:
```bash
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'yourpassword'; FLUSH PRIVILEGES;"
```

---

## 6. Running Liquibase

All commands must be run from the project root (`sangeet/` directory).

### First run — apply all changesets
```bash
liquibase update --contexts=dev,test
```

### Check what would run before actually running
```bash
liquibase status --verbose
```

### View history of everything that ran
```bash
liquibase history
```

### Dry run — show SQL without executing
```bash
liquibase update-sql --contexts=dev,test
```

### Validate changelog syntax
```bash
liquibase validate
```

### Run only for production (excludes dev/test seed data)
```bash
liquibase update --contexts=prod
```

---

## 7. Changeset Execution Attributes

These attributes control *when* a changeset runs. Understanding them is the difference between Liquibase working correctly and silently misbehaving.

### `runAlways:true`

```sql
--changeset aaryan.baidhya:009-deployment-log labels:ops runAlways:true
INSERT INTO audit_log (table_name, action, new_value, changed_by)
VALUES ('SYSTEM', 'DEPLOYMENT', CONCAT('deployed at ', NOW()), 'liquibase-runner');
```

Runs **every single time** `liquibase update` is called, regardless of whether it has run before. Liquibase records each execution as `EXECTYPE = RERAN` in `DATABASECHANGELOG`.

**When to use:** Writing a deployment timestamp, updating a metadata record, refreshing a config value — anything where re-running is intentional and side-effect-free.  
**When NOT to use:** `CREATE TABLE`, `ALTER TABLE`, or anything that fails on re-execution.

### `runOnChange:true`

```sql
--changeset aaryan.baidhya:008-view-patient-summary labels:views runOnChange:true
CREATE OR REPLACE VIEW v_patient_summary AS ...
```

Runs only when the **content of the changeset changes**. Liquibase compares the current MD5 checksum against what's stored. If they differ, it re-executes and updates the stored checksum (`EXECTYPE = RERAN`). If the content hasn't changed, it skips normally.

**When to use:** Views, stored procedures, functions — any re-definable database object that uses `CREATE OR REPLACE`. Without this attribute, modifying an already-deployed changeset would throw a validation error.

### `context:dev,test`

```sql
--changeset aaryan.baidhya:007-seed-billing-plans labels:billing,seed context:dev,test
INSERT INTO billing_plans ...
```

Acts as a filter gate. The changeset only executes when the matching context is passed at runtime. Without it, the changeset is counted in `Filtered out` in the summary output.

**Typical usage:**

```bash
# Development — runs everything including seed data
liquibase update --contexts=dev,test

# Production — skips any changeset with context:dev or context:test
liquibase update --contexts=prod
```

---

## 8. What Was Demonstrated

Five progressive `liquibase update` runs were made to prove different behaviors:

| Run | Script Added | Changesets Applied | Behavior Proven |
|-----|---|---|---|
| **Run 1** | `007-add-billing-module.sql` | 3 | Normal first execution → `EXECUTED` |
| **Run 2** | `008-add-views.sql` | 2 | `runOnChange` views applied → `EXECUTED` |
| **Run 3** | `009-add-operational-changesets.sql` | 3 | ALTER TABLE + `runAlways` + context seed |
| **Run 4** | *(view content modified)* | 2 | `runOnChange` re-fired → `RERAN`; all others skipped |
| **Run 5** | *(nothing new)* | 1 | Only `runAlways` fired → `RERAN`; everything else skipped |

**Run 4** is the most instructive: `v_patient_summary` was modified to join `billing_plans` and add a `current_plan` column to the view output. Because the changeset has `runOnChange:true`, Liquibase detected the checksum change and re-executed `CREATE OR REPLACE VIEW` automatically — no manual intervention, no error.

**Run 5** proves idempotency: calling `liquibase update` when nothing is new is completely safe. The only thing that ran was the `runAlways` deployment log changeset.

---

## 9. DATABASECHANGELOG Explained

This table is the brain of Liquibase. Every changeset execution is recorded here permanently.

```sql
SELECT ID, AUTHOR, EXECTYPE, DATE_FORMAT(DATEEXECUTED,'%Y-%m-%d %H:%i') AS WHEN,
       CONTEXTS, LABELS
FROM DATABASECHANGELOG ORDER BY ORDEREXECUTED;
```

| Column | What it tells you |
|---|---|
| `ID` | The changeset ID from `--changeset author:id` |
| `AUTHOR` | Who wrote it |
| `FILENAME` | Which file it's in |
| `DATEEXECUTED` | Exact timestamp it ran |
| `ORDEREXECUTED` | Sequential order number across all runs |
| `EXECTYPE` | `EXECUTED`, `RERAN`, `FAILED`, or `SKIPPED` |
| `MD5SUM` | Checksum of changeset content at time of execution |
| `CONTEXTS` | Which context it ran under |
| `LABELS` | Labels for filtering |
| `DEPLOYMENT_ID` | Groups all changesets from a single `liquibase update` call |

The `DEPLOYMENT_ID` is particularly useful: all changesets applied in one `liquibase update` run share the same `DEPLOYMENT_ID`, so you can identify exactly which changeset bundle introduced a problem.

### DATABASECHANGELOGLOCK

```sql
SELECT * FROM DATABASECHANGELOGLOCK;
```

| State | Meaning |
|---|---|
| `LOCKED = 0` | No update in progress — safe to run |
| `LOCKED = 1` | An update is running (or crashed while running) |

If Liquibase crashes mid-run, `LOCKED` stays `1` and future runs will fail with a lock error. Fix it with:
```bash
liquibase release-locks
```

---

## 10. Verification Queries

```sql
-- All tables in the database
SHOW TABLES;

-- Full execution history
SELECT ID, EXECTYPE, DATE_FORMAT(DATEEXECUTED,'%Y-%m-%d %H:%i:%s') AS WHEN,
       CONTEXTS, LABELS
FROM DATABASECHANGELOG ORDER BY ORDEREXECUTED;

-- Patient summary with billing plan (includes runOnChange view update)
SELECT full_name, age, total_appointments, total_balance_due, current_plan
FROM v_patient_summary;

-- Doctor workload
SELECT doctor_name, specialization, scheduled, completed
FROM v_doctor_workload;

-- Deployment audit trail (runAlways entries)
SELECT audit_id, new_value, changed_at
FROM audit_log WHERE table_name = 'SYSTEM';

-- Lock status
SELECT ID, LOCKED, LOCKEDBY FROM DATABASECHANGELOGLOCK;
```

---

## 11. Rollback

### Rollback the last N changesets
```bash
liquibase rollback-count 1
```

### Rollback to a tagged point
```bash
# First tag a deployment
liquibase tag v1.0

# Later, rollback to that tag
liquibase rollback --tag=v1.0
```

### Preview what rollback SQL would run (without executing)
```bash
liquibase rollback-count-sql 1
```

Every destructive changeset in this project includes `--rollback` directives so Liquibase knows how to undo it. Example from `007-add-billing-module.sql`:

```sql
--changeset aaryan.baidhya:007-create-patient-billing labels:billing,schema
CREATE TABLE IF NOT EXISTS patient_billing ( ... );

--rollback DROP INDEX idx_billing_effective ON patient_billing;
--rollback DROP INDEX idx_billing_patient   ON patient_billing;
--rollback DROP TABLE IF EXISTS patient_billing;
```

---

## 12. Pros and Cons

### Pros

| Advantage | Why it matters |
|---|---|
| **Version control for the database** | Every schema change is tracked exactly like application code in Git |
| **Idempotent execution** | Running `liquibase update` 100 times is safe — it only applies what's new |
| **Audit trail** | `DATABASECHANGELOG` records who changed what and when — critical for HIPAA compliance at Zakipoint |
| **Rollback built-in** | Can undo changes safely with `rollback-count` or tag-based rollback |
| **Context filtering** | Dev seed data never accidentally runs in production |
| **Concurrent safety** | The lock table prevents two CI/CD pipelines from running migrations simultaneously |
| **Multi-format support** | Works with SQL, XML, YAML, or JSON changelogs |
| **Cross-database** | Same changelogs work on MySQL, PostgreSQL, Oracle, SQL Server |

### Cons

| Disadvantage | What it means in practice |
|---|---|
| **Java dependency** | Liquibase requires a JVM — adds overhead to minimal environments |
| **Immutable changesets** | Once a changeset is deployed you can never edit it — you must add a new one |
| **Lock can get stuck** | If Liquibase crashes mid-run, the lock must be manually released |
| **Learning curve** | The `runAlways` / `runOnChange` / context system confuses developers at first |
| **Checksum rigidity** | Reformatting or adding a comment to a deployed changeset breaks the checksum |
| **Rollback limitations** | Not all SQL operations are automatically reversible (e.g., `DROP COLUMN` loses data) |
| **Verbose XML** | The master changelog XML format is noisy compared to Flyway's plain file naming |

---

## 13. Liquibase vs Flyway

Both tools solve the same problem. The choice depends on team size and complexity.

| Feature | Liquibase | Flyway |
|---|---|---|
| Formats | SQL, XML, YAML, JSON | SQL, Java |
| Rollback | Built-in (free tier) | Manual scripts / paid tier |
| `runOnChange` | Yes | No |
| `runAlways` | Yes | No |
| Context filtering | Yes | No |
| Learning curve | Steeper | Easier |
| Best for | Complex, multi-environment enterprise projects | Simpler projects with SQL-only migrations |

For Zakipoint Health — with multiple environments, HIPAA audit requirements, and a team of DBAs — Liquibase is the better fit.

---

## 14. Troubleshooting

### `liquibase: command not found`

Liquibase is installed but not on the system PATH.

```bash
# Add to PATH permanently
echo 'export PATH="$HOME/liquibase:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
liquibase --version
```

New terminal windows will automatically have `liquibase` available after this.

### `Plugin 'mysql_native_password' is not loaded`

MySQL 8.4 removed this plugin. Use `caching_sha2_password`:

```bash
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'yourpassword'; FLUSH PRIVILEGES;"
```

### `Access denied for user 'root'@'localhost'`

MySQL root is using socket authentication. Either connect via `sudo mysql` or switch to password auth (see above).

### `Checksum mismatch` validation error

You edited a changeset that was already deployed. **Never do this.** Options:
- In development only: `liquibase clear-checksums` then `liquibase changelog-sync`
- Correct approach: create a new changeset that makes the additional change

### Lock stuck (`DATABASECHANGELOGLOCK` shows `LOCKED=1`)

```bash
liquibase release-locks
```

Or directly in MySQL:
```sql
UPDATE DATABASECHANGELOGLOCK SET LOCKED=0, LOCKGRANTED=NULL, LOCKEDBY=NULL WHERE ID=1;
```

---

## 15. Command Reference

| Command | What it does |
|---|---|
| `liquibase update` | Apply all pending changesets |
| `liquibase update --contexts=dev,test` | Apply only changesets matching context |
| `liquibase update-sql` | Show SQL that would run — dry run |
| `liquibase status --verbose` | List pending (not-yet-run) changesets |
| `liquibase history` | Show all changesets that have been applied |
| `liquibase validate` | Check changelog files for syntax errors |
| `liquibase rollback-count 1` | Roll back the last N changesets |
| `liquibase rollback --tag=v1.0` | Roll back to a tagged state |
| `liquibase rollback-count-sql 1` | Preview rollback SQL without executing |
| `liquibase tag v1.0` | Tag the current database state |
| `liquibase diff` | Compare the database against the changelog |
| `liquibase generate-changelog` | Reverse-engineer a changelog from an existing DB |
| `liquibase changelog-sync` | Mark all changesets as executed without running SQL |
| `liquibase clear-checksums` | Reset all stored checksums (dev only) |
| `liquibase release-locks` | Release a stuck lock |
| `liquibase db-doc docs/` | Generate HTML documentation of the schema |

---

*Prepared by Aaryan Baidhya — DBA Intern, Zakipoint Health*  
*Under guidance of Shrawan Panthi (Gurudev)*

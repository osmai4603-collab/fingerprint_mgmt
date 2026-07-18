-- ============================================================
-- Fingerprint Backend Database Schema
-- Migration: init_tables.sql (Revised)
-- ============================================================

-- ============================================================
-- 1. shifts
-- ============================================================
CREATE TABLE shifts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  cut_off_time TIME,
  weekend_days INTEGER[],
  in_grace_period_mins INTEGER NOT NULL DEFAULT 0
    CONSTRAINT chk_shifts_grace_in CHECK (in_grace_period_mins >= 0),
  out_grace_period_mins INTEGER NOT NULL DEFAULT 0
    CONSTRAINT chk_shifts_grace_out CHECK (out_grace_period_mins >= 0),
  min_overtime_mins INTEGER NOT NULL DEFAULT 0
    CONSTRAINT chk_shifts_min_ot CHECK (min_overtime_mins >= 0)
);

-- ============================================================
-- 2. biometric_devices
-- ============================================================
CREATE TABLE biometric_devices (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  device_type VARCHAR(100) NOT NULL,
  ip_address VARCHAR(50) NOT NULL UNIQUE,
  port INTEGER NOT NULL DEFAULT 4370
    CONSTRAINT chk_bd_port CHECK (port BETWEEN 1 AND 65535),
  is_online BOOLEAN NOT NULL DEFAULT false,
  last_sync TIMESTAMP,
  last_request_date DATE
);

-- ============================================================
-- 3. employees
-- ============================================================
CREATE TABLE employees (
  uid SERIAL PRIMARY KEY,
  employee_id VARCHAR(100) NOT NULL UNIQUE,
  name VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'user'
    CONSTRAINT chk_employees_role CHECK (role IN ('admin', 'user')),
  password VARCHAR(255),
  group_id VARCHAR(100),
  card_no INTEGER,
  default_shift_id INTEGER REFERENCES shifts(id) ON DELETE SET NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 4. app_users
-- ============================================================
CREATE TABLE app_users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'viewer'
    CONSTRAINT chk_app_users_role CHECK (role IN ('admin', 'viewer', 'hr')),
  employee_id INTEGER REFERENCES employees(uid) ON DELETE SET NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- 5. employee_fingerprints
-- ============================================================
CREATE TABLE employee_fingerprints (
  id SERIAL PRIMARY KEY,
  employee_id INTEGER NOT NULL REFERENCES employees(uid) ON UPDATE CASCADE ON DELETE CASCADE,
  biometric TEXT NOT NULL,
  finger_index INTEGER NOT NULL,
  CONSTRAINT uq_emp_fingerprint UNIQUE (employee_id, finger_index)
);

-- ============================================================
-- 6. attendance_logs
-- ============================================================
CREATE TABLE attendance_logs (
  id SERIAL PRIMARY KEY,
  employee_id INTEGER REFERENCES employees(uid) ON DELETE SET NULL,
  unrecognized_biometric VARCHAR(255),
  device_id INTEGER REFERENCES biometric_devices(id) ON DELETE SET NULL,
  punch_time TIMESTAMP NOT NULL
);

CREATE INDEX idx_attendance_logs_punch_time ON attendance_logs (punch_time);
CREATE INDEX idx_attendance_logs_employee_punch ON attendance_logs (employee_id, punch_time);

-- ============================================================
-- Trigger: auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_employees_updated_at
  BEFORE UPDATE ON employees
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trg_app_users_updated_at
  BEFORE UPDATE ON app_users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================
-- Default admin app_user (password: admin123)
-- ============================================================
INSERT INTO app_users (username, password_hash, role, is_active)
VALUES ('admin', '$2a$10$nKSo5vF.68Ux2mLWH24D5uqAtkEEfXNqMCcvw69ZcfLikc4RIaw/O', 'admin', true);

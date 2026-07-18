-- Migration: 003_add_last_request_date.sql
-- Add last_request_date column to biometric_devices table

ALTER TABLE biometric_devices ADD COLUMN last_request_date DATE;

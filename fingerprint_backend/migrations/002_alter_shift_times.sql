-- Migration: 002_alter_shift_times.sql
-- Convert start_time and end_time from VARCHAR to TIME

ALTER TABLE shifts
  ALTER COLUMN start_time TYPE TIME USING start_time::TIME,
  ALTER COLUMN end_time TYPE TIME USING end_time::TIME;

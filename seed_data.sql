-- Full seed: 3 shifts, 30 employees, 2 months of attendance logs

TRUNCATE attendance_logs;
DELETE FROM employees;
DELETE FROM shifts;

-- ── Shifts ──
INSERT INTO shifts (id, name, start_time, end_time, weekend_days,
  before_start_time, after_start_time, before_end_time, after_end_time,
  max_attendance_time, is_night_shift, accept_overtime)
VALUES
  (1, 'صباحي', '07:00', '15:00', '{5,6}',
   '00:30', '00:30', '00:00', '00:30', '02:00', false, true),
  (2, 'مسائي', '15:00', '23:00', '{5,6}',
   '00:30', '00:30', '00:00', '00:30', '02:00', false, true),
  (3, 'ليلي', '23:00', '07:00', '{5,6}',
   '00:30', '00:30', '00:00', '00:30', '02:00', true,  true);
SELECT setval('shifts_id_seq', 3);

-- ── 30 employees (10 per shift) ──
INSERT INTO employees (employee_id, name, role, default_shift_id, is_active)
SELECT
  'EMP' || LPAD(g::text, 3, '0'),
  CASE g % 6
    WHEN 0 THEN 'أحمد محمد'
    WHEN 1 THEN 'سارة علي'
    WHEN 2 THEN 'خالد عمر'
    WHEN 3 THEN 'نورة عبدالله'
    WHEN 4 THEN 'فيصل أحمد'
    ELSE 'مريم حسن'
  END || ' ' || g,
  'user',
  CASE
    WHEN g <= 10 THEN 1
    WHEN g <= 20 THEN 2
    ELSE 3
  END,
  true
FROM generate_series(1, 30) g;

INSERT INTO biometric_devices (id, name, device_type, ip_address, port, is_online)
VALUES (1, 'الجهاز الرئيسي', 'zkteco_k40', '192.168.1.100', 4370, false)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- ── Attendance logs: 90 days × 3 shifts × 10 employees × 2 punches ──
WITH
  emp AS (SELECT uid, default_shift_id FROM employees WHERE is_active),
  days AS (
    SELECT generate_series(
      CURRENT_DATE - INTERVAL '90 days',
      CURRENT_DATE - INTERVAL '1 day',
      '1 day'
    )::date AS day
  ),
  base AS (
    SELECT e.uid, e.default_shift_id, d.day,
      s.*, EXTRACT(ISODOW FROM d.day) AS dow
    FROM emp e
    CROSS JOIN days d
    JOIN shifts s ON s.id = e.default_shift_id
  ),
  workdays AS (
    SELECT * FROM base
    WHERE dow NOT IN (6, 7)
      AND random() < 0.92
  )
INSERT INTO attendance_logs (employee_id, device_id, punch_time)
SELECT
  -- Check-in: within 30 min after shift start
  uid, 1,
  day + start_time::interval + (random() * INTERVAL '30 minutes')
FROM workdays

UNION ALL

SELECT
  -- Check-out: within 30 min before shift end
  uid, 1,
  day + end_time::interval - (random() * INTERVAL '30 minutes')
    + CASE WHEN is_night_shift THEN INTERVAL '1 day' ELSE INTERVAL '0' END
FROM workdays
WHERE random() < 0.95;

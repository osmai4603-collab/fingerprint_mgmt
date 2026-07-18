ALTER TABLE shifts
    DROP COLUMN cut_off_time,
    DROP COLUMN in_grace_period_mins,
    DROP COLUMN out_grace_period_mins,
    DROP COLUMN min_overtime_mins;

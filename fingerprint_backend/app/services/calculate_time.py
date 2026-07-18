from datetime import datetime, time, date as date_type, timedelta
from typing import List, Optional
from enum import Enum


class AttendanceStatus(Enum):
    EARLY = "مبكراً"
    ACCEPTED = "مقبول"
    LATE = "متأخر"
    ABSENT = "غائب"


class CalculateTime:
    @staticmethod
    def _merge_time_with_date(
        time_val: time,
        date_val: date_type,
        is_night_shift: bool = False,
        shift_start_hour: int = 0,
    ) -> datetime:
        merged = datetime(
            date_val.year, date_val.month, date_val.day,
            time_val.hour, time_val.minute, time_val.second,
        )
        if is_night_shift and time_val.hour < shift_start_hour and time_val.hour < 12:
            merged += timedelta(days=1)
        return merged

    @staticmethod
    def find_matching_timestamp(
        timestamps: List[datetime],
        date_val: date_type,
        shift_start_time: Optional[time],
        max_attendance_time: Optional[time],
    ) -> Optional[datetime]:
        if not timestamps or shift_start_time is None or max_attendance_time is None:
            return None
        shift_start = CalculateTime._merge_time_with_date(shift_start_time, date_val)
        max_attendance = CalculateTime._merge_time_with_date(
            max_attendance_time, date_val,
            is_night_shift=max_attendance_time.hour < shift_start_time.hour,
            shift_start_hour=shift_start_time.hour,
        )
        sorted_ts = sorted(timestamps)
        for ts in sorted_ts:
            if ts == shift_start or (shift_start < ts < max_attendance):
                return ts
        return None

    @staticmethod
    def find_departure_timestamp(
        timestamps: List[datetime],
        date_val: date_type,
        before_shift_end_time: Optional[time],
        after_shift_end_time: Optional[time],
        is_night_shift: bool = False,
        shift_start_hour: int = 0,
    ) -> Optional[datetime]:
        if not timestamps or before_shift_end_time is None or after_shift_end_time is None:
            return None
        before_shift_end = CalculateTime._merge_time_with_date(
            before_shift_end_time, date_val,
            is_night_shift=is_night_shift, shift_start_hour=shift_start_hour,
        )
        after_shift_end = CalculateTime._merge_time_with_date(
            after_shift_end_time, date_val,
            is_night_shift=is_night_shift, shift_start_hour=shift_start_hour,
        )
        sorted_ts = sorted(timestamps)
        for ts in sorted_ts:
            if before_shift_end < ts <= after_shift_end:
                return ts
        return None

    @staticmethod
    def get_attendance_status(
        before_shift_start_time: time,
        official_shift_start_time: time,
        after_shift_start_time: time,
        max_attendance_time: time,
        date_val: date_type,
        timestamp: datetime,
    ) -> AttendanceStatus:
        before_start = CalculateTime._merge_time_with_date(before_shift_start_time, date_val)
        official_start = CalculateTime._merge_time_with_date(official_shift_start_time, date_val)
        after_start = CalculateTime._merge_time_with_date(after_shift_start_time, date_val)
        max_attendance = CalculateTime._merge_time_with_date(max_attendance_time, date_val)

        if before_start <= timestamp < official_start:
            return AttendanceStatus.EARLY
        if official_start <= timestamp < after_start:
            return AttendanceStatus.ACCEPTED
        if after_start <= timestamp < max_attendance:
            return AttendanceStatus.LATE
        return AttendanceStatus.ABSENT

    @staticmethod
    def calculate_working_hours(
        attendance_time: Optional[datetime],
        departure_time: Optional[datetime],
        date_val: date_type,
        shift: object,
    ) -> timedelta:
        if attendance_time is None or departure_time is None:
            return timedelta()

        is_night = shift.is_night_shift
        start_hour = shift.start_time.hour

        att_time = attendance_time.time()
        dep_time = departure_time.time()

        attendance = CalculateTime._merge_time_with_date(
            att_time, date_val,
            is_night_shift=is_night, shift_start_hour=start_hour,
        )
        departure = CalculateTime._merge_time_with_date(
            dep_time, date_val,
            is_night_shift=is_night, shift_start_hour=start_hour,
        )

        before_start = CalculateTime._merge_time_with_date(shift.before_start_time, date_val)
        after_end = CalculateTime._merge_time_with_date(
            shift.after_end_time, date_val,
            is_night_shift=is_night, shift_start_hour=start_hour,
        )
        official_start = CalculateTime._merge_time_with_date(shift.start_time, date_val)
        official_end = CalculateTime._merge_time_with_date(
            shift.end_time, date_val,
            is_night_shift=is_night, shift_start_hour=start_hour,
        )

        if attendance < before_start:
            attendance = before_start
        if departure > after_end:
            departure = after_end

        if departure <= attendance:
            return timedelta()

        total_duration = departure - attendance

        if shift.accept_overtime:
            if attendance < official_start:
                clamped_end = departure if departure < official_start else official_start
                early_overtime = clamped_end - attendance
                total_duration -= early_overtime
            if departure > official_end:
                clamped_start = attendance if attendance > official_end else official_end
                late_overtime = departure - clamped_start
                total_duration -= late_overtime

        if total_duration.total_seconds() < 0:
            return timedelta()
        return total_duration

    @staticmethod
    def calculate_excess_hours(
        departure_time: Optional[datetime],
        date_val: date_type,
        after_shift_end_time: time,
        shift: Optional[object] = None,
    ) -> timedelta:
        if departure_time is None:
            return timedelta()
        if shift is not None and not shift.accept_overtime:
            return timedelta()
        dep_time = departure_time.time()
        departure = CalculateTime._merge_time_with_date(dep_time, date_val)
        after_shift_end = CalculateTime._merge_time_with_date(after_shift_end_time, date_val)
        if departure > after_shift_end:
            return departure - after_shift_end
        return timedelta()

    @staticmethod
    def calculate_absence_hours(
        attendance_time: Optional[datetime],
        departure_time: Optional[datetime],
        date_val: date_type,
        shift: object,
    ) -> timedelta:
        is_night = shift.is_night_shift
        start_hour = shift.start_time.hour

        official_start = CalculateTime._merge_time_with_date(shift.start_time, date_val)
        official_end = CalculateTime._merge_time_with_date(
            shift.end_time, date_val,
            is_night_shift=is_night, shift_start_hour=start_hour,
        )

        official_shift_duration = official_end - official_start

        if attendance_time is None or departure_time is None:
            return official_shift_duration

        att_time = attendance_time.time()
        dep_time = departure_time.time()

        attendance = CalculateTime._merge_time_with_date(
            att_time, date_val,
            is_night_shift=is_night, shift_start_hour=start_hour,
        )
        departure = CalculateTime._merge_time_with_date(
            dep_time, date_val,
            is_night_shift=is_night, shift_start_hour=start_hour,
        )

        overlap_start = attendance if attendance > official_start else official_start
        overlap_end = departure if departure < official_end else official_end

        if overlap_end <= overlap_start:
            return official_shift_duration

        actual_work_in_shift = overlap_end - overlap_start
        absence = official_shift_duration - actual_work_in_shift
        return absence if absence.total_seconds() >= 0 else timedelta()

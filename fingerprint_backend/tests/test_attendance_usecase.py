from datetime import datetime
from app.models.employee import Employee
from app.models.shift import Shift
from app.models.attendance import AttendanceLog
from app.models.attendance_record import AttendanceRecord
from app.usecases.attendance import ProcessAttendanceLogUseCase, GenerateAttendanceReportUseCase

def test_process_attendance_log(db_session):
    # Setup test data
    shift = Shift(
        name="Test Shift",
        start_time="09:00",
        end_time="17:00",
        weekend_days=[5, 6],
        before_start_time="08:00",
        after_start_time="09:15",
        before_end_time="16:45",
        after_end_time="17:00",
        max_attendance_time="10:00",
        is_night_shift=False,
        accept_overtime=True,
    )
    db_session.add(shift)
    db_session.commit()
    db_session.refresh(shift)

    employee = Employee(
        employee_id="TEST001",
        name="Test Employee",
        role="user",
        default_shift_id=shift.id,
        is_active=True
    )
    db_session.add(employee)
    db_session.commit()
    db_session.refresh(employee)

    # Log - IN (late by 20 mins, grace period is 15 mins)
    punch_in_time = datetime(2024, 1, 1, 9, 20)
    log_in = AttendanceLog(
        employee_id=employee.uid,
        punch_time=punch_in_time,
    )
    
    usecase = ProcessAttendanceLogUseCase(db_session)
    record = usecase.execute(log_in)
    
    assert record is not None
    assert record.employee_id == employee.uid  # type: ignore
    assert record.lateness_mins == 20
    assert record.overtime_mins == 0
    
    # Log - OUT (overtime by 45 mins, min is 30 mins)
    punch_out_time = datetime(2024, 1, 1, 17, 45)
    log_out = AttendanceLog(
        employee_id=employee.uid,
        punch_time=punch_out_time,
    )
    
    record2 = usecase.execute(log_out)
    
    assert record2.id == record.id # Should update the same record
    assert record2.lateness_mins == 20
    assert record2.overtime_mins == 45


def test_generate_attendance_report(db_session):
    # Setup test data
    employee = Employee(
        employee_id="TEST002",
        name="Report Employee",
        role="user",
        is_active=True
    )
    db_session.add(employee)
    db_session.commit()
    db_session.refresh(employee)
    
    # Insert a processed record
    record = AttendanceRecord(
        employee_id=employee.uid,
        payroll_period_id=0,
        record_date="2024-01-01",
        total_hours=8.5,
        lateness_mins=10,
        overtime_mins=30
    )
    db_session.add(record)
    db_session.commit()
    
    usecase = GenerateAttendanceReportUseCase(db_session)
    report = usecase.execute(employee.uid, "2024-01-01", "2024-01-02")  # type: ignore
    
    assert report["employee_id"] == employee.uid  # type: ignore
    assert report["total_days"] == 1
    assert report["present_days"] == 1
    assert report["total_hours"] == 8.5
    assert report["total_lateness_mins"] == 10
    assert report["total_overtime_mins"] == 30

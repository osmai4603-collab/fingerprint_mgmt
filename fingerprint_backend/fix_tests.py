import re
import glob

for filename in glob.glob("tests/test_*_api.py"):
    with open(filename, "r") as f:
        content = f.read()

    # Fix endpoints trailing slash
    content = re.sub(r'("/api/[a-z]+)(")', r'\1/\2', content)
    
    # Fix time formats in test_shifts_api
    if "test_shifts_api" in filename:
        content = content.replace('"08:00:00"', '"08:00"')
        content = content.replace('"16:00:00"', '"16:00"')
        content = content.replace('"17:00:00"', '"17:00"')
        content = content.replace('"00:00:00"', '"00:00"')
        content = content.replace('"01:00:00"', '"01:00"')
        content = content.replace('"10:00:00"', '"10:00"')
        content = content.replace('"18:00:00"', '"18:00"')
        
    # Fix device payloads
    if "test_devices_api" in filename:
        content = re.sub(r'"port": \d+,?', '"device_type": "ZK",', content)
        content = re.sub(r'"is_active": True,?', '', content)

    # Fix leaves payloads
    if "test_leaves_api" in filename:
        content = content.replace('"leave_type"', '"type"')
        content = content.replace('"start_date": "2024-05-01",\n        "end_date": "2024-05-05",\n        "reason": "Vacation"', '"target_date": "2024-05-01",\n        "duration_mins": 480')
        content = content.replace('"start_date": "2024-06-01",\n        "end_date": "2024-06-02"', '"target_date": "2024-06-01",\n        "duration_mins": 480')
        content = content.replace('"start_date": "2024-07-01",\n        "end_date": "2024-07-02"', '"target_date": "2024-07-01",\n        "duration_mins": 480')

    # Fix overtime payloads
    if "test_overtime_api" in filename:
        content = content.replace('"date"', '"request_date"')
        
    # Fix payroll periods API url
    if "test_payroll_api" in filename:
        content = content.replace('/api/payroll/', '/api/payroll/periods/')
        content = content.replace('/api/payroll/periods/{period_id}', '/api/payroll/{period_id}/close')
        
    with open(filename, "w") as f:
        f.write(content)

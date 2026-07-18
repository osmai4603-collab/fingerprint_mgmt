with open("tests/test_shifts_api.py", "r") as f:
    c = f.read()

c = c.replace('"cut_off_time": "01:00"', '"cut_off_time": "01:00",\n        "weekend_days": [5, 6]')
c = c.replace('"end_time": "18:00"', '"end_time": "18:00",\n        "cut_off_time": "19:00",\n        "weekend_days": [5, 6]')

with open("tests/test_shifts_api.py", "w") as f:
    f.write(c)

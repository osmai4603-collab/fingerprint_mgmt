import calendar
from datetime import datetime
from struct import unpack


def safe_decode_time(self, t):
    t = unpack("<I", t)[0]
    second = t % 60
    t = t // 60
    minute = t % 60
    t = t // 60
    hour = t % 24
    t = t // 24
    day = t % 31 + 1
    t = t // 31
    month = t % 12 + 1
    t = t // 12
    year = t + 2000
    max_day = calendar.monthrange(year, month)[1]
    day = min(day, max_day)
    return datetime(year, month, day, hour, minute, second)

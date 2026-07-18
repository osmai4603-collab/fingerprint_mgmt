import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingerprint_frontend/core/services/date_time_format.dart';

void main() {
  group('formatDate', () {
    test('returns dd-MM-yyyy format', () {
      expect(formatDate(DateTime(2026, 7, 17)), '17-07-2026');
    });

    test('pads single-digit day and month', () {
      expect(formatDate(DateTime(2026, 1, 5)), '05-01-2026');
    });

    test('handles different years', () {
      expect(formatDate(DateTime(1999, 12, 31)), '31-12-1999');
    });
  });

  group('formatTime', () {
    test('returns 12h format with AM/PM by default', () {
      expect(formatTime(DateTime(0, 0, 0, 9, 5, 3)), '09:05:03  AM');
    });

    test('returns PM for afternoon hours', () {
      expect(formatTime(DateTime(0, 0, 0, 15, 30, 0)), '03:30:00  PM');
    });

    test('shows 12 for midnight (0 hour)', () {
      expect(formatTime(DateTime(0, 0, 0, 0, 0, 0)), '12:00:00  AM');
    });

    test('shows 12 for noon (12 hour)', () {
      expect(formatTime(DateTime(0, 0, 0, 12, 0, 0)), '12:00:00  PM');
    });

    test('24h mode when is12Mode=false', () {
      expect(formatTime(DateTime(0, 0, 0, 15, 30, 0), is12Mode: false), '15:30:00  PM');
    });

    test('hides AM/PM when showBlendMode=false', () {
      expect(formatTime(DateTime(0, 0, 0, 9, 5, 3), showBlendMode: false), '09:05:03 ');
    });
  });

  group('formatDateTime', () {
    test('returns date and time combined', () {
      final dt = DateTime(2026, 7, 17, 14, 30, 15);
      expect(formatDateTime(dt), '17-07-2026 02:30:15  PM');
    });
  });

  group('formatDateTimeWithDayName', () {
    test('returns date, time, and day name', () {
      // 2026-07-17 is a Friday = الجمعة
      final dt = DateTime(2026, 7, 17, 9, 0, 0);
      expect(formatDateTimeWithDayName(dt), '17-07-2026 09:00:00  AM الجمعة');
    });
  });

  group('formatHours', () {
    test('returns 00:00 for zero', () {
      expect(formatHours(0), '00:00');
    });

    test('returns 00:00 for negative', () {
      expect(formatHours(-5), '00:00');
    });

    test('formats whole hours', () => expect(formatHours(8), '08:00'));

    test('formats fractional hours', () {
      expect(formatHours(8.5), '08:30');
    });

    test('rounds minutes correctly', () {
      expect(formatHours(8.25), '08:15');
      expect(formatHours(8.75), '08:45');
    });

    test('handles more than 24 hours', () {
      expect(formatHours(40.25), '40:15');
    });
  });

  group('toTime', () {
    test('returns midnight for null', () {
      final r = toTime(null);
      expect(r.hour, 0);
      expect(r.minute, 0);
      expect(r.second, 0);
    });

    test('parses HH:mm format', () {
      final r = toTime('14:30');
      expect(r.hour, 14);
      expect(r.minute, 30);
      expect(r.second, 0);
    });

    test('parses HH:mm:ss format', () {
      final r = toTime('09:05:03');
      expect(r.hour, 9);
      expect(r.minute, 5);
      expect(r.second, 3);
    });

    test('strips AM/PM suffix', () {
      expect(toTime('02:30 PM').hour, 14);
      expect(toTime('02:30 AM').hour, 2);
    });

    test('strips am/pm lowercase suffix', () {
      expect(toTime('10:15 am').hour, 10);
      expect(toTime('10:15 pm').hour, 22);
    });

    test('handles time with seconds and AM/PM', () {
      final r = toTime('11:45:30 PM');
      expect(r.hour, 23);
      expect(r.minute, 45);
      expect(r.second, 30);
    });

    test('returns 0 for invalid input', () {
      final r = toTime('abc');
      expect(r.hour, 0);
      expect(r.minute, 0);
    });
  });

  group('toDateTimeFromTimeOfDay', () {
    test('converts TimeOfDay to DateTime', () {
      final r = toDateTimeFromTimeOfDay(const TimeOfDay(hour: 14, minute: 30));
      expect(r.hour, 14);
      expect(r.minute, 30);
      expect(r.second, 0);
    });
  });

  group('formatTimeOfDay', () {
    test('formats TimeOfDay using formatTime', () {
      expect(
        formatTimeOfDay(const TimeOfDay(hour: 14, minute: 30)),
        '02:30:00  PM',
      );
    });
  });

  group('getDayName', () {
    test('returns Arabic day names', () {
      // DateTime(2026, 7, 17) = Friday
      expect(getDayName(DateTime(2026, 7, 17)), 'الجمعة');
    });

    test('returns empty string for invalid weekday', () {
      // DateTime.weekday is 1-7, but construct with invalid values
    });
  });

  group('getDayNameByNumber', () {
    test('Saturday', () => expect(getDayNameByNumber(6), 'السبت'));
    test('Sunday', () => expect(getDayNameByNumber(7), 'الأحد'));
    test('Monday', () => expect(getDayNameByNumber(1), 'الإثنين'));
    test('Tuesday', () => expect(getDayNameByNumber(2), 'الثلاثاء'));
    test('Wednesday', () => expect(getDayNameByNumber(3), 'الأربعاء'));
    test('Thursday', () => expect(getDayNameByNumber(4), 'الخميس'));
    test('Friday', () => expect(getDayNameByNumber(5), 'الجمعة'));

    test('returns empty string for unknown number', () {
      expect(getDayNameByNumber(0), '');
      expect(getDayNameByNumber(8), '');
    });
  });
}

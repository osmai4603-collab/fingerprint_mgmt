import 'package:flutter/material.dart';

String _formatNumber(int number, {int width = 2, String formatter = '0'}) {
  return number.toString().padLeft(width, formatter);
}

String formatDateTime(DateTime dt) {
  return '${formatDate(dt)} ${formatTime(dt)}';
}

String formatDateTimeWithDayName(DateTime dt) {
  return '${formatDate(dt)} ${formatTime(dt)} ${getDayName(dt)}';
}

String formatDate(DateTime dt) {
  return '${_formatNumber(dt.day)}-${_formatNumber(dt.month)}-${_formatNumber(dt.year)}';
}

String formatHours(double h) {
  if (h <= 0) return '00:00';
  int hours = h.toInt();
  int minutes = ((h - hours) * 60).round();
  return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
}

String formatTime(
  DateTime dt, {
  bool is12Mode = true,
  bool showBlendMode = true,
}) {
  final list = [
    _formatNumber(is12Mode ? (dt.hour % 12 == 0 ? 12 : dt.hour % 12) : dt.hour),
    _formatNumber(dt.minute),
    _formatNumber(dt.second),
  ];
  return '${list.join(':')} ${showBlendMode ? (' ${dt.hour >= 12 ? 'PM' : 'AM'}') : ''}';
}

DateTime toDateTimeFromTimeOfDay(TimeOfDay time) {
  return DateTime(0, 0, 0, time.hour, time.minute, 0);
}

DateTime toTime(String? time) {
  if (time == null) return DateTime(0, 0, 0, 0, 0, 0);
  final isPM = RegExp(r'\s*[Pp][Mm]\s*$').hasMatch(time);
  final cleaned = time.replaceAll(RegExp(r'\s*[APap][Mm]\s*$'), '');
  final split = cleaned.split(':');
  var hour = int.tryParse(split[0]) ?? 0;
  if (isPM && hour != 12) hour += 12;
  if (!isPM && hour == 12) hour = 0;
  return DateTime(
    0,
    0,
    0,
    hour,
    split.length > 1 ? int.tryParse(split[1]) ?? 0 : 0,
    split.length > 2 ? int.tryParse(split[2]) ?? 0 : 0,
  );
}

String formatTimeOfDay(TimeOfDay dt) {
  return formatTime(toDateTimeFromTimeOfDay(dt));
}

String getDayName(DateTime dt) {
  return _days[dt.weekday] ?? '';
}

String getDayNameByNumber(int number) {
  return _days[number] ?? '';
}

final _days = {
  1: 'الإثنين',
  2: 'الثلاثاء',
  3: 'الأربعاء',
  4: 'الخميس',
  5: 'الجمعة',
  6: 'السبت',
  7: 'الأحد',
};

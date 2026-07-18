/// Represents a day of the week using PostgreSQL DOW convention:
/// 0 = Sunday, 1 = Monday, ..., 6 = Saturday.
enum WeekDays {
  sunday(0),
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6);

  final int value;
  const WeekDays(this.value);

  static WeekDays fromValue(int value) {
    return WeekDays.values.firstWhere(
      (d) => d.value == value,
      orElse: () => WeekDays.sunday,
    );
  }

  static List<WeekDays> fromValues(List<int> values) {
    return values.map(fromValue).toList();
  }

  static List<int> toValues(List<WeekDays> days) {
    return days.map((d) => d.value).toList();
  }
}

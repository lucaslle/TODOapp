/// A calendar day, the unit everything in Cadence is filed under.
///
/// Days are compared and stored as `yyyy-MM-dd` strings so that a task, a log
/// entry and a calendar cell all agree on what "the same day" means, without
/// any timezone arithmetic leaking into the domain.
extension type const DayKey(String value) implements Object {
  factory DayKey.fromDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return DayKey('${date.year}-$month-$day');
  }

  static DayKey today() => DayKey.fromDate(DateTime.now());

  DateTime get date => DateTime.parse(value);

  /// Monday is 0, Sunday is 6 — the order the week is drawn in.
  int get weekdayIndex => date.weekday - 1;

  DayKey shift(int days) => DayKey.fromDate(date.add(Duration(days: days)));

  DayKey get previous => shift(-1);

  bool isBefore(DayKey other) => value.compareTo(other.value) < 0;

  bool isAfter(DayKey other) => value.compareTo(other.value) > 0;

  /// Whole days from this day to [other], negative when [other] is earlier.
  int daysUntil(DayKey other) => other.date.difference(date).inDays;
}

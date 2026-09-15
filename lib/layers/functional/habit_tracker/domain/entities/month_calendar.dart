import 'package:equatable/equatable.dart';

enum DayCellStatus {
  /// Everything the day asked for was closed.
  full,

  /// Some of it was closed.
  partial,

  /// The day asked nothing, or nothing was closed.
  rest,

  /// Not yet.
  upcoming,
}

class DayCell extends Equatable {
  const DayCell({
    required this.dayNumber,
    required this.status,
    required this.isToday,
  });

  final int dayNumber;
  final DayCellStatus status;
  final bool isToday;

  @override
  List<Object?> get props => <Object?>[dayNumber, status, isToday];
}

/// One month of squares, plus the blanks that align the first day under its
/// weekday column.
class MonthCalendar extends Equatable {
  const MonthCalendar({
    required this.year,
    required this.month,
    required this.leadingBlanks,
    required this.cells,
  });

  const MonthCalendar.empty()
    : year = 0,
      month = 1,
      leadingBlanks = 0,
      cells = const <DayCell>[];

  final int year;
  final int month;
  final int leadingBlanks;
  final List<DayCell> cells;

  @override
  List<Object?> get props => <Object?>[year, month, leadingBlanks, cells];
}

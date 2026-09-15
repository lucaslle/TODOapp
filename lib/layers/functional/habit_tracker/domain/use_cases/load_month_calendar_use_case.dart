import '../entities/day_key.dart';
import '../entities/day_log.dart';
import '../entities/month_calendar.dart';
import '../entities/task.dart';
import '../gateways/day_log_gateway.dart';
import '../gateways/task_gateway.dart';

/// Builds the current month grid. Today is read live, past days from their
/// logs, and a day with no log at all reads as rest rather than as a miss.
class LoadMonthCalendarUseCase {
  const LoadMonthCalendarUseCase({
    required DayLogGateway dayLogGateway,
    required TaskGateway taskGateway,
  }) : _dayLogGateway = dayLogGateway,
       _taskGateway = taskGateway;

  final DayLogGateway _dayLogGateway;
  final TaskGateway _taskGateway;

  Future<MonthCalendar> call({List<Task>? todayTasks}) async {
    final DateTime now = DateTime.now();
    final DayKey today = DayKey.fromDate(now);
    final DateTime monthStart = DateTime(now.year, now.month);
    final int daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final List<DayLog> logs = await _dayLogGateway.logsBetween(
      DayKey.fromDate(monthStart),
      DayKey.fromDate(DateTime(now.year, now.month, daysInMonth)),
    );
    final Map<String, DayLog> logsByDay = <String, DayLog>{
      for (final DayLog log in logs) log.day.value: log,
    };

    final List<Task> tasks =
        todayTasks ?? await _taskGateway.tasksForDay(today);
    final int completedToday = tasks.where((Task task) => task.isDone).length;

    final List<DayCell> cells = <DayCell>[];
    for (int dayNumber = 1; dayNumber <= daysInMonth; dayNumber++) {
      final DayKey day = DayKey.fromDate(
        DateTime(now.year, now.month, dayNumber),
      );
      final bool isToday = day.value == today.value;

      cells.add(
        DayCell(
          dayNumber: dayNumber,
          isToday: isToday,
          status: isToday
              ? _statusFor(
                  completedCount: completedToday,
                  plannedCount: tasks.length,
                )
              : day.isAfter(today)
              ? DayCellStatus.upcoming
              : _statusForLog(logsByDay[day.value]),
        ),
      );
    }

    return MonthCalendar(
      year: now.year,
      month: now.month,
      leadingBlanks: DayKey.fromDate(monthStart).weekdayIndex,
      cells: cells,
    );
  }

  DayCellStatus _statusForLog(DayLog? log) {
    if (log == null) return DayCellStatus.rest;
    if (log.isFullyDone) return DayCellStatus.full;
    if (log.isPartiallyDone || log.isFrozen) return DayCellStatus.partial;
    return DayCellStatus.rest;
  }

  DayCellStatus _statusFor({
    required int completedCount,
    required int plannedCount,
  }) {
    if (plannedCount > 0 && completedCount >= plannedCount) {
      return DayCellStatus.full;
    }
    if (completedCount > 0) return DayCellStatus.partial;
    return DayCellStatus.rest;
  }
}

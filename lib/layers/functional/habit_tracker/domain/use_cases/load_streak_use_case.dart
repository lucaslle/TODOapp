import '../entities/day_key.dart';
import '../entities/day_log.dart';
import '../entities/streak_summary.dart';
import '../entities/task.dart';
import '../gateways/day_log_gateway.dart';
import '../gateways/task_gateway.dart';

/// Counts the run of days kept alive.
///
/// Today is read from the live tasks rather than a log, because it has not
/// been closed yet: a day with nothing done yet does not break the run, it is
/// simply not counted until midnight.
class LoadStreakUseCase {
  const LoadStreakUseCase({
    required DayLogGateway dayLogGateway,
    required TaskGateway taskGateway,
  }) : _dayLogGateway = dayLogGateway,
       _taskGateway = taskGateway;

  final DayLogGateway _dayLogGateway;
  final TaskGateway _taskGateway;

  Future<StreakSummary> call({List<Task>? todayTasks}) async {
    final DayKey today = DayKey.today();
    final List<Task> tasks =
        todayTasks ?? await _taskGateway.tasksForDay(today);
    final bool isTodayCounted = tasks.any((Task task) => task.isDone);

    final List<DayLog> logs = await _dayLogGateway.allLogs();
    final Map<String, DayLog> logsByDay = <String, DayLog>{
      for (final DayLog log in logs) log.day.value: log,
    };

    final int freezesUsed = await _dayLogGateway.freezesUsedInMonthOf(today);

    return StreakSummary(
      currentDays: _currentRun(
        logsByDay: logsByDay,
        today: today,
        isTodayCounted: isTodayCounted,
      ),
      recordDays: _record(
        logs: logs,
        today: today,
        isTodayCounted: isTodayCounted,
      ),
      freezesLeft: (StreakSummary.freezesPerMonth - freezesUsed).clamp(
        0,
        StreakSummary.freezesPerMonth,
      ),
      isTodayCounted: isTodayCounted,
    );
  }

  int _currentRun({
    required Map<String, DayLog> logsByDay,
    required DayKey today,
    required bool isTodayCounted,
  }) {
    int run = isTodayCounted ? 1 : 0;

    for (int offset = 1; offset <= 3650; offset++) {
      final DayLog? log = logsByDay[today.shift(-offset).value];
      if (log == null) break;
      if (log.isRestDay) continue;
      if (!log.keepsStreakAlive) break;
      run++;
    }
    return run;
  }

  int _record({
    required List<DayLog> logs,
    required DayKey today,
    required bool isTodayCounted,
  }) {
    final List<DayLog> ordered = List<DayLog>.of(logs)
      ..sort((DayLog a, DayLog b) => a.day.value.compareTo(b.day.value));

    int best = 0;
    int run = 0;
    for (final DayLog log in ordered) {
      if (log.isRestDay) continue;
      if (log.keepsStreakAlive) {
        run++;
        if (run > best) best = run;
      } else {
        run = 0;
      }
    }

    final int runIncludingToday = isTodayCounted ? run + 1 : run;
    return runIncludingToday > best ? runIncludingToday : best;
  }
}

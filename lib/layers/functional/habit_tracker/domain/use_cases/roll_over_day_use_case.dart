import '../entities/daily_quest.dart';
import '../entities/day_key.dart';
import '../entities/day_log.dart';
import '../entities/routine.dart';
import '../entities/streak_summary.dart';
import '../entities/task.dart';
import '../entities/user_preferences.dart';
import '../gateways/day_log_gateway.dart';
import '../gateways/routine_gateway.dart';
import '../gateways/task_gateway.dart';
import '../gateways/user_preferences_gateway.dart';
import 'generate_routine_tasks_use_case.dart';

/// Brings the app up to the current day.
///
/// Every day that went by since the last launch is closed into a [DayLog] —
/// spending a freeze when the day was missed — open one-off tasks are pulled
/// forward, and today's routine steps are printed. Running it twice on the
/// same day does nothing, so it is safe to call on every launch and resume.
class RollOverDayUseCase {
  const RollOverDayUseCase({
    required TaskGateway taskGateway,
    required RoutineGateway routineGateway,
    required DayLogGateway dayLogGateway,
    required UserPreferencesGateway preferencesGateway,
    required GenerateRoutineTasksUseCase generateRoutineTasks,
  }) : _taskGateway = taskGateway,
       _routineGateway = routineGateway,
       _dayLogGateway = dayLogGateway,
       _preferencesGateway = preferencesGateway,
       _generateRoutineTasks = generateRoutineTasks;

  final TaskGateway _taskGateway;
  final RoutineGateway _routineGateway;
  final DayLogGateway _dayLogGateway;
  final UserPreferencesGateway _preferencesGateway;
  final GenerateRoutineTasksUseCase _generateRoutineTasks;

  /// Guard against a first launch after a long pause writing hundreds of logs.
  static const int _maxDaysClosedAtOnce = 120;

  Future<void> call() async {
    final UserPreferences preferences = await _preferencesGateway.read();
    final DayKey today = DayKey.today();
    final DayKey? lastRollover = preferences.lastRolloverDay;

    if (lastRollover != null && !lastRollover.isBefore(today)) return;

    if (lastRollover != null) {
      await _closeDaysBetween(lastRollover, today);
      await _carryOpenTasksForward(today);
    }

    final List<Routine> routines = await _routineGateway.all();
    await _generateRoutineTasks(day: today, routines: routines);

    await _preferencesGateway.write(
      preferences.copyWith(lastRolloverDay: today),
    );
  }

  /// Writes a log for every day in `[from, until)`.
  Future<void> _closeDaysBetween(DayKey from, DayKey until) async {
    final int dayCount = from.daysUntil(until);
    final int firstOffset = dayCount > _maxDaysClosedAtOnce
        ? dayCount - _maxDaysClosedAtOnce
        : 0;

    for (int offset = firstOffset; offset < dayCount; offset++) {
      final DayKey day = from.shift(offset);
      final List<Task> tasks = await _taskGateway.tasksForDay(day);
      final List<Task> completed = tasks
          .where((Task task) => task.isDone)
          .toList();

      final bool needsFreeze = tasks.isNotEmpty && completed.isEmpty;
      final bool isFrozen = needsFreeze && await _hasFreezeLeft(day);

      await _dayLogGateway.upsert(
        DayLog(
          day: day,
          completedCount: completed.length,
          plannedCount: tasks.length,
          xpEarned: completed.fold(
            0,
            (int total, Task task) => total + task.xpReward,
          ),
          isQuestCompleted:
              completed.where((Task task) => task.isRoutineStep).length >=
              DailyQuest.requiredSteps,
          isFrozen: isFrozen,
        ),
      );
    }
  }

  Future<bool> _hasFreezeLeft(DayKey day) async {
    final int used = await _dayLogGateway.freezesUsedInMonthOf(day);
    return used < StreakSummary.freezesPerMonth;
  }

  /// Standalone tasks left open move to today. Routine steps do not: a missed
  /// step belongs to the day that asked for it.
  Future<void> _carryOpenTasksForward(DayKey today) async {
    final List<Task> openTasks = await _taskGateway.openTasksBefore(today);
    for (final Task task in openTasks) {
      if (task.isRoutineStep) continue;
      await _taskGateway.update(
        task.copyWith(day: today, title: task.title),
      );
    }
  }
}

import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_key.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_log.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/routine.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/streak_summary.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/user_preferences.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/gateways/day_log_gateway.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/gateways/reminder_gateway.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/gateways/routine_gateway.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/gateways/task_gateway.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/gateways/user_preferences_gateway.dart';

/// Stand-ins for the sqflite-backed gateways, so the domain can be exercised
/// without a database.
class InMemoryTaskGateway implements TaskGateway {
  InMemoryTaskGateway([List<Task> initialTasks = const <Task>[]]) {
    for (final Task task in initialTasks) {
      tasks[task.id] = task;
      if (task.id >= _nextId) _nextId = task.id + 1;
    }
  }

  final Map<int, Task> tasks = <int, Task>{};
  int _nextId = 1;

  @override
  Future<Task> create(Task task) async {
    final Task stored = task.copyWith().withId(_nextId++);
    tasks[stored.id] = stored;
    return stored;
  }

  @override
  Future<void> deleteById(int id) async => tasks.remove(id);

  @override
  Future<void> deleteRoutineSteps({
    required String routineId,
    required DayKey day,
  }) async {
    tasks.removeWhere(
      (int _, Task task) =>
          task.routineId == routineId && task.day.value == day.value &&
          !task.isDone,
    );
  }

  @override
  Future<bool> hasAnyTaskOn(DayKey day) async =>
      tasks.values.any((Task task) => task.day.value == day.value);

  @override
  Future<List<Task>> openTasksBefore(DayKey day) async => tasks.values
      .where((Task task) => task.day.isBefore(day) && !task.isDone)
      .toList();

  @override
  Future<List<Task>> tasksBetween(DayKey from, DayKey to) async =>
      tasks.values
          .where(
            (Task task) => !task.day.isBefore(from) && !task.day.isAfter(to),
          )
          .toList()
        ..sort((Task a, Task b) => a.day.value.compareTo(b.day.value));

  @override
  Future<List<Task>> tasksForDay(DayKey day) async =>
      tasks.values.where((Task task) => task.day.value == day.value).toList()
        ..sort((Task a, Task b) => a.sortIndex.compareTo(b.sortIndex));

  @override
  Future<void> update(Task task) async => tasks[task.id] = task;
}

extension on Task {
  Task withId(int id) => Task(
    id: id,
    day: day,
    title: title,
    list: list,
    xpReward: xpReward,
    whenLabel: whenLabel,
    repeatLabel: repeatLabel,
    note: note,
    sortIndex: sortIndex,
    routineId: routineId,
    isDone: isDone,
    completedAt: completedAt,
  );
}

class InMemoryRoutineGateway implements RoutineGateway {
  InMemoryRoutineGateway([List<Routine> initialRoutines = const <Routine>[]]) {
    for (final Routine routine in initialRoutines) {
      routines[routine.id] = routine;
    }
  }

  final Map<String, Routine> routines = <String, Routine>{};

  @override
  Future<List<Routine>> all() async => routines.values.toList();

  @override
  Future<void> deleteById(String routineId) async => routines.remove(routineId);

  @override
  Future<void> save(Routine routine) async => routines[routine.id] = routine;

  @override
  Future<void> setEnabled({
    required String routineId,
    required bool isEnabled,
  }) async {
    final Routine? routine = routines[routineId];
    if (routine == null) return;
    routines[routineId] = routine.copyWith(isEnabled: isEnabled);
  }
}

class InMemoryDayLogGateway implements DayLogGateway {
  InMemoryDayLogGateway([List<DayLog> initialLogs = const <DayLog>[]]) {
    for (final DayLog log in initialLogs) {
      logs[log.day.value] = log;
    }
  }

  final Map<String, DayLog> logs = <String, DayLog>{};

  @override
  Future<List<DayLog>> allLogs() async => logs.values.toList();

  @override
  Future<int> freezesUsedInMonthOf(DayKey day) async {
    final String month = day.value.substring(0, 7);
    return logs.values
        .where(
          (DayLog log) => log.isFrozen && log.day.value.startsWith(month),
        )
        .length;
  }

  @override
  Future<List<DayLog>> logsBetween(DayKey from, DayKey to) async => logs.values
      .where((DayLog log) => !log.day.isBefore(from) && !log.day.isAfter(to))
      .toList();

  @override
  Future<void> upsert(DayLog log) async => logs[log.day.value] = log;
}

class InMemoryUserPreferencesGateway implements UserPreferencesGateway {
  InMemoryUserPreferencesGateway([
    this.preferences = const UserPreferences.initial(),
  ]);

  UserPreferences preferences;

  @override
  Future<UserPreferences> read() async => preferences;

  @override
  Future<void> write(UserPreferences updated) async => preferences = updated;
}

class RecordingReminderGateway implements ReminderGateway {
  int? lastOpenTaskCount;
  bool? lastIsEnabled;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> syncEveningReminder({
    required bool isEnabled,
    required int openTaskCount,
  }) async {
    lastIsEnabled = isEnabled;
    lastOpenTaskCount = openTaskCount;
  }
}

/// A log for a day that was fully closed.
DayLog completedLog(DayKey day, {int completed = 2, int planned = 2}) => DayLog(
  day: day,
  completedCount: completed,
  plannedCount: planned,
  xpEarned: completed * 15,
  isQuestCompleted: false,
  isFrozen: false,
);

/// A log for a day that asked for something and got nothing.
DayLog missedLog(DayKey day, {bool isFrozen = false}) => DayLog(
  day: day,
  completedCount: 0,
  plannedCount: 3,
  xpEarned: 0,
  isQuestCompleted: false,
  isFrozen: isFrozen,
);

/// A day that asked nothing at all.
DayLog restLog(DayKey day) => DayLog(
  day: day,
  completedCount: 0,
  plannedCount: 0,
  xpEarned: 0,
  isQuestCompleted: false,
  isFrozen: false,
);

StreakSummary noStreak() => const StreakSummary(
  currentDays: 0,
  recordDays: 0,
  freezesLeft: StreakSummary.freezesPerMonth,
  isTodayCounted: false,
);

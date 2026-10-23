import 'package:cadence/layers/functional/habit_tracker/domain/entities/daily_quest.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_key.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_log.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/habit_stats.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/streak_summary.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/user_preferences.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/generate_routine_tasks_use_case.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/load_stats_use_case.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/load_streak_use_case.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/seed_demo_data_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_gateways.dart';

void main() {
  late InMemoryTaskGateway tasks;
  late InMemoryRoutineGateway routines;
  late InMemoryDayLogGateway dayLogs;
  late InMemoryUserPreferencesGateway preferences;
  late SeedDemoDataUseCase seed;

  final DayKey today = DayKey.today();

  setUp(() {
    tasks = InMemoryTaskGateway();
    routines = InMemoryRoutineGateway();
    dayLogs = InMemoryDayLogGateway();
    preferences = InMemoryUserPreferencesGateway();
    seed = SeedDemoDataUseCase(
      taskGateway: tasks,
      routineGateway: routines,
      dayLogGateway: dayLogs,
      preferencesGateway: preferences,
      generateRoutineTasks: GenerateRoutineTasksUseCase(taskGateway: tasks),
    );
  });

  test('fills eight weeks of history and marks today as rolled over', () async {
    await seed();

    expect(routines.routines.length, 3);
    expect(dayLogs.logs.length, SeedDemoDataUseCase.historyDays);
    expect(preferences.preferences.displayName, SeedDemoDataUseCase.displayName);
    expect(preferences.preferences.lastRolloverDay, today);
    expect(preferences.preferences.hasCompletedOnboarding, isFalse);

    final List<Task> todayTasks = await tasks.tasksForDay(today);
    expect(todayTasks.where((Task task) => task.isDone), isNotEmpty);
    expect(todayTasks.where((Task task) => !task.isDone), isNotEmpty);
  });

  test('pays exactly the XP of what was closed, quest bonuses included', () async {
    await seed();

    final int earned = tasks.tasks.values
        .where((Task task) => task.isDone)
        .fold(0, (int total, Task task) => total + task.xpReward);
    final int bonuses =
        dayLogs.logs.values.where((DayLog log) => log.isQuestCompleted).length *
        DailyQuest.bonusXp;

    expect(preferences.preferences.totalXp, earned + bonuses);
    expect(preferences.preferences.lastQuestRewardDay, isNotNull);
  });

  test('writes day logs that agree with the tasks of their day', () async {
    await seed();

    for (final DayLog log in dayLogs.logs.values) {
      final List<Task> dayTasks = await tasks.tasksForDay(log.day);
      expect(log.plannedCount, dayTasks.length, reason: log.day.value);
      expect(
        log.completedCount,
        dayTasks.where((Task task) => task.isDone).length,
        reason: log.day.value,
      );
      expect(
        log.xpEarned,
        dayTasks
            .where((Task task) => task.isDone)
            .fold(0, (int total, Task task) => total + task.xpReward),
        reason: log.day.value,
      );
    }
  });

  test('leaves no one-off task open in the past for the roll-over to drag in', () async {
    await seed();

    final List<Task> stale = await tasks.openTasksBefore(today);
    expect(stale.where((Task task) => !task.isRoutineStep), isEmpty);
  });

  test('gives a 24-day streak, a 31-day record and one freeze spent', () async {
    await seed();

    final StreakSummary streak = await LoadStreakUseCase(
      dayLogGateway: dayLogs,
      taskGateway: tasks,
    )();

    expect(streak.currentDays, 24);
    expect(streak.recordDays, 31);
    expect(streak.isTodayCounted, isTrue);
    expect(
      dayLogs.logs.values.where((DayLog log) => log.isFrozen).length,
      1,
    );
  });

  test('leaves enough history for the stats to say something', () async {
    await seed();

    final HabitStats stats = await LoadStatsUseCase(taskGateway: tasks)();

    expect(stats.consistencyPercent, greaterThan(60));
    expect(stats.consistencyDeltaPoints, greaterThan(0));
    expect(stats.insights, isNotEmpty);
  });

  test('is the same demo twice', () async {
    await seed();
    final List<Task> first = tasks.tasks.values.toList();

    tasks = InMemoryTaskGateway();
    routines = InMemoryRoutineGateway();
    dayLogs = InMemoryDayLogGateway();
    preferences = InMemoryUserPreferencesGateway();
    await SeedDemoDataUseCase(
      taskGateway: tasks,
      routineGateway: routines,
      dayLogGateway: dayLogs,
      preferencesGateway: preferences,
      generateRoutineTasks: GenerateRoutineTasksUseCase(taskGateway: tasks),
    )();

    expect(
      tasks.tasks.values.map((Task task) => '${task.day.value}/${task.title}/${task.isDone}'),
      first.map((Task task) => '${task.day.value}/${task.title}/${task.isDone}'),
    );
  });

  test('runs once', () async {
    await seed();
    final int taskCount = tasks.tasks.length;
    final int totalXp = preferences.preferences.totalXp;

    await seed();

    expect(tasks.tasks.length, taskCount);
    expect(preferences.preferences.totalXp, totalXp);
  });

  test('leaves an install that has already lived alone', () async {
    preferences.preferences = const UserPreferences.initial().copyWith(
      lastRolloverDay: today.previous,
    );

    await seed();

    expect(tasks.tasks, isEmpty);
    expect(routines.routines, isEmpty);
  });
}

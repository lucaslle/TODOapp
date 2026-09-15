import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_key.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_log.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/routine.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/routine_slot.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task_list.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/user_preferences.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/generate_routine_tasks_use_case.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/roll_over_day_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_gateways.dart';

void main() {
  final DayKey today = DayKey.today();
  final DayKey yesterday = today.previous;

  Routine everyDayRoutine() => Routine(
    id: 'r1',
    name: 'Réveil lent',
    weekdays: const <int>{0, 1, 2, 3, 4, 5, 6},
    slot: RoutineSlot.morning,
    steps: const <String>['Étirements', 'Faire le lit'],
    isEnabled: true,
    createdAt: DateTime(2026),
  );

  Task standaloneTask(DayKey day, {required int id, bool isDone = false}) =>
      Task(
        id: id,
        day: day,
        title: 'Appeler le garage',
        list: TaskList.focus,
        xpReward: 15,
        whenLabel: 'Ce soir',
        repeatLabel: 'Une fois',
        note: '',
        sortIndex: id,
        isDone: isDone,
      );

  ({
    RollOverDayUseCase rollOver,
    InMemoryTaskGateway tasks,
    InMemoryDayLogGateway logs,
    InMemoryUserPreferencesGateway preferences,
  })
  buildUseCase({
    required List<Task> tasks,
    required List<Routine> routines,
    DayKey? lastRolloverDay,
    List<DayLog> logs = const <DayLog>[],
  }) {
    final InMemoryTaskGateway taskGateway = InMemoryTaskGateway(tasks);
    final InMemoryDayLogGateway dayLogGateway = InMemoryDayLogGateway(logs);
    final InMemoryUserPreferencesGateway preferencesGateway =
        InMemoryUserPreferencesGateway(
          UserPreferences(
            displayName: '',
            totalXp: 0,
            hasCompletedOnboarding: true,
            isReminderEnabled: true,
            areEffectsEnabled: true,
            lastRolloverDay: lastRolloverDay,
            lastQuestRewardDay: null,
          ),
        );

    return (
      rollOver: RollOverDayUseCase(
        taskGateway: taskGateway,
        routineGateway: InMemoryRoutineGateway(routines),
        dayLogGateway: dayLogGateway,
        preferencesGateway: preferencesGateway,
        generateRoutineTasks: GenerateRoutineTasksUseCase(
          taskGateway: taskGateway,
        ),
      ),
      tasks: taskGateway,
      logs: dayLogGateway,
      preferences: preferencesGateway,
    );
  }

  group('RollOverDayUseCase', () {
    test('the first launch prints today without writing any log', () async {
      final context = buildUseCase(
        tasks: <Task>[],
        routines: <Routine>[everyDayRoutine()],
      );

      await context.rollOver();

      expect(context.tasks.tasks.length, 2);
      expect(context.logs.logs, isEmpty);
      expect(context.preferences.preferences.lastRolloverDay?.value,
          today.value);
    });

    test('running twice on the same day changes nothing', () async {
      final context = buildUseCase(
        tasks: <Task>[],
        routines: <Routine>[everyDayRoutine()],
      );

      await context.rollOver();
      await context.rollOver();

      expect(context.tasks.tasks.length, 2);
    });

    test('yesterday is closed into a log', () async {
      final context = buildUseCase(
        tasks: <Task>[
          standaloneTask(yesterday, id: 1, isDone: true),
          standaloneTask(yesterday, id: 2),
        ],
        routines: <Routine>[],
        lastRolloverDay: yesterday,
      );

      await context.rollOver();

      final DayLog log = context.logs.logs[yesterday.value]!;
      expect(log.completedCount, 1);
      expect(log.plannedCount, 2);
      expect(log.xpEarned, 15);
    });

    test('a fully missed day spends a freeze', () async {
      final context = buildUseCase(
        tasks: <Task>[standaloneTask(yesterday, id: 1)],
        routines: <Routine>[],
        lastRolloverDay: yesterday,
      );

      await context.rollOver();

      expect(context.logs.logs[yesterday.value]!.isFrozen, isTrue);
    });

    test('once the month’s freezes are gone a miss stays a miss', () async {
      final context = buildUseCase(
        tasks: <Task>[standaloneTask(yesterday, id: 1)],
        routines: <Routine>[],
        lastRolloverDay: yesterday,
        logs: <DayLog>[
          missedLog(DayKey.fromDate(DateTime(today.date.year, today.date.month)),
              isFrozen: true),
          missedLog(
            DayKey.fromDate(DateTime(today.date.year, today.date.month, 2)),
            isFrozen: true,
          ),
        ],
      );

      await context.rollOver();

      expect(context.logs.logs[yesterday.value]!.isFrozen, isFalse);
    });

    test('an open one-off task moves to today', () async {
      final context = buildUseCase(
        tasks: <Task>[standaloneTask(yesterday, id: 1)],
        routines: <Routine>[],
        lastRolloverDay: yesterday,
      );

      await context.rollOver();

      expect(context.tasks.tasks[1]!.day.value, today.value);
    });

    test('a missed routine step stays on the day that asked for it', () async {
      final Task missedStep = Task(
        id: 1,
        day: yesterday,
        title: 'Étirements',
        list: TaskList.routine,
        xpReward: 15,
        whenLabel: 'Matin',
        repeatLabel: 'Tous les jours',
        note: '',
        sortIndex: 0,
        routineId: 'r1',
      );
      final context = buildUseCase(
        tasks: <Task>[missedStep],
        routines: <Routine>[everyDayRoutine()],
        lastRolloverDay: yesterday,
      );

      await context.rollOver();

      expect(context.tasks.tasks[1]!.day.value, yesterday.value);
      expect(
        context.tasks.tasks.values
            .where((Task task) => task.day.value == today.value)
            .length,
        2,
        reason: 'la routine réimprime ses deux étapes pour aujourd’hui',
      );
    });
  });
}

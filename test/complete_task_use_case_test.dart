import 'package:cadence/layers/functional/habit_tracker/domain/entities/daily_quest.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_key.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task_list.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/user_preferences.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/complete_task_use_case.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/compute_task_chains_use_case.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/undo_task_completion_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_gateways.dart';

void main() {
  final DayKey today = DayKey.today();

  Task routineStep(int id, {bool isDone = false}) => Task(
    id: id,
    day: today,
    title: 'Étape $id',
    list: TaskList.routine,
    xpReward: TaskList.routine.xpReward,
    whenLabel: 'Matin',
    repeatLabel: 'Tous les jours',
    note: '',
    sortIndex: id,
    routineId: 'r1',
    isDone: isDone,
    completedAt: isDone ? DateTime.now() : null,
  );

  ({
    CompleteTaskUseCase complete,
    InMemoryTaskGateway tasks,
    InMemoryUserPreferencesGateway preferences,
  })
  buildUseCase({required List<Task> tasks, int totalXp = 0}) {
    final InMemoryTaskGateway taskGateway = InMemoryTaskGateway(tasks);
    final InMemoryUserPreferencesGateway preferencesGateway =
        InMemoryUserPreferencesGateway(
          const UserPreferences.initial().copyWith(totalXp: totalXp),
        );

    return (
      complete: CompleteTaskUseCase(
        taskGateway: taskGateway,
        preferencesGateway: preferencesGateway,
        computeTaskChains: ComputeTaskChainsUseCase(taskGateway: taskGateway),
      ),
      tasks: taskGateway,
      preferences: preferencesGateway,
    );
  }

  group('CompleteTaskUseCase', () {
    test('closing a task pays its XP', () async {
      final ({
        CompleteTaskUseCase complete,
        InMemoryTaskGateway tasks,
        InMemoryUserPreferencesGateway preferences,
      })
      context = buildUseCase(tasks: <Task>[routineStep(1)]);

      final TaskCompletionOutcome? outcome = await context.complete(
        context.tasks.tasks[1]!,
      );

      expect(outcome?.xpGained, 15);
      expect(context.preferences.preferences.totalXp, 15);
      expect(context.tasks.tasks[1]!.isDone, isTrue);
    });

    test('closing an already closed task pays nothing', () async {
      final ({
        CompleteTaskUseCase complete,
        InMemoryTaskGateway tasks,
        InMemoryUserPreferencesGateway preferences,
      })
      context = buildUseCase(tasks: <Task>[routineStep(1, isDone: true)]);

      final TaskCompletionOutcome? outcome = await context.complete(
        context.tasks.tasks[1]!,
      );

      expect(outcome, isNull);
      expect(context.preferences.preferences.totalXp, 0);
    });

    test('the third routine step of the day pays the quest bonus', () async {
      final ({
        CompleteTaskUseCase complete,
        InMemoryTaskGateway tasks,
        InMemoryUserPreferencesGateway preferences,
      })
      context = buildUseCase(
        tasks: <Task>[
          routineStep(1, isDone: true),
          routineStep(2, isDone: true),
          routineStep(3),
        ],
      );

      final TaskCompletionOutcome? outcome = await context.complete(
        context.tasks.tasks[3]!,
      );

      expect(outcome?.hasCompletedQuest, isTrue);
      expect(outcome?.xpGained, 15 + DailyQuest.bonusXp);
      expect(outcome?.cheerLine, 'Quête du jour terminée');
    });

    test('the quest bonus is paid at most once a day', () async {
      final ({
        CompleteTaskUseCase complete,
        InMemoryTaskGateway tasks,
        InMemoryUserPreferencesGateway preferences,
      })
      context = buildUseCase(
        tasks: <Task>[
          routineStep(1, isDone: true),
          routineStep(2, isDone: true),
          routineStep(3),
          routineStep(4),
        ],
      );

      await context.complete(context.tasks.tasks[3]!);
      final TaskCompletionOutcome? second = await context.complete(
        context.tasks.tasks[4]!,
      );

      expect(second?.hasCompletedQuest, isFalse);
      expect(second?.xpGained, 15);
    });

    test('crossing a threshold reports the level up', () async {
      final ({
        CompleteTaskUseCase complete,
        InMemoryTaskGateway tasks,
        InMemoryUserPreferencesGateway preferences,
      })
      context = buildUseCase(tasks: <Task>[routineStep(1)], totalXp: 110);

      final TaskCompletionOutcome? outcome = await context.complete(
        context.tasks.tasks[1]!,
      );

      expect(outcome?.hasLeveledUp, isTrue);
      expect(outcome?.level.rank, 2);
    });
  });

  group('UndoTaskCompletionUseCase', () {
    test('reopening a task takes its XP back', () async {
      final InMemoryTaskGateway taskGateway = InMemoryTaskGateway(<Task>[
        routineStep(1, isDone: true),
      ]);
      final InMemoryUserPreferencesGateway preferencesGateway =
          InMemoryUserPreferencesGateway(
            const UserPreferences.initial().copyWith(totalXp: 40),
          );

      await UndoTaskCompletionUseCase(
        taskGateway: taskGateway,
        preferencesGateway: preferencesGateway,
      )(taskGateway.tasks[1]!);

      expect(preferencesGateway.preferences.totalXp, 25);
      expect(taskGateway.tasks[1]!.isDone, isFalse);
      expect(taskGateway.tasks[1]!.completedAt, isNull);
    });

    test('XP never goes below zero', () async {
      final InMemoryTaskGateway taskGateway = InMemoryTaskGateway(<Task>[
        routineStep(1, isDone: true),
      ]);
      final InMemoryUserPreferencesGateway preferencesGateway =
          InMemoryUserPreferencesGateway();

      await UndoTaskCompletionUseCase(
        taskGateway: taskGateway,
        preferencesGateway: preferencesGateway,
      )(taskGateway.tasks[1]!);

      expect(preferencesGateway.preferences.totalXp, 0);
    });
  });
}

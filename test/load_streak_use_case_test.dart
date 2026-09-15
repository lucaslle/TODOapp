import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_key.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_log.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/streak_summary.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task_list.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/use_cases/load_streak_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/in_memory_gateways.dart';

Task taskOn(DayKey day, {required int id, bool isDone = false}) => Task(
  id: id,
  day: day,
  title: 'Tâche $id',
  list: TaskList.routine,
  xpReward: 15,
  whenLabel: 'Matin',
  repeatLabel: 'Tous les jours',
  note: '',
  sortIndex: id,
  routineId: 'r1',
  isDone: isDone,
  completedAt: isDone ? DateTime.now() : null,
);

void main() {
  final DayKey today = DayKey.today();

  LoadStreakUseCase buildUseCase({
    required List<DayLog> logs,
    required List<Task> todayTasks,
  }) => LoadStreakUseCase(
    dayLogGateway: InMemoryDayLogGateway(logs),
    taskGateway: InMemoryTaskGateway(todayTasks),
  );

  group('LoadStreakUseCase', () {
    test('a brand new install has no streak', () async {
      final StreakSummary streak = await buildUseCase(
        logs: <DayLog>[],
        todayTasks: <Task>[],
      )();

      expect(streak.currentDays, 0);
      expect(streak.recordDays, 0);
      expect(streak.isTodayCounted, isFalse);
      expect(streak.freezesLeft, StreakSummary.freezesPerMonth);
    });

    test('today only counts once something has been closed', () async {
      final List<DayLog> logs = <DayLog>[
        completedLog(today.shift(-2)),
        completedLog(today.shift(-1)),
      ];

      final StreakSummary before = await buildUseCase(
        logs: logs,
        todayTasks: <Task>[taskOn(today, id: 1)],
      )();
      expect(before.currentDays, 2, reason: 'les jours passés tiennent seuls');
      expect(before.isTodayCounted, isFalse);

      final StreakSummary after = await buildUseCase(
        logs: logs,
        todayTasks: <Task>[taskOn(today, id: 1, isDone: true)],
      )();
      expect(after.currentDays, 3);
      expect(after.isTodayCounted, isTrue);
    });

    test('a missed day breaks the run', () async {
      final StreakSummary streak = await buildUseCase(
        logs: <DayLog>[
          completedLog(today.shift(-3)),
          missedLog(today.shift(-2)),
          completedLog(today.shift(-1)),
        ],
        todayTasks: <Task>[taskOn(today, id: 1, isDone: true)],
      )();

      expect(streak.currentDays, 2);
    });

    test('a freeze covers a missed day and keeps the run alive', () async {
      final StreakSummary streak = await buildUseCase(
        logs: <DayLog>[
          completedLog(today.shift(-3)),
          missedLog(today.shift(-2), isFrozen: true),
          completedLog(today.shift(-1)),
        ],
        todayTasks: <Task>[taskOn(today, id: 1, isDone: true)],
      )();

      expect(streak.currentDays, 4);
      expect(streak.freezesLeft, StreakSummary.freezesPerMonth - 1);
    });

    test('a day that asked nothing is neutral, not a miss', () async {
      final StreakSummary streak = await buildUseCase(
        logs: <DayLog>[
          completedLog(today.shift(-3)),
          restLog(today.shift(-2)),
          completedLog(today.shift(-1)),
        ],
        todayTasks: <Task>[taskOn(today, id: 1, isDone: true)],
      )();

      expect(streak.currentDays, 3, reason: 'le jour de repos ne compte pas');
    });

    test('the record survives a broken run', () async {
      final StreakSummary streak = await buildUseCase(
        logs: <DayLog>[
          completedLog(today.shift(-6)),
          completedLog(today.shift(-5)),
          completedLog(today.shift(-4)),
          completedLog(today.shift(-3)),
          missedLog(today.shift(-2)),
          completedLog(today.shift(-1)),
        ],
        todayTasks: <Task>[taskOn(today, id: 1, isDone: true)],
      )();

      expect(streak.currentDays, 2);
      expect(streak.recordDays, 4);
    });
  });
}

import 'package:cadence/layers/functional/habit_tracker/data/data_sources/habit_local_data_source.dart';
import 'package:cadence/layers/functional/habit_tracker/data/gateways/day_log_gateway_impl.dart';
import 'package:cadence/layers/functional/habit_tracker/data/gateways/routine_gateway_impl.dart';
import 'package:cadence/layers/functional/habit_tracker/data/gateways/task_gateway_impl.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_key.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/day_log.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/routine.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/routine_slot.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task.dart';
import 'package:cadence/layers/functional/habit_tracker/domain/entities/task_list.dart';
import 'package:cadence/layers/technical/persistence/cadence_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Exercises the real schema and the real SQL against an in-memory SQLite, so
/// a typo in a column name fails here rather than on the phone.
void main() {
  late CadenceDatabase database;
  late HabitLocalDataSource dataSource;
  late TaskGatewayImpl tasks;
  late RoutineGatewayImpl routines;
  late DayLogGatewayImpl dayLogs;

  final DayKey today = DayKey.today();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await databaseFactory.deleteDatabase(
      '${await databaseFactory.getDatabasesPath()}/${CadenceDatabase.fileName}',
    );
    database = CadenceDatabase.instance;
    await database.close();
    dataSource = HabitLocalDataSource(database: database);
    tasks = TaskGatewayImpl(localDataSource: dataSource);
    routines = RoutineGatewayImpl(localDataSource: dataSource);
    dayLogs = DayLogGatewayImpl(localDataSource: dataSource);
  });

  tearDown(() => database.close());

  Task newTask({
    required String title,
    DayKey? day,
    String? routineId,
    bool isDone = false,
  }) => Task(
    id: 0,
    day: day ?? today,
    title: title,
    list: TaskList.home,
    xpReward: TaskList.home.xpReward,
    whenLabel: 'Matin',
    repeatLabel: 'Tous les jours',
    note: 'Deux grandes bouteilles.',
    sortIndex: 1,
    routineId: routineId,
    isDone: isDone,
    completedAt: isDone ? DateTime(2026, 9, 15, 8) : null,
  );

  group('tasks', () {
    test('a task survives a round trip through the database', () async {
      final Task created = await tasks.create(
        newTask(title: 'Remplir les bouteilles', routineId: 'r1'),
      );

      expect(created.id, greaterThan(0));

      final List<Task> stored = await tasks.tasksForDay(today);
      expect(stored, hasLength(1));
      expect(stored.first.title, 'Remplir les bouteilles');
      expect(stored.first.list, TaskList.home);
      expect(stored.first.routineId, 'r1');
      expect(stored.first.note, 'Deux grandes bouteilles.');
      expect(stored.first.isDone, isFalse);
    });

    test('completing a task persists the timestamp', () async {
      final Task created = await tasks.create(newTask(title: 'Faire le lit'));
      final DateTime completedAt = DateTime(2026, 9, 15, 7, 12);

      await tasks.update(
        created.copyWith(isDone: true, completedAt: completedAt),
      );

      final Task reloaded = (await tasks.tasksForDay(today)).single;
      expect(reloaded.isDone, isTrue);
      expect(reloaded.completedAt, completedAt);
    });

    test('open tasks before today are found, closed ones are not', () async {
      await tasks.create(newTask(title: 'Ouverte', day: today.shift(-1)));
      await tasks.create(
        newTask(title: 'Fermée', day: today.shift(-1), isDone: true),
      );
      await tasks.create(newTask(title: 'Aujourd’hui'));

      final List<Task> open = await tasks.openTasksBefore(today);
      expect(open.map((Task task) => task.title), <String>['Ouverte']);
    });

    test('a date range query is inclusive on both ends', () async {
      await tasks.create(newTask(title: 'Avant', day: today.shift(-3)));
      await tasks.create(newTask(title: 'Dedans', day: today.shift(-1)));
      await tasks.create(newTask(title: 'Aujourd’hui'));

      final List<Task> found = await tasks.tasksBetween(
        today.shift(-1),
        today,
      );
      expect(found, hasLength(2));
    });

    test('dropping a routine keeps the steps already closed', () async {
      await tasks.create(newTask(title: 'Étape ouverte', routineId: 'r1'));
      await tasks.create(
        newTask(title: 'Étape faite', routineId: 'r1', isDone: true),
      );

      await tasks.deleteRoutineSteps(routineId: 'r1', day: today);

      final List<Task> left = await tasks.tasksForDay(today);
      expect(left.map((Task task) => task.title), <String>['Étape faite']);
    });
  });

  group('routines', () {
    test('weekdays and steps survive a round trip', () async {
      await routines.save(
        Routine(
          id: 'r1',
          name: 'Réveil lent',
          weekdays: const <int>{0, 2, 4},
          slot: RoutineSlot.evening,
          steps: const <String>['Étirements', 'Grand verre d’eau'],
          isEnabled: true,
          createdAt: DateTime(2026, 9, 15),
        ),
      );

      final Routine stored = (await routines.all()).single;
      expect(stored.name, 'Réveil lent');
      expect(stored.weekdays, <int>{0, 2, 4});
      expect(stored.slot, RoutineSlot.evening);
      expect(stored.steps, <String>['Étirements', 'Grand verre d’eau']);
      expect(stored.isEnabled, isTrue);
    });

    test('saving the same id twice replaces it rather than duplicating', ()
        async {
      final Routine routine = Routine(
        id: 'r1',
        name: 'Réveil lent',
        weekdays: const <int>{0},
        slot: RoutineSlot.morning,
        steps: const <String>['Étirements'],
        isEnabled: true,
        createdAt: DateTime(2026),
      );
      await routines.save(routine);
      await routines.save(routine);

      expect(await routines.all(), hasLength(1));
    });

    test('a routine can be switched off and deleted', () async {
      await routines.save(
        Routine(
          id: 'r1',
          name: 'Réveil lent',
          weekdays: const <int>{0},
          slot: RoutineSlot.morning,
          steps: const <String>['Étirements'],
          isEnabled: true,
          createdAt: DateTime(2026),
        ),
      );

      await routines.setEnabled(routineId: 'r1', isEnabled: false);
      expect((await routines.all()).single.isEnabled, isFalse);

      await routines.deleteById('r1');
      expect(await routines.all(), isEmpty);
    });
  });

  group('day logs', () {
    test('a log is written once per day and counts its freezes', () async {
      await dayLogs.upsert(
        DayLog(
          day: today.shift(-1),
          completedCount: 0,
          plannedCount: 3,
          xpEarned: 0,
          isQuestCompleted: false,
          isFrozen: true,
        ),
      );
      await dayLogs.upsert(
        DayLog(
          day: today.shift(-1),
          completedCount: 1,
          plannedCount: 3,
          xpEarned: 15,
          isQuestCompleted: false,
          isFrozen: false,
        ),
      );

      final List<DayLog> stored = await dayLogs.allLogs();
      expect(stored, hasLength(1));
      expect(stored.single.completedCount, 1);
      expect(await dayLogs.freezesUsedInMonthOf(today.shift(-1)), 0);
    });

    test('freezes are counted per calendar month', () async {
      final DayKey firstOfMonth = DayKey.fromDate(
        DateTime(today.date.year, today.date.month),
      );
      await dayLogs.upsert(
        DayLog(
          day: firstOfMonth,
          completedCount: 0,
          plannedCount: 2,
          xpEarned: 0,
          isQuestCompleted: false,
          isFrozen: true,
        ),
      );
      await dayLogs.upsert(
        DayLog(
          day: firstOfMonth.shift(-40),
          completedCount: 0,
          plannedCount: 2,
          xpEarned: 0,
          isQuestCompleted: false,
          isFrozen: true,
        ),
      );

      expect(await dayLogs.freezesUsedInMonthOf(today), 1);
    });
  });
}

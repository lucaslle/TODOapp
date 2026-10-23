import 'dart:math';

import '../entities/daily_quest.dart';
import '../entities/day_key.dart';
import '../entities/day_log.dart';
import '../entities/routine.dart';
import '../entities/routine_slot.dart';
import '../entities/task.dart';
import '../entities/task_list.dart';
import '../entities/user_preferences.dart';
import '../gateways/day_log_gateway.dart';
import '../gateways/routine_gateway.dart';
import '../gateways/task_gateway.dart';
import '../gateways/user_preferences_gateway.dart';
import 'generate_routine_tasks_use_case.dart';

/// Fills a fresh install with eight weeks of plausible history, so the online
/// demo opens on a lived-in app rather than an empty board.
///
/// Everything is laid down the way the app would have laid it down itself: the
/// tasks are real rows, each day log matches the tasks of its day, and the XP
/// total is exactly what those completions and quest bonuses would have paid.
/// The history is deterministic for a given day, so two visitors see the same
/// demo.
///
/// It only runs on an install that has never rolled a day over — the same
/// signal `SeedStarterRoutinesUseCase` uses — and leaves `lastRolloverDay` set
/// to today, so the starter routines and the roll-over both stand aside.
class SeedDemoDataUseCase {
  const SeedDemoDataUseCase({
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

  static const String displayName = 'Léa';

  /// Closed days before today. With today that makes eight weeks, the window
  /// the Stats screen compares against the eight before.
  static const int historyDays = 55;

  /// The one unprotected miss: it ends the record run and starts the current
  /// one.
  static const int brokenDayOffset = 24;

  /// A miss inside the current run, covered by a freeze.
  static const int frozenDayOffset = 9;

  /// Days ago the running routine was added, so the history shows a habit
  /// that came later than the other two.
  static const int runningRoutineAgeInDays = 34;

  static const int _seed = 2024;
  static const double _errandChance = 0.4;

  static const List<({String title, TaskList list})> _errands =
      <({String title, TaskList list})>[
        (title: 'Courses de la semaine', list: TaskList.home),
        (title: 'Lessive', list: TaskList.home),
        (title: 'Arroser les plantes', list: TaskList.home),
        (title: 'Payer le loyer', list: TaskList.home),
        (title: 'Appeler maman', list: TaskList.family),
        (title: 'Dîner chez Sam', list: TaskList.family),
        (title: 'Cadeau pour Noé', list: TaskList.family),
        (title: 'Avancer le rapport', list: TaskList.focus),
        (title: 'Relire le chapitre 3', list: TaskList.focus),
        (title: 'Préparer la réunion de lundi', list: TaskList.focus),
      ];

  Future<void> call() async {
    final UserPreferences preferences = await _preferencesGateway.read();
    if (preferences.lastRolloverDay != null) return;
    if ((await _routineGateway.all()).isNotEmpty) return;

    final DateTime now = DateTime.now();
    final DayKey today = DayKey.fromDate(now);
    final Random random = Random(_seed);

    final List<Routine> routines = _routines(today);
    for (final Routine routine in routines) {
      await _routineGateway.save(routine);
    }

    int totalXp = 0;
    DayKey? lastQuestRewardDay;

    for (int offset = historyDays; offset >= 1; offset--) {
      final DayKey day = today.shift(-offset);
      final bool isMissed =
          offset == brokenDayOffset || offset == frozenDayOffset;
      final List<Task> tasks = _tasksOf(
        day: day,
        offset: offset,
        routines: routines,
        random: random,
        isMissed: isMissed,
      );
      for (final Task task in tasks) {
        await _taskGateway.create(task);
      }

      final List<Task> completed = tasks
          .where((Task task) => task.isDone)
          .toList();
      final int xpEarned = completed.fold(
        0,
        (int total, Task task) => total + task.xpReward,
      );
      final bool isQuestCompleted =
          completed.where((Task task) => task.isRoutineStep).length >=
          DailyQuest.requiredSteps;

      await _dayLogGateway.upsert(
        DayLog(
          day: day,
          completedCount: completed.length,
          plannedCount: tasks.length,
          xpEarned: xpEarned,
          isQuestCompleted: isQuestCompleted,
          isFrozen: offset == frozenDayOffset,
        ),
      );

      totalXp += xpEarned + (isQuestCompleted ? DailyQuest.bonusXp : 0);
      if (isQuestCompleted) lastQuestRewardDay = day;
    }

    totalXp += await _layOutToday(today: today, now: now, routines: routines);

    await _preferencesGateway.write(
      preferences.copyWith(
        displayName: displayName,
        totalXp: totalXp,
        lastRolloverDay: today,
        lastQuestRewardDay: lastQuestRewardDay,
      ),
    );
  }

  List<Routine> _routines(DayKey today) {
    final DateTime start = today.shift(-historyDays).date;
    return <Routine>[
      Routine(
        id: 'demo-morning',
        name: 'Réveil lent',
        weekdays: const <int>{0, 1, 2, 3, 4},
        slot: RoutineSlot.morning,
        steps: const <String>[
          'Étirements du matin',
          'Faire le lit',
          'Grand verre d’eau',
        ],
        isEnabled: true,
        createdAt: start,
      ),
      Routine(
        id: 'demo-evening',
        name: 'Fermeture du soir',
        weekdays: const <int>{0, 1, 2, 3, 4, 5, 6},
        slot: RoutineSlot.evening,
        steps: const <String>['Lire 20 minutes', 'Préparer demain'],
        isEnabled: true,
        createdAt: start.add(const Duration(milliseconds: 1)),
      ),
      Routine(
        id: 'demo-running',
        name: 'Course à pied',
        weekdays: const <int>{0, 2, 4},
        slot: RoutineSlot.day,
        steps: const <String>['30 minutes de course'],
        isEnabled: true,
        createdAt: today.shift(-runningRoutineAgeInDays).date,
      ),
    ];
  }

  /// The routine steps the day asked for and, some days, an errand. A missed
  /// day keeps its steps and closes none; any other day closes at least one,
  /// so the dice never break the streak by accident.
  List<Task> _tasksOf({
    required DayKey day,
    required int offset,
    required List<Routine> routines,
    required Random random,
    required bool isMissed,
  }) {
    final List<Task> tasks = <Task>[];
    int sortIndex = 0;

    for (final Routine routine in routines) {
      if (DayKey.fromDate(routine.createdAt).isAfter(day)) continue;
      if (!routine.runsOnWeekday(day.weekdayIndex)) continue;

      for (final String step in routine.steps) {
        final bool isDone =
            !isMissed &&
            random.nextDouble() <
                _completionRate(day: day, slot: routine.slot, offset: offset);
        tasks.add(
          Task(
            id: 0,
            day: day,
            title: step,
            list: TaskList.routine,
            xpReward: TaskList.routine.xpReward,
            whenLabel: routine.slot.taskWhenLabel,
            repeatLabel: routine.repeatLabel(),
            note: 'Étape de la routine « ${routine.name} ».',
            sortIndex: routine.slot.sortIndex * 100 + sortIndex++,
            routineId: routine.id,
            isDone: isDone,
            completedAt: isDone
                ? _completedAt(day: day, slot: routine.slot, random: random)
                : null,
          ),
        );
      }
    }

    if (!isMissed && random.nextDouble() < _errandChance) {
      final ({String title, TaskList list}) errand =
          _errands[random.nextInt(_errands.length)];
      tasks.add(
        _errand(
          day: day,
          title: errand.title,
          list: errand.list,
          sortIndex: 900,
          completedAt: _completedAt(day: day, slot: null, random: random),
        ),
      );
    }

    if (!isMissed &&
        tasks.isNotEmpty &&
        tasks.every((Task task) => !task.isDone)) {
      tasks[0] = tasks[0].copyWith(
        isDone: true,
        completedAt: _completedAt(
          day: day,
          slot: RoutineSlot.evening,
          random: random,
        ),
      );
    }

    return tasks;
  }

  /// How likely a step was closed. The last four weeks run tighter than the
  /// four before, so the consistency trend reads as progress; Sunday evenings
  /// slip, so the Stats screen has a weak day to point at.
  double _completionRate({
    required DayKey day,
    required RoutineSlot slot,
    required int offset,
  }) {
    const int recentWeeksInDays = 27;
    if (day.weekdayIndex == 6 && slot == RoutineSlot.evening) return 0.45;
    final double base = offset <= recentWeeksInDays ? 0.9 : 0.78;
    return slot == RoutineSlot.morning ? base + 0.04 : base;
  }

  /// A believable clock time for a completion: in the slot's hours for a
  /// routine step, during the day for an errand.
  DateTime _completedAt({
    required DayKey day,
    required RoutineSlot? slot,
    required Random random,
  }) {
    final (int from, int to) = switch (slot) {
      RoutineSlot.morning => (7 * 60, 8 * 60 + 30),
      RoutineSlot.day => (12 * 60, 14 * 60),
      RoutineSlot.evening => (20 * 60 + 30, 22 * 60 + 30),
      null => (10 * 60, 19 * 60),
    };
    return day.date.add(Duration(minutes: from + random.nextInt(to - from)));
  }

  /// Today is printed by the real generator, then two steps are closed — the
  /// quest at two of three — plus one errand, with three left to do.
  Future<int> _layOutToday({
    required DayKey today,
    required DateTime now,
    required List<Routine> routines,
  }) async {
    int xpEarned = 0;

    await _generateRoutineTasks(day: today, routines: routines);
    final List<Task> steps = await _taskGateway.tasksForDay(today);
    final int closedSteps = steps.length >= DailyQuest.requiredSteps ? 2 : 1;

    int minutesAgo = 95;
    for (final Task step in steps.take(closedSteps)) {
      await _taskGateway.update(
        step.copyWith(
          isDone: true,
          completedAt: _earlierToday(now: now, minutesAgo: minutesAgo),
        ),
      );
      xpEarned += step.xpReward;
      minutesAgo -= 35;
    }

    final Task paidBill = await _taskGateway.create(
      _errand(
        day: today,
        title: 'Payer la facture d’eau',
        list: TaskList.home,
        sortIndex: 900,
        completedAt: _earlierToday(now: now, minutesAgo: 150),
      ),
    );
    xpEarned += paidBill.xpReward;

    const List<({String title, TaskList list})> open =
        <({String title, TaskList list})>[
          (title: 'Courses pour le dîner', list: TaskList.home),
          (title: 'Appeler mamie', list: TaskList.family),
          (title: 'Relire le rapport', list: TaskList.focus),
        ];
    for (int index = 0; index < open.length; index++) {
      await _taskGateway.create(
        _errand(
          day: today,
          title: open[index].title,
          list: open[index].list,
          sortIndex: 901 + index,
          completedAt: null,
        ),
      );
    }

    return xpEarned;
  }

  /// A moment earlier today, never before the day began.
  DateTime _earlierToday({required DateTime now, required int minutesAgo}) {
    final DateTime at = now.subtract(Duration(minutes: minutesAgo));
    final DateTime dayStart = DateTime(now.year, now.month, now.day);
    return at.isBefore(dayStart) ? dayStart.add(const Duration(minutes: 5)) : at;
  }

  /// A one-off task, shaped like `CreateTaskUseCase` shapes them.
  Task _errand({
    required DayKey day,
    required String title,
    required TaskList list,
    required int sortIndex,
    required DateTime? completedAt,
  }) => Task(
    id: 0,
    day: day,
    title: title,
    list: list,
    xpReward: list.xpReward,
    whenLabel: 'Aujourd’hui',
    repeatLabel: 'Une fois',
    note: 'Ajoutée depuis la feuille rapide.',
    sortIndex: sortIndex,
    isDone: completedAt != null,
    completedAt: completedAt,
  );
}

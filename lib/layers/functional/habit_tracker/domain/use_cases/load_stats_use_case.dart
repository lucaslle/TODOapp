import '../entities/day_key.dart';
import '../entities/habit_stats.dart';
import '../entities/task.dart';
import '../gateways/task_gateway.dart';

/// Reads the last eight weeks of tasks and derives the Stats screen from them.
///
/// Every figure here comes from tasks the user actually closed. Insights are
/// only produced once there is enough history to stand behind them, so a fresh
/// install shows fewer lines rather than invented ones.
class LoadStatsUseCase {
  const LoadStatsUseCase({required TaskGateway taskGateway})
    : _taskGateway = taskGateway;

  final TaskGateway _taskGateway;

  static const int _consistencyWindowInDays = 28;
  static const int _minimumCompletionsForTimeInsight = 8;
  static const int _minimumSamplesPerWeekday = 2;
  static const int _weakWeekdayThresholdPercent = 70;

  Future<HabitStats> call() async {
    final DayKey today = DayKey.today();
    final DayKey windowStart = today.shift(-(_consistencyWindowInDays * 2 - 1));
    final List<Task> history = await _taskGateway.tasksBetween(
      windowStart,
      today,
    );

    final DayKey weekStart = today.shift(-today.weekdayIndex);
    final List<Task> weekTasks = history
        .where(
          (Task task) =>
              !task.day.isBefore(weekStart) &&
              !task.day.isAfter(weekStart.shift(6)),
        )
        .toList();
    final List<Task> weekCompleted = weekTasks
        .where((Task task) => task.isDone)
        .toList();

    final int consistencyPercent = _consistencyPercent(
      history: history,
      from: today.shift(-(_consistencyWindowInDays - 1)),
      to: today,
    );
    final int previousConsistencyPercent = _consistencyPercent(
      history: history,
      from: windowStart,
      to: today.shift(-_consistencyWindowInDays),
    );

    return HabitStats(
      weekCompletedCount: weekCompleted.length,
      consistencyPercent: consistencyPercent,
      consistencyDeltaPoints: previousConsistencyPercent == 0
          ? 0
          : consistencyPercent - previousConsistencyPercent,
      weekXp: weekCompleted.fold(
        0,
        (int total, Task task) => total + task.xpReward,
      ),
      weekXpGoal: weekTasks.fold(
        0,
        (int total, Task task) => total + task.xpReward,
      ),
      dailyXp: _dailyXp(weekTasks: weekTasks, weekStart: weekStart),
      insights: _insights(history: history, today: today),
    );
  }

  List<DailyXp> _dailyXp({
    required List<Task> weekTasks,
    required DayKey weekStart,
  }) {
    final List<int> xpByWeekday = List<int>.filled(7, 0);
    for (final Task task in weekTasks) {
      if (!task.isDone) continue;
      final int index = weekStart.daysUntil(task.day);
      if (index < 0 || index > 6) continue;
      xpByWeekday[index] += task.xpReward;
    }
    return List<DailyXp>.generate(
      7,
      (int index) => DailyXp(weekdayIndex: index, xp: xpByWeekday[index]),
    );
  }

  /// Average share of a day's tasks that got closed, over the days that asked
  /// for something. Days with nothing planned are ignored rather than counted
  /// as perfect.
  int _consistencyPercent({
    required List<Task> history,
    required DayKey from,
    required DayKey to,
  }) {
    final Map<String, (int completed, int planned)> byDay =
        <String, (int, int)>{};

    for (final Task task in history) {
      if (task.day.isBefore(from) || task.day.isAfter(to)) continue;
      final (int completed, int planned) current =
          byDay[task.day.value] ?? (0, 0);
      byDay[task.day.value] = (
        current.$1 + (task.isDone ? 1 : 0),
        current.$2 + 1,
      );
    }

    if (byDay.isEmpty) return 0;

    double total = 0;
    for (final (int completed, int planned) in byDay.values) {
      total += completed / planned;
    }
    return (total / byDay.length * 100).round();
  }

  List<TrendInsight> _insights({
    required List<Task> history,
    required DayKey today,
  }) {
    final DayKey from = today.shift(-(_consistencyWindowInDays - 1));
    final List<Task> window = history
        .where((Task task) => !task.day.isBefore(from))
        .toList();

    final List<TrendInsight?> candidates = <TrendInsight?>[
      _timeOfDayInsight(window),
      _weakWeekdayInsight(window),
      _longestHabitInsight(history: history, today: today),
    ];
    return candidates.whereType<TrendInsight>().toList();
  }

  TimeOfDayInsight? _timeOfDayInsight(List<Task> window) {
    final List<DateTime> completions = window
        .where((Task task) => task.isDone && task.completedAt != null)
        .map((Task task) => task.completedAt!)
        .toList();
    if (completions.length < _minimumCompletionsForTimeInsight) return null;

    final int morningCount = completions
        .where((DateTime at) => at.hour < TimeOfDayInsight.cutoffHour)
        .length;
    final int morningPercent = (morningCount / completions.length * 100)
        .round();
    final bool isMorning = morningPercent >= 50;

    return TimeOfDayInsight(
      percent: isMorning ? morningPercent : 100 - morningPercent,
      isMorning: isMorning,
    );
  }

  WeakWeekdayInsight? _weakWeekdayInsight(List<Task> window) {
    final List<int> completed = List<int>.filled(7, 0);
    final List<int> planned = List<int>.filled(7, 0);

    for (final Task task in window) {
      final int weekday = task.day.weekdayIndex;
      planned[weekday]++;
      if (task.isDone) completed[weekday]++;
    }

    int? weakest;
    double weakestRatio = 1;
    for (int weekday = 0; weekday < 7; weekday++) {
      if (planned[weekday] < _minimumSamplesPerWeekday) continue;
      final double ratio = completed[weekday] / planned[weekday];
      if (ratio < weakestRatio) {
        weakestRatio = ratio;
        weakest = weekday;
      }
    }

    if (weakest == null) return null;
    final int percent = (weakestRatio * 100).round();
    if (percent >= _weakWeekdayThresholdPercent) return null;

    return WeakWeekdayInsight(
      weekdayIndex: weakest,
      suggestedWeekdayIndex: (weakest + 6) % 7,
      completionPercent: percent,
    );
  }

  /// The habit with the longest run still going. Days the habit was not asked
  /// for are skipped, the same rule the task chains use.
  LongestHabitInsight? _longestHabitInsight({
    required List<Task> history,
    required DayKey today,
  }) {
    final Map<String, Map<String, bool>> doneByTitleAndDay =
        <String, Map<String, bool>>{};
    for (final Task task in history) {
      if (task.routineId == null) continue;
      (doneByTitleAndDay[task.title] ??= <String, bool>{})[task.day.value] =
          task.isDone;
    }

    String? bestTitle;
    int bestRun = 0;
    doneByTitleAndDay.forEach((String title, Map<String, bool> doneByDay) {
      int run = 0;
      for (int offset = 0; offset <= _consistencyWindowInDays * 2; offset++) {
        final bool? wasDone = doneByDay[today.shift(-offset).value];
        if (wasDone == null) continue;
        if (!wasDone) {
          if (offset == 0) continue;
          break;
        }
        run++;
      }
      if (run > bestRun) {
        bestRun = run;
        bestTitle = title;
      }
    });

    if (bestTitle == null || bestRun < 2) return null;
    return LongestHabitInsight(title: bestTitle!, days: bestRun);
  }
}

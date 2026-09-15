import 'package:equatable/equatable.dart';

import 'daily_quest.dart';
import 'day_key.dart';
import 'level.dart';
import 'routine.dart';
import 'streak_summary.dart';
import 'task.dart';
import 'user_preferences.dart';

/// The state of today: what is left, what was closed, and where that puts the
/// user on the ladder.
class HabitBoard extends Equatable {
  const HabitBoard({
    required this.day,
    required this.preferences,
    required this.level,
    required this.streak,
    required this.quest,
    required this.openTasks,
    required this.completedTasks,
    required this.routines,
    required this.chainDaysByTitle,
  });

  final DayKey day;
  final UserPreferences preferences;
  final Level level;
  final StreakSummary streak;
  final DailyQuest quest;
  final List<Task> openTasks;
  final List<Task> completedTasks;
  final List<Routine> routines;
  final Map<String, int> chainDaysByTitle;

  int get todayXp => completedTasks.fold(
    0,
    (int total, Task task) => total + task.xpReward,
  );

  bool get hasAnyTask => openTasks.isNotEmpty || completedTasks.isNotEmpty;

  Task? get nextTask => openTasks.isEmpty ? null : openTasks.first;

  int chainDaysFor(Task task) => chainDaysByTitle[task.title] ?? 0;

  @override
  List<Object?> get props => <Object?>[
    day.value,
    preferences,
    level,
    streak,
    quest,
    openTasks,
    completedTasks,
    routines,
    chainDaysByTitle,
  ];
}

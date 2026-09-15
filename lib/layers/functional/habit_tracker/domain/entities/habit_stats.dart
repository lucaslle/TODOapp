import 'package:equatable/equatable.dart';

/// One bar of the "XP par jour" chart.
class DailyXp extends Equatable {
  const DailyXp({required this.weekdayIndex, required this.xp});

  /// Monday is 0, Sunday is 6.
  final int weekdayIndex;

  final int xp;

  @override
  List<Object?> get props => <Object?>[weekdayIndex, xp];
}

/// Something the app can defend with the user's own history. When there is not
/// enough history yet, no insight is produced rather than a made-up one.
///
/// Each variant carries figures, not a sentence: the wording belongs to the
/// view, the finding belongs here.
sealed class TrendInsight extends Equatable {
  const TrendInsight();
}

/// Which half of the day carries the user, and by how much.
final class TimeOfDayInsight extends TrendInsight {
  const TimeOfDayInsight({required this.percent, required this.isMorning});

  static const int cutoffHour = 11;

  final int percent;
  final bool isMorning;

  @override
  List<Object?> get props => <Object?>[percent, isMorning];
}

/// The weekday that keeps slipping, and the one before it to move work to.
final class WeakWeekdayInsight extends TrendInsight {
  const WeakWeekdayInsight({
    required this.weekdayIndex,
    required this.suggestedWeekdayIndex,
    required this.completionPercent,
  });

  final int weekdayIndex;
  final int suggestedWeekdayIndex;
  final int completionPercent;

  @override
  List<Object?> get props => <Object?>[
    weekdayIndex,
    suggestedWeekdayIndex,
    completionPercent,
  ];
}

/// The habit that has held the longest.
final class LongestHabitInsight extends TrendInsight {
  const LongestHabitInsight({required this.title, required this.days});

  final String title;
  final int days;

  @override
  List<Object?> get props => <Object?>[title, days];
}

/// Everything the Stats screen draws, computed from closed tasks only.
class HabitStats extends Equatable {
  const HabitStats({
    required this.weekCompletedCount,
    required this.consistencyPercent,
    required this.consistencyDeltaPoints,
    required this.weekXp,
    required this.weekXpGoal,
    required this.dailyXp,
    required this.insights,
  });

  const HabitStats.empty()
    : weekCompletedCount = 0,
      consistencyPercent = 0,
      consistencyDeltaPoints = 0,
      weekXp = 0,
      weekXpGoal = 0,
      dailyXp = const <DailyXp>[],
      insights = const <TrendInsight>[];

  final int weekCompletedCount;
  final int consistencyPercent;

  /// Change against the previous four weeks, in points.
  final int consistencyDeltaPoints;

  final int weekXp;
  final int weekXpGoal;
  final List<DailyXp> dailyXp;
  final List<TrendInsight> insights;

  String get consistencyDeltaLabel {
    if (consistencyDeltaPoints == 0) return 'stable';
    final String sign = consistencyDeltaPoints > 0 ? '+' : '−';
    return '$sign${consistencyDeltaPoints.abs()} pts';
  }

  @override
  List<Object?> get props => <Object?>[
    weekCompletedCount,
    consistencyPercent,
    consistencyDeltaPoints,
    weekXp,
    weekXpGoal,
    dailyXp,
    insights,
  ];
}

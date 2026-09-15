import 'package:equatable/equatable.dart';

import 'day_key.dart';

/// What a finished day amounted to.
///
/// Logs are written once a day has rolled over, which is what lets the streak,
/// the calendar and the stats read history without walking every task again.
class DayLog extends Equatable {
  const DayLog({
    required this.day,
    required this.completedCount,
    required this.plannedCount,
    required this.xpEarned,
    required this.isQuestCompleted,
    required this.isFrozen,
  });

  final DayKey day;
  final int completedCount;
  final int plannedCount;
  final int xpEarned;
  final bool isQuestCompleted;

  /// A missed day covered by one of the monthly freezes.
  final bool isFrozen;

  /// A day that asked nothing. It neither feeds nor breaks the streak — this
  /// is the "repos" of the calendar legend.
  bool get isRestDay => plannedCount == 0;

  /// A day keeps the streak alive when something was done, or when a freeze
  /// covered it.
  bool get keepsStreakAlive => completedCount > 0 || isFrozen;

  bool get isFullyDone => plannedCount > 0 && completedCount >= plannedCount;

  bool get isPartiallyDone => completedCount > 0 && !isFullyDone;

  @override
  List<Object?> get props => <Object?>[
    day.value,
    completedCount,
    plannedCount,
    xpEarned,
    isQuestCompleted,
    isFrozen,
  ];
}

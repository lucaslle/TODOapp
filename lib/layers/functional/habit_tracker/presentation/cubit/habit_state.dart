import 'package:equatable/equatable.dart';

import '../../domain/entities/habit_board.dart';
import '../../domain/entities/habit_stats.dart';
import '../../domain/entities/level.dart';
import '../../domain/entities/month_calendar.dart';

enum HabitStatus { initial, loading, ready }

enum AppTab { today, streak, stats, profile }

/// The short celebration shown when a task closes.
class CheerSignal extends Equatable {
  const CheerSignal({required this.xpGained, required this.line});

  final int xpGained;
  final String line;

  @override
  List<Object?> get props => <Object?>[xpGained, line];
}

class HabitState extends Equatable {
  const HabitState({
    this.status = HabitStatus.initial,
    this.tab = AppTab.today,
    this.board,
    this.stats = const HabitStats.empty(),
    this.calendar = const MonthCalendar.empty(),
    this.isOnboardingVisible = false,
    this.onboardingStep = 0,
    this.cheer,
    this.pendingLevelUp,
  });

  static const int onboardingStepCount = 4;

  final HabitStatus status;
  final AppTab tab;
  final HabitBoard? board;
  final HabitStats stats;
  final MonthCalendar calendar;
  final bool isOnboardingVisible;
  final int onboardingStep;
  final CheerSignal? cheer;
  final Level? pendingLevelUp;

  bool get isReady => status == HabitStatus.ready && board != null;

  /// The profile switch that collapses every animation in the app.
  bool get areEffectsEnabled =>
      board?.preferences.areEffectsEnabled ?? true;

  bool get isOnLastOnboardingStep =>
      onboardingStep == onboardingStepCount - 1;

  HabitState copyWith({
    HabitStatus? status,
    AppTab? tab,
    HabitBoard? board,
    HabitStats? stats,
    MonthCalendar? calendar,
    bool? isOnboardingVisible,
    int? onboardingStep,
    CheerSignal? cheer,
    Level? pendingLevelUp,
    bool clearCheer = false,
    bool clearLevelUp = false,
  }) => HabitState(
    status: status ?? this.status,
    tab: tab ?? this.tab,
    board: board ?? this.board,
    stats: stats ?? this.stats,
    calendar: calendar ?? this.calendar,
    isOnboardingVisible: isOnboardingVisible ?? this.isOnboardingVisible,
    onboardingStep: onboardingStep ?? this.onboardingStep,
    cheer: clearCheer ? null : (cheer ?? this.cheer),
    pendingLevelUp: clearLevelUp ? null : (pendingLevelUp ?? this.pendingLevelUp),
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    tab,
    board,
    stats,
    calendar,
    isOnboardingVisible,
    onboardingStep,
    cheer,
    pendingLevelUp,
  ];
}

import 'package:equatable/equatable.dart';

import 'day_key.dart';

/// Everything the app remembers about the person using it. All of it lives on
/// the device; Cadence never talks to a server.
class UserPreferences extends Equatable {
  const UserPreferences({
    required this.displayName,
    required this.totalXp,
    required this.hasCompletedOnboarding,
    required this.isReminderEnabled,
    required this.areEffectsEnabled,
    required this.lastRolloverDay,
    required this.lastQuestRewardDay,
  });

  const UserPreferences.initial()
    : displayName = '',
      totalXp = 0,
      hasCompletedOnboarding = false,
      isReminderEnabled = true,
      areEffectsEnabled = true,
      lastRolloverDay = null,
      lastQuestRewardDay = null;

  final String displayName;
  final int totalXp;
  final bool hasCompletedOnboarding;
  final bool isReminderEnabled;
  final bool areEffectsEnabled;

  /// Last day the app generated tasks and closed the previous logs.
  final DayKey? lastRolloverDay;

  /// Last day the quest bonus was paid, so it is paid at most once a day.
  final DayKey? lastQuestRewardDay;

  String get greeting =>
      displayName.isEmpty ? 'Bonjour' : 'Bonjour $displayName';

  UserPreferences copyWith({
    String? displayName,
    int? totalXp,
    bool? hasCompletedOnboarding,
    bool? isReminderEnabled,
    bool? areEffectsEnabled,
    DayKey? lastRolloverDay,
    DayKey? lastQuestRewardDay,
  }) => UserPreferences(
    displayName: displayName ?? this.displayName,
    totalXp: totalXp ?? this.totalXp,
    hasCompletedOnboarding:
        hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
    areEffectsEnabled: areEffectsEnabled ?? this.areEffectsEnabled,
    lastRolloverDay: lastRolloverDay ?? this.lastRolloverDay,
    lastQuestRewardDay: lastQuestRewardDay ?? this.lastQuestRewardDay,
  );

  @override
  List<Object?> get props => <Object?>[
    displayName,
    totalXp,
    hasCompletedOnboarding,
    isReminderEnabled,
    areEffectsEnabled,
    lastRolloverDay?.value,
    lastQuestRewardDay?.value,
  ];
}

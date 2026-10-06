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
    this.avatarPath,
  });

  const UserPreferences.initial()
    : displayName = '',
      avatarPath = null,
      totalXp = 0,
      hasCompletedOnboarding = false,
      isReminderEnabled = true,
      areEffectsEnabled = true,
      lastRolloverDay = null,
      lastQuestRewardDay = null;

  final String displayName;

  /// Path of the profile photo copied into the app's own storage, if any.
  final String? avatarPath;
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
    String? avatarPath,
    bool clearAvatarPath = false,
  }) => UserPreferences(
    displayName: displayName ?? this.displayName,
    avatarPath: clearAvatarPath ? null : avatarPath ?? this.avatarPath,
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
    avatarPath,
    totalXp,
    hasCompletedOnboarding,
    isReminderEnabled,
    areEffectsEnabled,
    lastRolloverDay?.value,
    lastQuestRewardDay?.value,
  ];
}

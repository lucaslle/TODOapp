import 'package:shared_preferences/shared_preferences.dart';

/// Flags, counters and the display name — the small scalars that do not
/// deserve a table.
class PreferencesLocalDataSource {
  const PreferencesLocalDataSource({required SharedPreferences preferences})
    : _preferences = preferences;

  final SharedPreferences _preferences;

  static const String displayNameKey = 'display_name';
  static const String avatarPathKey = 'avatar_path';
  static const String totalXpKey = 'total_xp';
  static const String hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String isReminderEnabledKey = 'is_reminder_enabled';
  static const String areEffectsEnabledKey = 'are_effects_enabled';
  static const String lastRolloverDayKey = 'last_rollover_day';
  static const String lastQuestRewardDayKey = 'last_quest_reward_day';

  String readString(String key, String fallback) =>
      _preferences.getString(key) ?? fallback;

  String? readNullableString(String key) => _preferences.getString(key);

  int readInt(String key, int fallback) =>
      _preferences.getInt(key) ?? fallback;

  bool readBool(String key, {required bool fallback}) =>
      _preferences.getBool(key) ?? fallback;

  Future<void> writeString(String key, String value) =>
      _preferences.setString(key, value);

  Future<void> writeInt(String key, int value) =>
      _preferences.setInt(key, value);

  Future<void> writeBool(String key, {required bool value}) =>
      _preferences.setBool(key, value);

  Future<void> writeNullableString(String key, String? value) async {
    if (value == null) {
      await _preferences.remove(key);
      return;
    }
    await _preferences.setString(key, value);
  }
}

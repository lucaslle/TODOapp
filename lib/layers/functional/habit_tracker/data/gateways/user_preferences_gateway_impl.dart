import '../../domain/entities/day_key.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/gateways/user_preferences_gateway.dart';
import '../data_sources/preferences_local_data_source.dart';

class UserPreferencesGatewayImpl implements UserPreferencesGateway {
  const UserPreferencesGatewayImpl({
    required PreferencesLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final PreferencesLocalDataSource _localDataSource;

  @override
  Future<UserPreferences> read() async {
    final String? lastRollover = _localDataSource.readNullableString(
      PreferencesLocalDataSource.lastRolloverDayKey,
    );
    final String? lastQuestReward = _localDataSource.readNullableString(
      PreferencesLocalDataSource.lastQuestRewardDayKey,
    );

    return UserPreferences(
      displayName: _localDataSource.readString(
        PreferencesLocalDataSource.displayNameKey,
        '',
      ),
      totalXp: _localDataSource.readInt(
        PreferencesLocalDataSource.totalXpKey,
        0,
      ),
      hasCompletedOnboarding: _localDataSource.readBool(
        PreferencesLocalDataSource.hasCompletedOnboardingKey,
        fallback: false,
      ),
      isReminderEnabled: _localDataSource.readBool(
        PreferencesLocalDataSource.isReminderEnabledKey,
        fallback: true,
      ),
      areEffectsEnabled: _localDataSource.readBool(
        PreferencesLocalDataSource.areEffectsEnabledKey,
        fallback: true,
      ),
      lastRolloverDay: lastRollover == null ? null : DayKey(lastRollover),
      lastQuestRewardDay: lastQuestReward == null
          ? null
          : DayKey(lastQuestReward),
    );
  }

  @override
  Future<void> write(UserPreferences preferences) async {
    await _localDataSource.writeString(
      PreferencesLocalDataSource.displayNameKey,
      preferences.displayName,
    );
    await _localDataSource.writeInt(
      PreferencesLocalDataSource.totalXpKey,
      preferences.totalXp,
    );
    await _localDataSource.writeBool(
      PreferencesLocalDataSource.hasCompletedOnboardingKey,
      value: preferences.hasCompletedOnboarding,
    );
    await _localDataSource.writeBool(
      PreferencesLocalDataSource.isReminderEnabledKey,
      value: preferences.isReminderEnabled,
    );
    await _localDataSource.writeBool(
      PreferencesLocalDataSource.areEffectsEnabledKey,
      value: preferences.areEffectsEnabled,
    );
    await _localDataSource.writeNullableString(
      PreferencesLocalDataSource.lastRolloverDayKey,
      preferences.lastRolloverDay?.value,
    );
    await _localDataSource.writeNullableString(
      PreferencesLocalDataSource.lastQuestRewardDayKey,
      preferences.lastQuestRewardDay?.value,
    );
  }
}

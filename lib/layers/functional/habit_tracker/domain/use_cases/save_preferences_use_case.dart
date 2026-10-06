import '../entities/user_preferences.dart';
import '../gateways/user_preferences_gateway.dart';

class SavePreferencesUseCase {
  const SavePreferencesUseCase({
    required UserPreferencesGateway preferencesGateway,
  }) : _preferencesGateway = preferencesGateway;

  final UserPreferencesGateway _preferencesGateway;

  Future<UserPreferences> call({
    String? displayName,
    bool? hasCompletedOnboarding,
    bool? isReminderEnabled,
    bool? areEffectsEnabled,
    String? avatarPath,
    bool clearAvatarPath = false,
  }) async {
    final UserPreferences current = await _preferencesGateway.read();
    final UserPreferences updated = current.copyWith(
      displayName: displayName?.trim(),
      avatarPath: avatarPath,
      clearAvatarPath: clearAvatarPath,
      hasCompletedOnboarding: hasCompletedOnboarding,
      isReminderEnabled: isReminderEnabled,
      areEffectsEnabled: areEffectsEnabled,
    );
    await _preferencesGateway.write(updated);
    return updated;
  }
}

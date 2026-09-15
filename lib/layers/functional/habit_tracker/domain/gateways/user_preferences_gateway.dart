import '../entities/user_preferences.dart';

abstract interface class UserPreferencesGateway {
  Future<UserPreferences> read();

  Future<void> write(UserPreferences preferences);
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper over the device's notification service.
///
/// Everything is scheduled locally: the app has no server to push from, so a
/// reminder is simply an alarm the phone holds for itself.
class LocalNotificationService {
  LocalNotificationService();

  static const int eveningReminderId = 1;
  static const String _channelId = 'cadence_evening_reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialised = false;

  Future<void> initialise() async {
    if (_isInitialised) return;

    tz_data.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _isInitialised = true;
  }

  Future<bool> requestPermission() async {
    await initialise();
    final AndroidFlutterLocalNotificationsPlugin? android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? false;
  }

  Future<void> cancelEveningReminder() async {
    await initialise();
    await _plugin.cancel(id: eveningReminderId);
  }

  /// Books the next occurrence of [hour]:[minute], today if it is still ahead,
  /// tomorrow otherwise.
  Future<void> scheduleEveningReminder({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    await initialise();
    await _plugin.cancel(id: eveningReminderId);

    await _plugin.zonedSchedule(
      id: eveningReminderId,
      title: title,
      body: body,
      scheduledDate: _nextOccurrenceOf(hour: hour, minute: minute),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Rappel du soir',
          channelDescription:
              'Un rappel en fin de journée quand il reste des tâches ouvertes.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// The next [hour]:[minute] on the phone's own clock, today if it is still
  /// ahead and tomorrow otherwise.
  ///
  /// The instant is built from a plain local [DateTime] and only then handed to
  /// the timezone package as UTC. `tz.local` is the UTC location unless the app
  /// looks the device zone up, so scheduling against it directly would fire the
  /// 20h30 reminder at 20h30 UTC — an hour or two late in France.
  tz.TZDateTime _nextOccurrenceOf({required int hour, required int minute}) {
    final DateTime now = DateTime.now();
    DateTime next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = DateTime(now.year, now.month, now.day + 1, hour, minute);
    }
    return tz.TZDateTime.from(next, tz.UTC);
  }
}

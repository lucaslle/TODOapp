import '../../../../technical/notifications/local_notification_service.dart';
import '../../domain/gateways/reminder_gateway.dart';

/// "20h30, seulement s'il reste quelque chose."
///
/// The phone cannot re-check the task list when the alarm fires, so the app
/// re-books the reminder every time the day changes: nothing open, nothing
/// scheduled.
class ReminderGatewayImpl implements ReminderGateway {
  const ReminderGatewayImpl({
    required LocalNotificationService notificationService,
  }) : _notificationService = notificationService;

  final LocalNotificationService _notificationService;

  static const int reminderHour = 20;
  static const int reminderMinute = 30;

  @override
  Future<bool> requestPermission() =>
      _notificationService.requestPermission();

  @override
  Future<void> syncEveningReminder({
    required bool isEnabled,
    required int openTaskCount,
  }) async {
    if (!isEnabled || openTaskCount == 0) {
      await _notificationService.cancelEveningReminder();
      return;
    }

    await _notificationService.scheduleEveningReminder(
      hour: reminderHour,
      minute: reminderMinute,
      title: 'Il reste quelque chose',
      body: openTaskCount == 1
          ? 'Une tâche ouverte. Une seule suffit à garder la série.'
          : '$openTaskCount tâches ouvertes. Une seule suffit à garder la série.',
    );
  }
}

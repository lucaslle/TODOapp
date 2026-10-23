import '../../domain/gateways/reminder_gateway.dart';

/// Where scheduled notifications do not exist — the web demo — the reminder
/// is simply never booked.
class NoReminderGateway implements ReminderGateway {
  const NoReminderGateway();

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> syncEveningReminder({
    required bool isEnabled,
    required int openTaskCount,
  }) async {}
}

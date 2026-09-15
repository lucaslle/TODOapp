/// Schedules the evening nudge. Implemented on top of the device's own
/// notification service — nothing leaves the phone.
abstract interface class ReminderGateway {
  /// Asks for the notification permission if it has not been granted yet.
  Future<bool> requestPermission();

  /// Books the next evening reminder when [openTaskCount] is above zero, and
  /// clears any pending one otherwise.
  Future<void> syncEveningReminder({
    required bool isEnabled,
    required int openTaskCount,
  });
}

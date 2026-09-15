import '../entities/task.dart';
import '../entities/user_preferences.dart';
import '../gateways/task_gateway.dart';
import '../gateways/user_preferences_gateway.dart';

/// Reopens a task and takes its XP back.
///
/// The quest bonus is deliberately not refunded: it was paid for a day that
/// did reach three routine steps, and re-paying it on the next completion
/// would turn undo into an XP pump.
class UndoTaskCompletionUseCase {
  const UndoTaskCompletionUseCase({
    required TaskGateway taskGateway,
    required UserPreferencesGateway preferencesGateway,
  }) : _taskGateway = taskGateway,
       _preferencesGateway = preferencesGateway;

  final TaskGateway _taskGateway;
  final UserPreferencesGateway _preferencesGateway;

  Future<void> call(Task task) async {
    if (!task.isDone) return;

    await _taskGateway.update(
      task.copyWith(isDone: false, clearCompletedAt: true),
    );

    final UserPreferences preferences = await _preferencesGateway.read();
    await _preferencesGateway.write(
      preferences.copyWith(
        totalXp: (preferences.totalXp - task.xpReward).clamp(0, 1 << 30),
      ),
    );
  }
}

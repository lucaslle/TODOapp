import '../entities/task.dart';
import '../entities/user_preferences.dart';
import '../gateways/task_gateway.dart';
import '../gateways/user_preferences_gateway.dart';

/// Removes a task from the day. Deleting a task that was already closed also
/// takes its XP back, so the ladder never rests on rows that no longer exist.
class DeleteTaskUseCase {
  const DeleteTaskUseCase({
    required TaskGateway taskGateway,
    required UserPreferencesGateway preferencesGateway,
  }) : _taskGateway = taskGateway,
       _preferencesGateway = preferencesGateway;

  final TaskGateway _taskGateway;
  final UserPreferencesGateway _preferencesGateway;

  Future<void> call(Task task) async {
    await _taskGateway.deleteById(task.id);

    if (!task.isDone) return;
    final UserPreferences preferences = await _preferencesGateway.read();
    await _preferencesGateway.write(
      preferences.copyWith(
        totalXp: (preferences.totalXp - task.xpReward).clamp(0, 1 << 30),
      ),
    );
  }
}

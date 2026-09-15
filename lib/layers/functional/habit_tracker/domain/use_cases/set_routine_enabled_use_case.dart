import '../entities/day_key.dart';
import '../entities/routine.dart';
import '../gateways/routine_gateway.dart';
import '../gateways/task_gateway.dart';
import 'generate_routine_tasks_use_case.dart';

/// Switching a routine on prints today's steps; switching it off pulls back
/// the ones still open. Steps already closed today stay — they were done, and
/// the XP they paid is not taken back.
class SetRoutineEnabledUseCase {
  const SetRoutineEnabledUseCase({
    required RoutineGateway routineGateway,
    required TaskGateway taskGateway,
    required GenerateRoutineTasksUseCase generateRoutineTasks,
  }) : _routineGateway = routineGateway,
       _taskGateway = taskGateway,
       _generateRoutineTasks = generateRoutineTasks;

  final RoutineGateway _routineGateway;
  final TaskGateway _taskGateway;
  final GenerateRoutineTasksUseCase _generateRoutineTasks;

  Future<void> call({required Routine routine, required bool isEnabled}) async {
    await _routineGateway.setEnabled(
      routineId: routine.id,
      isEnabled: isEnabled,
    );

    final DayKey today = DayKey.today();
    if (!routine.runsOnWeekday(today.weekdayIndex)) return;

    if (isEnabled) {
      await _generateRoutineTasks(
        day: today,
        routines: <Routine>[routine.copyWith(isEnabled: true)],
      );
      return;
    }
    await _taskGateway.deleteRoutineSteps(routineId: routine.id, day: today);
  }
}

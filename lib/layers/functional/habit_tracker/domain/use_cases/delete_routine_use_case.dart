import '../entities/day_key.dart';
import '../entities/routine.dart';
import '../gateways/routine_gateway.dart';
import '../gateways/task_gateway.dart';

/// Drops a routine and today's steps that are still open. History is left
/// untouched, so the streak and the stats keep telling the truth.
class DeleteRoutineUseCase {
  const DeleteRoutineUseCase({
    required RoutineGateway routineGateway,
    required TaskGateway taskGateway,
  }) : _routineGateway = routineGateway,
       _taskGateway = taskGateway;

  final RoutineGateway _routineGateway;
  final TaskGateway _taskGateway;

  Future<void> call(Routine routine) async {
    await _taskGateway.deleteRoutineSteps(
      routineId: routine.id,
      day: DayKey.today(),
    );
    await _routineGateway.deleteById(routine.id);
  }
}

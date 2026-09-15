import '../entities/day_key.dart';
import '../entities/routine.dart';
import '../entities/task.dart';
import '../entities/task_list.dart';
import '../gateways/task_gateway.dart';

/// Prints the steps of every enabled routine that runs on [day].
///
/// It is idempotent: a step already present for that day is left alone, so a
/// routine switched on mid-day fills in without duplicating what is there.
class GenerateRoutineTasksUseCase {
  const GenerateRoutineTasksUseCase({required TaskGateway taskGateway})
    : _taskGateway = taskGateway;

  final TaskGateway _taskGateway;

  Future<void> call({
    required DayKey day,
    required List<Routine> routines,
  }) async {
    final List<Task> existing = await _taskGateway.tasksForDay(day);
    final Set<String> existingSteps = existing
        .where((Task task) => task.isRoutineStep)
        .map((Task task) => '${task.routineId}/${task.title}')
        .toSet();

    int sortIndex = existing.length;

    for (final Routine routine in routines) {
      if (!routine.isEnabled) continue;
      if (!routine.runsOnWeekday(day.weekdayIndex)) continue;

      for (final String step in routine.steps) {
        if (existingSteps.contains('${routine.id}/$step')) continue;

        await _taskGateway.create(
          Task(
            id: 0,
            day: day,
            title: step,
            list: TaskList.routine,
            xpReward: TaskList.routine.xpReward,
            whenLabel: routine.slot.taskWhenLabel,
            repeatLabel: routine.repeatLabel(),
            note: 'Étape de la routine « ${routine.name} ».',
            sortIndex: routine.slot.sortIndex * 100 + sortIndex++,
            routineId: routine.id,
          ),
        );
      }
    }
  }
}

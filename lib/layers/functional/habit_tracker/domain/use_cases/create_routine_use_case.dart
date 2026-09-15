import '../entities/day_key.dart';
import '../entities/routine.dart';
import '../entities/routine_slot.dart';
import '../gateways/routine_gateway.dart';
import 'generate_routine_tasks_use_case.dart';

/// Saves a routine and, when it runs today, prints its steps straight away so
/// the user sees the effect of what they just created.
class CreateRoutineUseCase {
  const CreateRoutineUseCase({
    required RoutineGateway routineGateway,
    required GenerateRoutineTasksUseCase generateRoutineTasks,
  }) : _routineGateway = routineGateway,
       _generateRoutineTasks = generateRoutineTasks;

  final RoutineGateway _routineGateway;
  final GenerateRoutineTasksUseCase _generateRoutineTasks;

  Future<Routine?> call({
    required String name,
    required Set<int> weekdays,
    required RoutineSlot slot,
    required List<String> steps,
  }) async {
    final List<String> cleanSteps = steps
        .map((String step) => step.trim())
        .where((String step) => step.isNotEmpty)
        .toList();
    if (cleanSteps.isEmpty || weekdays.isEmpty) return null;

    final String cleanName = name.trim();
    final Routine routine = Routine(
      id: 'r${DateTime.now().microsecondsSinceEpoch}',
      name: cleanName.isEmpty ? 'Routine sans nom' : cleanName,
      weekdays: weekdays,
      slot: slot,
      steps: cleanSteps,
      isEnabled: true,
      createdAt: DateTime.now(),
    );

    await _routineGateway.save(routine);

    final DayKey today = DayKey.today();
    if (routine.runsOnWeekday(today.weekdayIndex)) {
      await _generateRoutineTasks(day: today, routines: <Routine>[routine]);
    }
    return routine;
  }
}

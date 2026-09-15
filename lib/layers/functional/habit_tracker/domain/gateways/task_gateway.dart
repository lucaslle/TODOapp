import '../entities/day_key.dart';
import '../entities/task.dart';

abstract interface class TaskGateway {
  Future<List<Task>> tasksForDay(DayKey day);

  /// Tasks whose day falls between [from] and [to], both included.
  Future<List<Task>> tasksBetween(DayKey from, DayKey to);

  /// Tasks still open on days strictly before [day].
  Future<List<Task>> openTasksBefore(DayKey day);

  Future<Task> create(Task task);

  Future<void> update(Task task);

  Future<void> deleteById(int id);

  /// Removes the still-open steps a routine printed on [day]. Steps already
  /// closed are kept: they happened, and their XP stands.
  Future<void> deleteRoutineSteps({
    required String routineId,
    required DayKey day,
  });

  Future<bool> hasAnyTaskOn(DayKey day);
}

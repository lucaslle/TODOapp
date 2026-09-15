import '../../domain/entities/day_key.dart';
import '../../domain/entities/task.dart';
import '../../domain/gateways/task_gateway.dart';
import '../data_sources/habit_local_data_source.dart';
import '../models/task_row.dart';

class TaskGatewayImpl implements TaskGateway {
  const TaskGatewayImpl({required HabitLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final HabitLocalDataSource _localDataSource;

  @override
  Future<List<Task>> tasksForDay(DayKey day) async {
    final List<Map<String, Object?>> rows = await _localDataSource.tasksForDay(
      day.value,
    );
    return rows.map(TaskRow.toEntity).toList();
  }

  @override
  Future<List<Task>> tasksBetween(DayKey from, DayKey to) async {
    final List<Map<String, Object?>> rows = await _localDataSource.tasksBetween(
      from.value,
      to.value,
    );
    return rows.map(TaskRow.toEntity).toList();
  }

  @override
  Future<List<Task>> openTasksBefore(DayKey day) async {
    final List<Map<String, Object?>> rows = await _localDataSource
        .openTasksBefore(day.value);
    return rows.map(TaskRow.toEntity).toList();
  }

  @override
  Future<Task> create(Task task) async {
    final int id = await _localDataSource.insertTask(TaskRow.toColumns(task));
    return Task(
      id: id,
      day: task.day,
      title: task.title,
      list: task.list,
      xpReward: task.xpReward,
      whenLabel: task.whenLabel,
      repeatLabel: task.repeatLabel,
      note: task.note,
      sortIndex: task.sortIndex,
      routineId: task.routineId,
      isDone: task.isDone,
      completedAt: task.completedAt,
    );
  }

  @override
  Future<void> update(Task task) =>
      _localDataSource.updateTask(task.id, TaskRow.toColumns(task));

  @override
  Future<void> deleteById(int id) => _localDataSource.deleteTask(id);

  @override
  Future<void> deleteRoutineSteps({
    required String routineId,
    required DayKey day,
  }) => _localDataSource.deleteOpenRoutineSteps(
    routineId: routineId,
    day: day.value,
  );

  @override
  Future<bool> hasAnyTaskOn(DayKey day) async =>
      await _localDataSource.countTasksOn(day.value) > 0;
}

import '../../domain/entities/routine.dart';
import '../../domain/gateways/routine_gateway.dart';
import '../data_sources/habit_local_data_source.dart';
import '../models/routine_row.dart';

class RoutineGatewayImpl implements RoutineGateway {
  const RoutineGatewayImpl({required HabitLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final HabitLocalDataSource _localDataSource;

  @override
  Future<List<Routine>> all() async {
    final List<Map<String, Object?>> rows = await _localDataSource.routines();
    return rows.map(RoutineRow.toEntity).toList();
  }

  @override
  Future<void> save(Routine routine) =>
      _localDataSource.upsertRoutine(RoutineRow.toColumns(routine));

  @override
  Future<void> setEnabled({
    required String routineId,
    required bool isEnabled,
  }) => _localDataSource.setRoutineEnabled(
    routineId: routineId,
    isEnabled: isEnabled,
  );

  @override
  Future<void> deleteById(String routineId) =>
      _localDataSource.deleteRoutine(routineId);
}

import '../../domain/entities/day_key.dart';
import '../../domain/entities/day_log.dart';
import '../../domain/gateways/day_log_gateway.dart';
import '../data_sources/habit_local_data_source.dart';
import '../models/day_log_row.dart';

class DayLogGatewayImpl implements DayLogGateway {
  const DayLogGatewayImpl({required HabitLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final HabitLocalDataSource _localDataSource;

  @override
  Future<List<DayLog>> logsBetween(DayKey from, DayKey to) async {
    final List<Map<String, Object?>> rows = await _localDataSource
        .dayLogsBetween(from.value, to.value);
    return rows.map(DayLogRow.toEntity).toList();
  }

  @override
  Future<List<DayLog>> allLogs() async {
    final List<Map<String, Object?>> rows = await _localDataSource.dayLogs();
    return rows.map(DayLogRow.toEntity).toList();
  }

  @override
  Future<void> upsert(DayLog log) =>
      _localDataSource.upsertDayLog(DayLogRow.toColumns(log));

  @override
  Future<int> freezesUsedInMonthOf(DayKey day) =>
      _localDataSource.freezesUsedInMonth(day.value.substring(0, 7));
}

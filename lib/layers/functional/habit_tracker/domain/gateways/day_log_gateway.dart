import '../entities/day_key.dart';
import '../entities/day_log.dart';

abstract interface class DayLogGateway {
  Future<List<DayLog>> logsBetween(DayKey from, DayKey to);

  Future<List<DayLog>> allLogs();

  Future<void> upsert(DayLog log);

  /// Freezes already spent in the calendar month of [day].
  Future<int> freezesUsedInMonthOf(DayKey day);
}

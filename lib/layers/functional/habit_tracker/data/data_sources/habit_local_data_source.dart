import 'package:sqflite/sqflite.dart';

import '../../../../technical/persistence/cadence_database.dart';

/// Every SQL statement of the feature lives here. Values are always bound as
/// placeholders — no caller ever builds a statement from a string.
class HabitLocalDataSource {
  const HabitLocalDataSource({required CadenceDatabase database})
    : _database = database;

  final CadenceDatabase _database;

  Future<List<Map<String, Object?>>> tasksForDay(String day) async {
    final Database db = await _database.open();
    return db.query(
      CadenceDatabase.tasksTable,
      where: 'day = ?',
      whereArgs: <Object?>[day],
      orderBy: 'sort_index ASC, id ASC',
    );
  }

  Future<List<Map<String, Object?>>> tasksBetween(String from, String to) async {
    final Database db = await _database.open();
    return db.query(
      CadenceDatabase.tasksTable,
      where: 'day >= ? AND day <= ?',
      whereArgs: <Object?>[from, to],
      orderBy: 'day ASC, sort_index ASC, id ASC',
    );
  }

  Future<List<Map<String, Object?>>> openTasksBefore(String day) async {
    final Database db = await _database.open();
    return db.query(
      CadenceDatabase.tasksTable,
      where: 'day < ? AND is_done = 0',
      whereArgs: <Object?>[day],
      orderBy: 'day ASC, sort_index ASC',
    );
  }

  Future<int> insertTask(Map<String, Object?> columns) async {
    final Database db = await _database.open();
    return db.insert(CadenceDatabase.tasksTable, columns);
  }

  Future<void> updateTask(int id, Map<String, Object?> columns) async {
    final Database db = await _database.open();
    await db.update(
      CadenceDatabase.tasksTable,
      columns,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> deleteTask(int id) async {
    final Database db = await _database.open();
    await db.delete(
      CadenceDatabase.tasksTable,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  Future<void> deleteOpenRoutineSteps({
    required String routineId,
    required String day,
  }) async {
    final Database db = await _database.open();
    await db.delete(
      CadenceDatabase.tasksTable,
      where: 'routine_id = ? AND day = ? AND is_done = 0',
      whereArgs: <Object?>[routineId, day],
    );
  }

  Future<int> countTasksOn(String day) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${CadenceDatabase.tasksTable} WHERE day = ?',
      <Object?>[day],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  Future<List<Map<String, Object?>>> routines() async {
    final Database db = await _database.open();
    return db.query(CadenceDatabase.routinesTable, orderBy: 'created_at ASC');
  }

  Future<void> upsertRoutine(Map<String, Object?> columns) async {
    final Database db = await _database.open();
    await db.insert(
      CadenceDatabase.routinesTable,
      columns,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> setRoutineEnabled({
    required String routineId,
    required bool isEnabled,
  }) async {
    final Database db = await _database.open();
    await db.update(
      CadenceDatabase.routinesTable,
      <String, Object?>{'is_enabled': isEnabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: <Object?>[routineId],
    );
  }

  Future<void> deleteRoutine(String routineId) async {
    final Database db = await _database.open();
    await db.delete(
      CadenceDatabase.routinesTable,
      where: 'id = ?',
      whereArgs: <Object?>[routineId],
    );
  }

  Future<List<Map<String, Object?>>> dayLogs() async {
    final Database db = await _database.open();
    return db.query(CadenceDatabase.dayLogsTable, orderBy: 'day ASC');
  }

  Future<List<Map<String, Object?>>> dayLogsBetween(
    String from,
    String to,
  ) async {
    final Database db = await _database.open();
    return db.query(
      CadenceDatabase.dayLogsTable,
      where: 'day >= ? AND day <= ?',
      whereArgs: <Object?>[from, to],
      orderBy: 'day ASC',
    );
  }

  Future<void> upsertDayLog(Map<String, Object?> columns) async {
    final Database db = await _database.open();
    await db.insert(
      CadenceDatabase.dayLogsTable,
      columns,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Freezes spent inside the `yyyy-MM` prefix of [day].
  Future<int> freezesUsedInMonth(String monthPrefix) async {
    final Database db = await _database.open();
    final List<Map<String, Object?>> rows = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM ${CadenceDatabase.dayLogsTable} '
      'WHERE is_frozen = 1 AND day LIKE ?',
      <Object?>['$monthPrefix%'],
    );
    return (rows.first['total'] as int?) ?? 0;
  }
}

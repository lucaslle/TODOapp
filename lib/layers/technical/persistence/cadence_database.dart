import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// The on-device store. Cadence has no backend: this file is the whole
/// database, and it never leaves the phone.
///
/// One connection is opened lazily and reused; callers go through the data
/// sources rather than touching [Database] themselves.
class CadenceDatabase {
  CadenceDatabase._();

  static final CadenceDatabase instance = CadenceDatabase._();

  static const String fileName = 'cadence.db';
  static const int schemaVersion = 1;

  static const String tasksTable = 'tasks';
  static const String routinesTable = 'routines';
  static const String dayLogsTable = 'day_logs';

  Database? _database;

  Future<Database> open() async {
    final Database? current = _database;
    if (current != null) return current;

    // The browser has no SQLite of its own: the web demo runs it as
    // WebAssembly, in the page itself, with the file kept in IndexedDB.
    if (kIsWeb) databaseFactory = databaseFactoryFfiWebNoWebWorker;
    final String path = p.join(await getDatabasesPath(), fileName);
    final Database database = await openDatabase(
      path,
      version: schemaVersion,
      onConfigure: (Database db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _createSchema,
    );
    _database = database;
    return database;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tasksTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day TEXT NOT NULL,
        title TEXT NOT NULL,
        list TEXT NOT NULL,
        xp_reward INTEGER NOT NULL,
        when_label TEXT NOT NULL,
        repeat_label TEXT NOT NULL,
        note TEXT NOT NULL,
        sort_index INTEGER NOT NULL,
        routine_id TEXT,
        is_done INTEGER NOT NULL DEFAULT 0,
        completed_at INTEGER
      )
    ''');
    await db.execute('CREATE INDEX idx_tasks_day ON $tasksTable (day)');

    await db.execute('''
      CREATE TABLE $routinesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        weekdays TEXT NOT NULL,
        slot TEXT NOT NULL,
        steps TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $dayLogsTable (
        day TEXT PRIMARY KEY,
        completed_count INTEGER NOT NULL,
        planned_count INTEGER NOT NULL,
        xp_earned INTEGER NOT NULL,
        is_quest_completed INTEGER NOT NULL DEFAULT 0,
        is_frozen INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}

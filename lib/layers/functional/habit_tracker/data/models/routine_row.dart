import 'dart:convert';

import '../../domain/entities/routine.dart';
import '../../domain/entities/routine_slot.dart';

abstract final class RoutineRow {
  static Routine toEntity(Map<String, Object?> row) => Routine(
    id: row['id']! as String,
    name: row['name']! as String,
    weekdays: (row['weekdays']! as String)
        .split(',')
        .where((String part) => part.isNotEmpty)
        .map(int.parse)
        .toSet(),
    slot: RoutineSlot.fromStorage(row['slot']! as String),
    steps: (jsonDecode(row['steps']! as String) as List<Object?>)
        .cast<String>(),
    isEnabled: (row['is_enabled']! as int) == 1,
    createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
  );

  static Map<String, Object?> toColumns(Routine routine) => <String, Object?>{
    'id': routine.id,
    'name': routine.name,
    'weekdays': (routine.weekdays.toList()..sort()).join(','),
    'slot': routine.slot.name,
    'steps': jsonEncode(routine.steps),
    'is_enabled': routine.isEnabled ? 1 : 0,
    'created_at': routine.createdAt.millisecondsSinceEpoch,
  };
}

import '../../domain/entities/day_key.dart';
import '../../domain/entities/day_log.dart';

abstract final class DayLogRow {
  static DayLog toEntity(Map<String, Object?> row) => DayLog(
    day: DayKey(row['day']! as String),
    completedCount: row['completed_count']! as int,
    plannedCount: row['planned_count']! as int,
    xpEarned: row['xp_earned']! as int,
    isQuestCompleted: (row['is_quest_completed']! as int) == 1,
    isFrozen: (row['is_frozen']! as int) == 1,
  );

  static Map<String, Object?> toColumns(DayLog log) => <String, Object?>{
    'day': log.day.value,
    'completed_count': log.completedCount,
    'planned_count': log.plannedCount,
    'xp_earned': log.xpEarned,
    'is_quest_completed': log.isQuestCompleted ? 1 : 0,
    'is_frozen': log.isFrozen ? 1 : 0,
  };
}

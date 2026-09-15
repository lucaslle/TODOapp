import '../../domain/entities/day_key.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_list.dart';

/// Translation between a [Task] and its row in the tasks table.
abstract final class TaskRow {
  static Task toEntity(Map<String, Object?> row) {
    final int? completedAtMillis = row['completed_at'] as int?;
    return Task(
      id: row['id']! as int,
      day: DayKey(row['day']! as String),
      title: row['title']! as String,
      list: TaskList.fromStorage(row['list']! as String),
      xpReward: row['xp_reward']! as int,
      whenLabel: row['when_label']! as String,
      repeatLabel: row['repeat_label']! as String,
      note: row['note']! as String,
      sortIndex: row['sort_index']! as int,
      routineId: row['routine_id'] as String?,
      isDone: (row['is_done']! as int) == 1,
      completedAt: completedAtMillis == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(completedAtMillis),
    );
  }

  /// The row without its id, so the same map serves insert and update.
  static Map<String, Object?> toColumns(Task task) => <String, Object?>{
    'day': task.day.value,
    'title': task.title,
    'list': task.list.name,
    'xp_reward': task.xpReward,
    'when_label': task.whenLabel,
    'repeat_label': task.repeatLabel,
    'note': task.note,
    'sort_index': task.sortIndex,
    'routine_id': task.routineId,
    'is_done': task.isDone ? 1 : 0,
    'completed_at': task.completedAt?.millisecondsSinceEpoch,
  };
}

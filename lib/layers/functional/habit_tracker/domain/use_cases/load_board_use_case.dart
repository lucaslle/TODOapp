import '../entities/daily_quest.dart';
import '../entities/day_key.dart';
import '../entities/habit_board.dart';
import '../entities/level.dart';
import '../entities/routine.dart';
import '../entities/task.dart';
import '../entities/user_preferences.dart';
import '../gateways/routine_gateway.dart';
import '../gateways/task_gateway.dart';
import '../gateways/user_preferences_gateway.dart';
import 'compute_task_chains_use_case.dart';
import 'load_streak_use_case.dart';

/// Reads everything today's screens need in one pass.
class LoadBoardUseCase {
  const LoadBoardUseCase({
    required TaskGateway taskGateway,
    required RoutineGateway routineGateway,
    required UserPreferencesGateway preferencesGateway,
    required LoadStreakUseCase loadStreak,
    required ComputeTaskChainsUseCase computeTaskChains,
  }) : _taskGateway = taskGateway,
       _routineGateway = routineGateway,
       _preferencesGateway = preferencesGateway,
       _loadStreak = loadStreak,
       _computeTaskChains = computeTaskChains;

  final TaskGateway _taskGateway;
  final RoutineGateway _routineGateway;
  final UserPreferencesGateway _preferencesGateway;
  final LoadStreakUseCase _loadStreak;
  final ComputeTaskChainsUseCase _computeTaskChains;

  Future<HabitBoard> call() async {
    final DayKey today = DayKey.today();
    final UserPreferences preferences = await _preferencesGateway.read();
    final List<Task> tasks = await _taskGateway.tasksForDay(today);
    final List<Routine> routines = await _routineGateway.all();

    final List<Task> completed = tasks.where((Task task) => task.isDone).toList()
      ..sort(
        (Task a, Task b) => (b.completedAt ?? DateTime(0)).compareTo(
          a.completedAt ?? DateTime(0),
        ),
      );
    final List<Task> open = tasks.where((Task task) => !task.isDone).toList();

    final int completedRoutineSteps = completed
        .where((Task task) => task.isRoutineStep)
        .length;

    return HabitBoard(
      day: today,
      preferences: preferences,
      level: LevelLadder.at(preferences.totalXp),
      streak: await _loadStreak(todayTasks: tasks),
      quest: DailyQuest(
        completedSteps: completedRoutineSteps.clamp(
          0,
          DailyQuest.requiredSteps,
        ),
        isRewarded: preferences.lastQuestRewardDay?.value == today.value,
      ),
      openTasks: open,
      completedTasks: completed,
      routines: routines,
      chainDaysByTitle: await _computeTaskChains(day: today, tasks: tasks),
    );
  }
}

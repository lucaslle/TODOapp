import 'package:equatable/equatable.dart';

import '../entities/daily_quest.dart';
import '../entities/day_key.dart';
import '../entities/level.dart';
import '../entities/task.dart';
import '../entities/user_preferences.dart';
import '../gateways/task_gateway.dart';
import '../gateways/user_preferences_gateway.dart';
import 'compute_task_chains_use_case.dart';

/// What closing a task paid, and whether it moved the ladder.
class TaskCompletionOutcome extends Equatable {
  const TaskCompletionOutcome({
    required this.xpGained,
    required this.cheerLine,
    required this.hasCompletedQuest,
    required this.hasLeveledUp,
    required this.level,
  });

  final int xpGained;

  /// The line under the celebration figure: the habit's chain, or the quest.
  final String cheerLine;

  final bool hasCompletedQuest;
  final bool hasLeveledUp;
  final Level level;

  @override
  List<Object?> get props => <Object?>[
    xpGained,
    cheerLine,
    hasCompletedQuest,
    hasLeveledUp,
    level,
  ];
}

/// Closes a task: pays its XP, pays the daily quest bonus the first time the
/// third routine step of the day lands, and reports whether a level was
/// crossed so the view can invert the screen.
class CompleteTaskUseCase {
  const CompleteTaskUseCase({
    required TaskGateway taskGateway,
    required UserPreferencesGateway preferencesGateway,
    required ComputeTaskChainsUseCase computeTaskChains,
  }) : _taskGateway = taskGateway,
       _preferencesGateway = preferencesGateway,
       _computeTaskChains = computeTaskChains;

  final TaskGateway _taskGateway;
  final UserPreferencesGateway _preferencesGateway;
  final ComputeTaskChainsUseCase _computeTaskChains;

  Future<TaskCompletionOutcome?> call(Task task) async {
    if (task.isDone) return null;

    final DayKey today = DayKey.today();
    await _taskGateway.update(
      task.copyWith(isDone: true, completedAt: DateTime.now()),
    );

    final UserPreferences preferences = await _preferencesGateway.read();
    final List<Task> tasks = await _taskGateway.tasksForDay(task.day);

    final int completedRoutineSteps = tasks
        .where((Task other) => other.isDone && other.isRoutineStep)
        .length;
    final bool wasQuestRewarded =
        preferences.lastQuestRewardDay?.value == today.value;
    final bool hasCompletedQuest =
        !wasQuestRewarded &&
        task.day.value == today.value &&
        completedRoutineSteps >= DailyQuest.requiredSteps;

    final int questBonus = hasCompletedQuest ? DailyQuest.bonusXp : 0;
    final int xpGained = task.xpReward + questBonus;

    final Level levelBefore = LevelLadder.at(preferences.totalXp);
    final int totalXp = preferences.totalXp + xpGained;
    final Level levelAfter = LevelLadder.at(totalXp);

    await _preferencesGateway.write(
      preferences.copyWith(
        totalXp: totalXp,
        lastQuestRewardDay: hasCompletedQuest
            ? today
            : preferences.lastQuestRewardDay,
      ),
    );

    return TaskCompletionOutcome(
      xpGained: xpGained,
      cheerLine: hasCompletedQuest
          ? 'Quête du jour terminée'
          : chainLabelFor(await _chainAfterCompletion(task)),
      hasCompletedQuest: hasCompletedQuest,
      hasLeveledUp: levelAfter.rank > levelBefore.rank,
      level: levelAfter,
    );
  }

  /// The chain the habit stands at once today counts, which is what the
  /// celebration should show.
  Future<int> _chainAfterCompletion(Task task) async {
    final Map<String, int> chains = await _computeTaskChains(
      day: task.day,
      tasks: <Task>[task],
    );
    return (chains[task.title] ?? 0) + 1;
  }
}

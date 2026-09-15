import 'package:flutter/material.dart';

import '../../../../technical/formatting/french_calendar.dart';
import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/mono_label.dart';
import '../../../../technical/theme/widgets/pressable.dart';
import '../../../../technical/theme/widgets/section_card.dart';
import '../../domain/entities/habit_board.dart';
import '../../domain/entities/task.dart';
import '../widgets/empty_state.dart';
import '../widgets/quest_card.dart';
import '../widgets/stat_tile.dart';
import '../widgets/task_tile.dart';

class TodayView extends StatelessWidget {
  const TodayView({
    required this.board,
    required this.isAnimated,
    required this.onCompleteTask,
    required this.onOpenTask,
    required this.onUndoTask,
    required this.onOpenStreak,
    super.key,
  });

  final HabitBoard board;
  final bool isAnimated;
  final ValueChanged<Task> onCompleteTask;
  final ValueChanged<Task> onOpenTask;
  final ValueChanged<Task> onUndoTask;
  final VoidCallback onOpenStreak;

  @override
  Widget build(BuildContext context) {
    final Task? nextTask = board.nextTask;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 12),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MonoLabel(FrenchCalendar.longDate(board.day.date)),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      board.preferences.greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CadenceTextStyles.display(
                        size: 30,
                        letterSpacing: -0.04,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StreakPill(
                    days: board.streak.currentDays,
                    isAnimated: isAnimated,
                    onPressed: onOpenStreak,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        QuestCard(
          quest: board.quest,
          level: board.level,
          streakDays: board.streak.currentDays,
          isAnimated: isAnimated,
          onOpenNextTask: nextTask == null ? null : () => onOpenTask(nextTask),
          onCompleteNextTask: nextTask == null
              ? null
              : () => onCompleteTask(nextTask),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                label: 'Ouvertes',
                value: '${board.openTasks.length}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: 'Faites',
                value: '${board.completedTasks.length}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(label: 'Gagnés', value: '${board.todayXp}'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SectionCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const MonoLabel('À suivre'),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      board.openTasks.isEmpty
                          ? 'terminé'
                          : '${board.openTasks.length} restantes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CadenceTextStyles.monoMeta(
                        size: 10,
                        color: CadenceColors.textGhost,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (!board.hasAnyTask)
                const EmptyState(
                  title: 'Rien pour aujourd’hui.',
                  body: 'Ajoute une tâche avec le bouton +, ou crée une '
                      'routine depuis le profil pour qu’elle revienne '
                      'toute seule.',
                )
              else if (board.openTasks.isEmpty)
                const EmptyState(
                  title: 'Tout est fait.',
                  body: 'La série est gardée pour aujourd’hui.',
                ),
              for (int index = 0; index < board.openTasks.length; index++)
                TaskTile(
                  task: board.openTasks[index],
                  isQuestStep: board.openTasks[index].isRoutineStep,
                  isAnimated: isAnimated,
                  hasDivider: index < board.openTasks.length - 1,
                  onComplete: () => onCompleteTask(board.openTasks[index]),
                  onOpen: () => onOpenTask(board.openTasks[index]),
                ),
              if (board.completedTasks.isNotEmpty) ...<Widget>[
                const SizedBox(height: 14),
                MonoLabel('Terminées', color: CadenceColors.textAt(0.34)),
                for (final Task task in board.completedTasks)
                  CompletedTaskTile(
                    task: task,
                    isAnimated: isAnimated,
                    onUndo: () => onUndoTask(task),
                  ),
                const SizedBox(height: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 96),
      ],
    );
  }
}

class _StreakPill extends StatelessWidget {
  const _StreakPill({
    required this.days,
    required this.isAnimated,
    required this.onPressed,
  });

  final int days;
  final bool isAnimated;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onPressed: onPressed,
      pressedScale: 0.95,
      isAnimated: isAnimated,
      semanticLabel: 'Série de $days jours',
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: CadenceColors.outlineStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              CadenceIcons.flameFilled,
              size: 14,
              color: CadenceColors.text,
            ),
            const SizedBox(width: 6),
            Text(
              '$days',
              style: CadenceTextStyles.monoMeta(
                size: 13,
                weight: FontWeight.w500,
                color: CadenceColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

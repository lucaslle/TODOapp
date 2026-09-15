import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/pressable.dart';
import '../../domain/entities/task.dart';

/// An open task: a hollow circle to close it, the title, and what it pays.
class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.task,
    required this.isQuestStep,
    required this.isAnimated,
    required this.onComplete,
    required this.onOpen,
    this.hasDivider = true,
    super.key,
  });

  final Task task;

  /// Routine steps feed the daily quest, and say so.
  final bool isQuestStep;

  final bool isAnimated;
  final VoidCallback onComplete;
  final VoidCallback onOpen;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 62),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: hasDivider
            ? Border(bottom: BorderSide(color: CadenceColors.hairline))
            : null,
      ),
      child: Row(
        children: <Widget>[
          Pressable(
            onPressed: onComplete,
            pressedScale: 0.86,
            isAnimated: isAnimated,
            semanticLabel: 'Valider ${task.title}',
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: CadenceColors.textAt(0.3),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Pressable(
              onPressed: onOpen,
              pressedScale: 0.99,
              isAnimated: isAnimated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    task.title,
                    style: CadenceTextStyles.body(
                      size: 16,
                      height: 1.25,
                      letterSpacing: -0.012,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          '${task.list.label} / ${task.whenLabel}'.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CadenceTextStyles.monoMeta(
                            size: 10,
                            letterSpacing: 0.08,
                            color: CadenceColors.textAt(0.38),
                          ),
                        ),
                      ),
                      if (isQuestStep) ...<Widget>[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CadenceColors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'QUÊTE',
                            style: CadenceTextStyles.monoMeta(
                              size: 10,
                              letterSpacing: 0.08,
                              color: CadenceColors.onWhite,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '+${task.xpReward}',
            style: CadenceTextStyles.monoMeta(
              size: 12,
              color: CadenceColors.textAt(0.34),
            ),
          ),
        ],
      ),
    );
  }
}

/// A closed task, dimmed, with its circle filled — tapping it reopens it.
class CompletedTaskTile extends StatelessWidget {
  const CompletedTaskTile({
    required this.task,
    required this.isAnimated,
    required this.onUndo,
    super.key,
  });

  final Task task;
  final bool isAnimated;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.45,
      child: Container(
        constraints: const BoxConstraints(minHeight: 54),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            Pressable(
              onPressed: onUndo,
              pressedScale: 0.86,
              isAnimated: isAnimated,
              semanticLabel: 'Annuler ${task.title}',
              child: Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CadenceColors.white,
                ),
                child: Icon(
                  CadenceIcons.checkFilled,
                  size: 12,
                  color: CadenceColors.onWhite,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CadenceTextStyles.body(
                  size: 16,
                  height: 1.25,
                ).copyWith(
                  decoration: TextDecoration.lineThrough,
                  decorationColor: CadenceColors.textAt(0.45),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '+${task.xpReward}',
              style: CadenceTextStyles.monoMeta(size: 12),
            ),
          ],
        ),
      ),
    );
  }
}

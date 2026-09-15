import 'package:flutter/material.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/pill_button.dart';
import '../../../../technical/theme/widgets/pressable.dart';
import '../../domain/entities/task.dart';
import '../../domain/use_cases/compute_task_chains_use_case.dart';
import 'cadence_sheet.dart';

/// What the user chose to do with the task they opened.
enum TaskDetailAction { complete, delete }

class TaskDetailSheet extends StatelessWidget {
  const TaskDetailSheet({
    required this.task,
    required this.chainDays,
    required this.isQuestStep,
    super.key,
  });

  final Task task;
  final int chainDays;
  final bool isQuestStep;

  @override
  Widget build(BuildContext context) {
    return CadenceSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              _Chip(label: task.list.label, isFilled: false),
              if (isQuestStep) ...<Widget>[
                const SizedBox(width: 8),
                const _Chip(label: 'Quête', isFilled: true),
              ],
              const Spacer(),
              Text(
                '+${task.xpReward} XP',
                style: CadenceTextStyles.monoMeta(
                  size: 12,
                  color: CadenceColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            task.title,
            style: CadenceTextStyles.display(
              size: 27,
              height: 1.1,
              letterSpacing: -0.04,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            task.note,
            style: CadenceTextStyles.body(
              size: 14,
              color: CadenceColors.textAt(0.55),
            ),
          ),
          const SizedBox(height: 18),
          _DetailRow(label: 'Quand', value: task.whenLabel),
          _DetailRow(label: 'Répétition', value: task.repeatLabel),
          _DetailRow(label: 'Chaîne', value: chainLabelFor(chainDays)),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              PillButton(
                label: 'Fermer',
                variant: PillButtonVariant.outlined,
                fontSize: 14,
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PillButton(
                  label: 'Valider',
                  icon: CadenceIcons.checkFilled,
                  isExpanded: true,
                  onPressed: () =>
                      Navigator.of(context).pop(TaskDetailAction.complete),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Center(
            child: Pressable(
              onPressed: () =>
                  Navigator.of(context).pop(TaskDetailAction.delete),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Supprimer la tâche',
                  style: CadenceTextStyles.button(
                    size: 13,
                    weight: FontWeight.w500,
                    color: CadenceColors.textAt(0.45),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.isFilled});

  final String label;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? CadenceColors.white : null,
        borderRadius: BorderRadius.circular(999),
        border: isFilled ? null : Border.all(color: CadenceColors.textAt(0.2)),
      ),
      child: Text(
        label.toUpperCase(),
        style: CadenceTextStyles.monoMeta(
          size: 10,
          letterSpacing: 0.12,
          color: isFilled ? CadenceColors.onWhite : CadenceColors.textAt(0.7),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: CadenceColors.textAt(0.08))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: CadenceTextStyles.body(
              size: 14,
              height: 1.2,
              color: CadenceColors.textAt(0.5),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: CadenceTextStyles.body(size: 14, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

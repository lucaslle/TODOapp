import 'package:flutter/material.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/choice_pill.dart';
import '../../../../technical/theme/widgets/mono_label.dart';
import '../../../../technical/theme/widgets/pill_button.dart';
import '../../../../technical/theme/widgets/pressable.dart';
import '../../../../technical/formatting/french_calendar.dart';
import '../../domain/entities/routine_slot.dart';
import '../../domain/entities/task_list.dart';
import 'cadence_sheet.dart';

/// What the user asked to create when the sheet closes.
sealed class ComposerResult {}

final class NewTaskResult extends ComposerResult {
  NewTaskResult({required this.title, required this.list});

  final String title;
  final TaskList list;
}

final class NewRoutineResult extends ComposerResult {
  NewRoutineResult({
    required this.name,
    required this.weekdays,
    required this.slot,
    required this.steps,
  });

  final String name;
  final Set<int> weekdays;
  final RoutineSlot slot;
  final List<String> steps;
}

/// The add sheet, with its two faces: a one-off task, or a routine that will
/// come back on the days chosen.
class TaskComposerSheet extends StatefulWidget {
  const TaskComposerSheet({this.initialTabIndex = 0, super.key});

  final int initialTabIndex;

  @override
  State<TaskComposerSheet> createState() => _TaskComposerSheetState();
}

class _TaskComposerSheetState extends State<TaskComposerSheet> {
  late int _tabIndex = widget.initialTabIndex;

  final TextEditingController _taskTitleController = TextEditingController();
  final TextEditingController _routineNameController = TextEditingController();
  final TextEditingController _stepController = TextEditingController();

  TaskList _selectedList = TaskList.routine;
  RoutineSlot _selectedSlot = RoutineSlot.morning;
  final Set<int> _selectedWeekdays = <int>{0, 1, 2, 3, 4};
  final List<String> _steps = <String>[];

  @override
  void initState() {
    super.initState();
    // The step count and the XP preview read the field as it is typed.
    _stepController.addListener(_onStepTextChanged);
  }

  void _onStepTextChanged() => setState(() {});

  @override
  void dispose() {
    _stepController.removeListener(_onStepTextChanged);
    _taskTitleController.dispose();
    _routineNameController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _addStep() {
    final String step = _stepController.text.trim();
    if (step.isEmpty) return;
    setState(() {
      _steps.add(step);
      _stepController.clear();
    });
  }

  void _submitTask() {
    Navigator.of(context).pop(
      NewTaskResult(title: _taskTitleController.text, list: _selectedList),
    );
  }

  void _submitRoutine() {
    final List<String> steps = <String>[
      ..._steps,
      if (_stepController.text.trim().isNotEmpty) _stepController.text.trim(),
    ];
    if (steps.isEmpty || _selectedWeekdays.isEmpty) return;

    Navigator.of(context).pop(
      NewRoutineResult(
        name: _routineNameController.text,
        weekdays: _selectedWeekdays,
        slot: _selectedSlot,
        steps: steps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CadenceSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SheetSegmentedTabs(
            labels: const <String>['Tâche', 'Routine'],
            selectedIndex: _tabIndex,
            onSelected: (int index) => setState(() => _tabIndex = index),
          ),
          const SizedBox(height: 18),
          if (_tabIndex == 0) _buildTaskForm() else _buildRoutineForm(),
        ],
      ),
    );
  }

  Widget _buildTaskForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Nouvelle tâche',
          style: CadenceTextStyles.display(size: 24, letterSpacing: -0.035),
        ),
        const SizedBox(height: 16),
        SheetTextField(
          controller: _taskTitleController,
          hintText: 'Qu’est-ce qu’il y a à faire ?',
          autofocus: true,
          onSubmitted: (_) => _submitTask(),
        ),
        const SizedBox(height: 22),
        const MonoLabel('Liste'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final TaskList list in TaskList.values)
              ChoicePill(
                label: list.label,
                isSelected: list == _selectedList,
                onPressed: () => setState(() => _selectedList = list),
              ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: CadenceColors.textAt(0.1))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Récompense à la validation',
                  style: CadenceTextStyles.body(
                    size: 13,
                    height: 1.2,
                    color: CadenceColors.textAt(0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '+${_selectedList.xpReward} XP',
                style: CadenceTextStyles.figure(size: 15, letterSpacing: 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildActions(
          confirmLabel: 'Ajouter à aujourd’hui',
          onConfirm: _submitTask,
        ),
      ],
    );
  }

  Widget _buildRoutineForm() {
    final int stepCount =
        _steps.length + (_stepController.text.trim().isEmpty ? 0 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Nouvelle routine',
          style: CadenceTextStyles.display(size: 24, letterSpacing: -0.035),
        ),
        const SizedBox(height: 4),
        Text(
          'Un bloc d’étapes qui revient aux jours choisis. Chaque étape '
          'compte pour la quête du jour.',
          style: CadenceTextStyles.body(
            size: 13,
            height: 1.5,
            color: CadenceColors.textAt(0.5),
          ),
        ),
        const SizedBox(height: 14),
        SheetTextField(
          controller: _routineNameController,
          hintText: 'Nom de la routine',
        ),
        const SizedBox(height: 22),
        const MonoLabel('Jours'),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            for (int weekday = 0; weekday < 7; weekday++) ...<Widget>[
              if (weekday > 0) const SizedBox(width: 6),
              Expanded(
                child: ChoicePill(
                  label: FrenchCalendar.weekdayInitials[weekday],
                  isSelected: _selectedWeekdays.contains(weekday),
                  isMono: true,
                  fontSize: 12,
                  minHeight: 44,
                  radius: 12,
                  onPressed: () => setState(() {
                    if (!_selectedWeekdays.remove(weekday)) {
                      _selectedWeekdays.add(weekday);
                    }
                  }),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const MonoLabel('Moment'),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                '$stepCount ${stepCount > 1 ? 'étapes' : 'étape'} · '
                '+${stepCount * TaskList.routine.xpReward} XP',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CadenceTextStyles.monoMeta(size: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            for (final RoutineSlot slot in RoutineSlot.values) ...<Widget>[
              if (slot != RoutineSlot.values.first) const SizedBox(width: 6),
              Expanded(
                child: ChoicePill(
                  label: slot.label,
                  isSelected: slot == _selectedSlot,
                  minHeight: 44,
                  onPressed: () => setState(() => _selectedSlot = slot),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 22),
        const MonoLabel('Étapes'),
        const SizedBox(height: 6),
        for (int index = 0; index < _steps.length; index++)
          _StepRow(
            number: (index + 1).toString().padLeft(2, '0'),
            title: _steps[index],
            onRemove: () => setState(() => _steps.removeAt(index)),
          ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: SheetTextField(
                controller: _stepController,
                hintText: 'Ajouter une étape',
                fontSize: 15,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _addStep(),
              ),
            ),
            const SizedBox(width: 10),
            Pressable(
              onPressed: _addStep,
              pressedScale: 0.92,
              semanticLabel: 'Ajouter l’étape',
              child: Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: CadenceColors.white,
                ),
                child: Icon(
                  CadenceIcons.plus,
                  size: 18,
                  color: CadenceColors.onWhite,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildActions(
          confirmLabel: 'Créer la routine',
          onConfirm: stepCount == 0 || _selectedWeekdays.isEmpty
              ? null
              : _submitRoutine,
        ),
      ],
    );
  }

  Widget _buildActions({
    required String confirmLabel,
    required VoidCallback? onConfirm,
  }) {
    return Row(
      children: <Widget>[
        PillButton(
          label: 'Annuler',
          variant: PillButtonVariant.outlined,
          fontSize: 14,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: PillButton(
            label: confirmLabel,
            isExpanded: true,
            onPressed: onConfirm,
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.title,
    required this.onRemove,
  });

  final String number;
  final String title;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CadenceColors.hairline)),
      ),
      child: Row(
        children: <Widget>[
          Text(
            number,
            style: CadenceTextStyles.monoMeta(
              size: 11,
              color: CadenceColors.textAt(0.34),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: CadenceTextStyles.body(size: 15, height: 1.25),
            ),
          ),
          Pressable(
            onPressed: onRemove,
            semanticLabel: 'Retirer l’étape',
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CadenceColors.outline),
              ),
              child: Icon(
                CadenceIcons.minus,
                size: 14,
                color: CadenceColors.textAt(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

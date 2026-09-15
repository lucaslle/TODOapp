import 'package:equatable/equatable.dart';

import 'routine_slot.dart';
import 'task_list.dart';

/// A block of steps that comes back on the chosen days.
///
/// A routine never holds tasks itself: on each of its days it prints one task
/// per step, so the history of what was actually done stays in the tasks and
/// editing a routine never rewrites the past.
class Routine extends Equatable {
  const Routine({
    required this.id,
    required this.name,
    required this.weekdays,
    required this.slot,
    required this.steps,
    required this.isEnabled,
    required this.createdAt,
  });

  final String id;
  final String name;

  /// Monday is 0, Sunday is 6.
  final Set<int> weekdays;

  final RoutineSlot slot;
  final List<String> steps;
  final bool isEnabled;
  final DateTime createdAt;

  bool runsOnWeekday(int weekdayIndex) => weekdays.contains(weekdayIndex);

  int get xpPerRun => steps.length * TaskList.routine.xpReward;

  /// "En semaine · Matin · 3 étapes" — the line under a routine name.
  String describe() {
    final String daysLabel = _daysLabel();
    final String stepsLabel = steps.length > 1
        ? '${steps.length} étapes'
        : '${steps.length} étape';
    return '$daysLabel · ${slot.label} · $stepsLabel';
  }

  String _daysLabel() {
    if (weekdays.length == 7) return 'Tous les jours';
    if (weekdays.length == 5 && weekdays.every((int day) => day < 5)) {
      return 'En semaine';
    }
    if (weekdays.isEmpty) return 'Aucun jour';
    const List<String> initials = <String>['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final List<int> ordered = weekdays.toList()..sort();
    return ordered.map((int day) => initials[day]).join(' ');
  }

  String repeatLabel() => weekdays.length == 7 ? 'Tous les jours' : _daysLabel();

  Routine copyWith({bool? isEnabled}) => Routine(
    id: id,
    name: name,
    weekdays: weekdays,
    slot: slot,
    steps: steps,
    isEnabled: isEnabled ?? this.isEnabled,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    weekdays,
    slot,
    steps,
    isEnabled,
    createdAt,
  ];
}

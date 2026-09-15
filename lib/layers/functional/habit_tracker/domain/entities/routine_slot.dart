/// Moment of the day a routine runs. The slot decides both the label shown on
/// a generated task and the order tasks appear in.
enum RoutineSlot {
  morning('Matin', 'Matin', 0),
  day('Journée', 'Quand tu veux', 1),
  evening('Soir', 'Ce soir', 2);

  const RoutineSlot(this.label, this.taskWhenLabel, this.sortIndex);

  /// Label of the slot itself, as shown in the routine sheet.
  final String label;

  /// Label carried by the tasks this slot generates.
  final String taskWhenLabel;

  final int sortIndex;

  static RoutineSlot fromStorage(String value) => RoutineSlot.values.firstWhere(
    (RoutineSlot slot) => slot.name == value,
    orElse: () => RoutineSlot.morning,
  );
}

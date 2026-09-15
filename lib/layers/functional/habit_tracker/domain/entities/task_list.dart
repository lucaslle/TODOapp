/// The four lists a task can belong to. Each list carries its own reward, so
/// the XP a task is worth is a property of where it lives, not a free field.
enum TaskList {
  routine('Routine', 15),
  home('Maison', 10),
  focus('Focus', 15),
  family('Famille', 25);

  const TaskList(this.label, this.xpReward);

  final String label;
  final int xpReward;

  static TaskList fromStorage(String value) => TaskList.values.firstWhere(
    (TaskList list) => list.name == value,
    orElse: () => TaskList.routine,
  );
}

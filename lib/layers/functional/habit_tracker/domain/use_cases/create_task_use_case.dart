import '../entities/day_key.dart';
import '../entities/task.dart';
import '../entities/task_list.dart';
import '../gateways/task_gateway.dart';

/// Adds a one-off task to today.
class CreateTaskUseCase {
  const CreateTaskUseCase({required TaskGateway taskGateway})
    : _taskGateway = taskGateway;

  final TaskGateway _taskGateway;

  Future<Task> call({required String title, required TaskList list}) async {
    final DayKey today = DayKey.today();
    final String cleanTitle = title.trim();

    return _taskGateway.create(
      Task(
        id: 0,
        day: today,
        title: cleanTitle.isEmpty ? 'Tâche sans titre' : cleanTitle,
        list: list,
        xpReward: list.xpReward,
        whenLabel: 'Aujourd’hui',
        repeatLabel: 'Une fois',
        note: 'Ajoutée depuis la feuille rapide.',
        sortIndex: 900 + DateTime.now().millisecondsSinceEpoch % 100,
      ),
    );
  }
}

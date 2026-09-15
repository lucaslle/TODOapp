import '../entities/day_key.dart';
import '../entities/task.dart';
import '../gateways/task_gateway.dart';

/// How many days in a row a habit has held.
///
/// The walk goes back day by day from the day before [day]. A day where the
/// habit was not asked for at all is skipped rather than counted as a break —
/// a weekday-only routine keeps its chain over the weekend.
class ComputeTaskChainsUseCase {
  const ComputeTaskChainsUseCase({required TaskGateway taskGateway})
    : _taskGateway = taskGateway;

  final TaskGateway _taskGateway;

  static const int _historyDepthInDays = 120;

  /// Chain length per task title, for the titles present in [tasks].
  Future<Map<String, int>> call({
    required DayKey day,
    required List<Task> tasks,
  }) async {
    if (tasks.isEmpty) return const <String, int>{};

    final DayKey from = day.shift(-_historyDepthInDays);
    final List<Task> history = await _taskGateway.tasksBetween(
      from,
      day.previous,
    );

    final Map<String, Map<String, bool>> doneByTitleAndDay =
        <String, Map<String, bool>>{};
    for (final Task task in history) {
      (doneByTitleAndDay[task.title] ??= <String, bool>{})[task.day.value] =
          task.isDone;
    }

    final Map<String, int> chains = <String, int>{};
    for (final Task task in tasks) {
      if (chains.containsKey(task.title)) continue;
      chains[task.title] = _chainFor(
        doneByDay: doneByTitleAndDay[task.title] ?? const <String, bool>{},
        day: day,
      );
    }
    return chains;
  }

  int _chainFor({
    required Map<String, bool> doneByDay,
    required DayKey day,
  }) {
    int chain = 0;
    for (int offset = 1; offset <= _historyDepthInDays; offset++) {
      final bool? wasDone = doneByDay[day.shift(-offset).value];
      if (wasDone == null) continue;
      if (!wasDone) break;
      chain++;
    }
    return chain;
  }
}

/// "Chaîne de 12 jours", or the honest absence of one.
String chainLabelFor(int chainDays) {
  if (chainDays <= 0) return 'Nouvelle habitude';
  if (chainDays == 1) return 'Chaîne de 1 jour';
  return 'Chaîne de $chainDays jours';
}

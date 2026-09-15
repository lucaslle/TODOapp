import '../entities/routine.dart';

abstract interface class RoutineGateway {
  Future<List<Routine>> all();

  Future<void> save(Routine routine);

  Future<void> setEnabled({required String routineId, required bool isEnabled});

  Future<void> deleteById(String routineId);
}

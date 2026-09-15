import '../entities/routine.dart';
import '../entities/routine_slot.dart';
import '../gateways/routine_gateway.dart';
import '../gateways/user_preferences_gateway.dart';

/// Gives a brand new install two routines to push against.
///
/// Only XP, streaks and history are ever left at zero — those have to be
/// earned. Starter routines are just content, and the user can switch them off
/// or delete them from the profile.
class SeedStarterRoutinesUseCase {
  const SeedStarterRoutinesUseCase({
    required RoutineGateway routineGateway,
    required UserPreferencesGateway preferencesGateway,
  }) : _routineGateway = routineGateway,
       _preferencesGateway = preferencesGateway;

  final RoutineGateway _routineGateway;
  final UserPreferencesGateway _preferencesGateway;

  Future<void> call() async {
    final bool hasRunBefore =
        (await _preferencesGateway.read()).lastRolloverDay != null;
    if (hasRunBefore) return;
    if ((await _routineGateway.all()).isNotEmpty) return;

    final DateTime now = DateTime.now();
    await _routineGateway.save(
      Routine(
        id: 'starter-morning',
        name: 'Réveil lent',
        weekdays: const <int>{0, 1, 2, 3, 4},
        slot: RoutineSlot.morning,
        steps: const <String>[
          'Étirements du matin',
          'Faire le lit',
          'Grand verre d’eau',
        ],
        isEnabled: true,
        createdAt: now,
      ),
    );
    await _routineGateway.save(
      Routine(
        id: 'starter-evening',
        name: 'Fermeture du soir',
        weekdays: const <int>{0, 1, 2, 3, 4, 5, 6},
        slot: RoutineSlot.evening,
        steps: const <String>['Lire 20 minutes', 'Préparer demain'],
        isEnabled: true,
        createdAt: now.add(const Duration(milliseconds: 1)),
      ),
    );
  }
}

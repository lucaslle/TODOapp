import 'package:equatable/equatable.dart';

/// The one thing the app asks of a day: close three routine steps before the
/// evening. It pays a flat bonus, once, and resets at midnight.
class DailyQuest extends Equatable {
  const DailyQuest({required this.completedSteps, required this.isRewarded});

  static const int requiredSteps = 3;
  static const int bonusXp = 40;

  static const String title = 'Trois routines avant ce soir';

  /// Routine steps closed today, capped at [requiredSteps].
  final int completedSteps;

  /// Whether the bonus has already been paid for this day.
  final bool isRewarded;

  bool get isCompleted => completedSteps >= requiredSteps;

  String get subtitle => 'Bonus +$bonusXp XP · réinitialisé à minuit';

  String get counterLabel => '$completedSteps · $requiredSteps';

  @override
  List<Object?> get props => <Object?>[completedSteps, isRewarded];
}

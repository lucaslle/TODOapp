import 'package:equatable/equatable.dart';

/// The run of days kept alive, plus the freezes left to cover a miss.
class StreakSummary extends Equatable {
  const StreakSummary({
    required this.currentDays,
    required this.recordDays,
    required this.freezesLeft,
    required this.isTodayCounted,
  });

  static const int freezesPerMonth = 2;

  final int currentDays;
  final int recordDays;
  final int freezesLeft;

  /// True once something has been closed today; until then the run is only
  /// held until midnight.
  final bool isTodayCounted;

  String get protectionLabel =>
      isTodayCounted ? 'comptée pour aujourd’hui' : 'protégée jusqu’à minuit';

  String get freezesLabel => freezesLeft > 1
      ? '$freezesLeft gels disponibles'
      : '$freezesLeft gel disponible';

  @override
  List<Object?> get props => <Object?>[
    currentDays,
    recordDays,
    freezesLeft,
    isTodayCounted,
  ];
}

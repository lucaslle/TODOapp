import 'package:equatable/equatable.dart';

/// Where the user stands on the ladder, and how far the next rung is.
class Level extends Equatable {
  const Level({
    required this.rank,
    required this.name,
    required this.floorXp,
    required this.ceilingXp,
    required this.totalXp,
  });

  final int rank;
  final String name;

  /// XP at which this level was reached.
  final int floorXp;

  /// XP at which the next level starts.
  final int ceilingXp;

  final int totalXp;

  int get xpLeft => (ceilingXp - totalXp).clamp(0, ceilingXp);

  /// Progress inside the current level, 0 to 100.
  int get progressPercent {
    final int span = ceilingXp - floorXp;
    if (span <= 0) return 100;
    final double ratio = (totalXp - floorXp) / span;
    return (ratio * 100).round().clamp(0, 100);
  }

  @override
  List<Object?> get props => <Object?>[rank, name, floorXp, ceilingXp, totalXp];
}

/// The ladder itself.
///
/// The named rungs stop at 15; past that the cadence keeps its last name and
/// each level simply costs another [_xpPerLevelBeyondLadder].
abstract final class LevelLadder {
  static const List<({int rank, String name, int floorXp})> _rungs =
      <({int rank, String name, int floorXp})>[
        (rank: 1, name: 'Première', floorXp: 0),
        (rank: 2, name: 'Naissante', floorXp: 120),
        (rank: 3, name: 'Émergente', floorXp: 280),
        (rank: 4, name: 'Installée', floorXp: 480),
        (rank: 5, name: 'Assurée', floorXp: 680),
        (rank: 6, name: 'Régulière', floorXp: 900),
        (rank: 7, name: 'Constante', floorXp: 1200),
        (rank: 8, name: 'Fiable', floorXp: 1400),
        (rank: 9, name: 'Inébranlable', floorXp: 1700),
        (rank: 10, name: 'Souveraine', floorXp: 2100),
        (rank: 11, name: 'Inaltérable', floorXp: 2600),
        (rank: 12, name: 'Légendaire', floorXp: 3200),
        (rank: 13, name: 'Indélébile', floorXp: 3900),
        (rank: 14, name: 'Immuable', floorXp: 4700),
        (rank: 15, name: 'Éternelle', floorXp: 5600),
      ];

  static const int _xpPerLevelBeyondLadder = 1000;

  static Level at(int totalXp) {
    final int safeXp = totalXp < 0 ? 0 : totalXp;

    for (int index = _rungs.length - 1; index >= 0; index--) {
      final ({int rank, String name, int floorXp}) rung = _rungs[index];
      if (safeXp < rung.floorXp) continue;

      final bool isLastNamedRung = index == _rungs.length - 1;
      if (!isLastNamedRung) {
        return Level(
          rank: rung.rank,
          name: rung.name,
          floorXp: rung.floorXp,
          ceilingXp: _rungs[index + 1].floorXp,
          totalXp: safeXp,
        );
      }

      final int stepsBeyond =
          (safeXp - rung.floorXp) ~/ _xpPerLevelBeyondLadder;
      final int floorXp = rung.floorXp + stepsBeyond * _xpPerLevelBeyondLadder;
      return Level(
        rank: rung.rank + stepsBeyond,
        name: rung.name,
        floorXp: floorXp,
        ceilingXp: floorXp + _xpPerLevelBeyondLadder,
        totalXp: safeXp,
      );
    }

    return Level(
      rank: 1,
      name: _rungs.first.name,
      floorXp: 0,
      ceilingXp: _rungs[1].floorXp,
      totalXp: safeXp,
    );
  }
}

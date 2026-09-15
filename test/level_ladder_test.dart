import 'package:cadence/layers/functional/habit_tracker/domain/entities/level.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelLadder', () {
    test('a fresh account sits on the first rung', () {
      final Level level = LevelLadder.at(0);

      expect(level.rank, 1);
      expect(level.name, 'Première');
      expect(level.progressPercent, 0);
    });

    test('reaching a threshold moves up exactly one rung', () {
      expect(LevelLadder.at(119).rank, 1);
      expect(LevelLadder.at(120).rank, 2);
    });

    test('the named thresholds of the design are honoured', () {
      expect(LevelLadder.at(900).name, 'Régulière');
      expect(LevelLadder.at(1200).name, 'Constante');
      expect(LevelLadder.at(1400).name, 'Fiable');
      expect(LevelLadder.at(1700).name, 'Inébranlable');
    });

    test('progress is measured inside the current rung', () {
      final Level level = LevelLadder.at(1050);

      expect(level.rank, 6);
      expect(level.floorXp, 900);
      expect(level.ceilingXp, 1200);
      expect(level.progressPercent, 50);
      expect(level.xpLeft, 150);
    });

    test('past the named rungs the ladder keeps climbing at a flat cost', () {
      expect(LevelLadder.at(5600).rank, 15);
      expect(LevelLadder.at(6600).rank, 16);
      expect(LevelLadder.at(7600).rank, 17);
      expect(LevelLadder.at(6600).xpLeft, 1000);
    });

    test('negative XP cannot happen but does not crash the ladder', () {
      expect(LevelLadder.at(-50).rank, 1);
    });
  });
}

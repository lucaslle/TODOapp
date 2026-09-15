import 'package:flutter/animation.dart';

/// Motion tokens of the design system.
///
/// The profile "effets de validation" switch collapses every duration to
/// [instant], so a user who dislikes animation gets a still interface rather
/// than a faster one.
abstract final class CadenceMotion {
  static const Curve ease = Cubic(0.22, 1, 0.36, 1);

  static const Duration instant = Duration(milliseconds: 1);
  static const Duration quick = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 300);
  static const Duration sheet = Duration(milliseconds: 260);
  static const Duration celebration = Duration(milliseconds: 340);
  static const Duration bar = Duration(milliseconds: 520);
  static const Duration progress = Duration(milliseconds: 620);

  /// Cheer overlay lifetime, matching the 0.8 s celebration of the design.
  static const Duration cheerHold = Duration(milliseconds: 1100);
}

import 'package:flutter/widgets.dart';

/// Monochrome palette of the Cadence design system.
///
/// Hierarchy comes from scale and inversion, never from hue: one white card
/// per screen carries the action of the moment, everything else sits in
/// [surface] on [background].
abstract final class CadenceColors {
  static const Color background = Color(0xFF0B0B0E);
  static const Color surface = Color(0xFF15151A);
  static const Color white = Color(0xFFFAFAFA);
  static const Color onWhite = Color(0xFF0B0B0E);

  static const Color text = Color(0xFFF2F2F2);

  static Color textAt(double opacity) => text.withValues(alpha: opacity);
  static Color onWhiteAt(double opacity) => onWhite.withValues(alpha: opacity);

  static final Color textStrong = textAt(0.75);
  static final Color textMuted = textAt(0.55);
  static final Color textFaint = textAt(0.40);
  static final Color textGhost = textAt(0.30);

  static final Color hairline = textAt(0.07);
  static final Color outline = textAt(0.16);
  static final Color outlineStrong = textAt(0.22);

  static final Color scrim = const Color(0xFF07070A).withValues(alpha: 0.72);
  static final Color scrimStrong = const Color(0xFF07070A).withValues(alpha: 0.84);
}

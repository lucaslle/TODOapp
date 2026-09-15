import 'package:flutter/widgets.dart';

import 'cadence_colors.dart';

/// Typography of the Cadence design system.
///
/// Inter carries prose and buttons, JetBrains Mono carries every number and
/// every uppercase label — that split is what makes the screens read as one
/// instrument panel.
abstract final class CadenceTextStyles {
  static const String sans = 'Inter';
  static const String mono = 'JetBrainsMono';

  /// Uppercase mono caption, the recurring section label of the app.
  static TextStyle label({
    double size = 10,
    double letterSpacing = 0.2,
    Color? color,
    FontWeight weight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: mono,
    fontSize: size,
    height: 1.0,
    fontWeight: weight,
    letterSpacing: size * letterSpacing,
    color: color ?? CadenceColors.textFaint,
  );

  /// Mono figure used for every counter, level and XP amount.
  static TextStyle figure({
    required double size,
    Color? color,
    FontWeight weight = FontWeight.w700,
    double letterSpacing = -0.04,
    double height = 1.0,
  }) => TextStyle(
    fontFamily: mono,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: size * letterSpacing,
    color: color ?? CadenceColors.text,
  );

  /// Mono body used for metadata lines under a task or a routine.
  static TextStyle monoMeta({
    double size = 11,
    Color? color,
    double letterSpacing = 0,
    FontWeight weight = FontWeight.w400,
  }) => TextStyle(
    fontFamily: mono,
    fontSize: size,
    height: 1.35,
    fontWeight: weight,
    letterSpacing: size * letterSpacing,
    color: color ?? CadenceColors.textFaint,
  );

  static TextStyle display({
    required double size,
    Color? color,
    double letterSpacing = -0.045,
    double height = 1.0,
    FontWeight weight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: sans,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: size * letterSpacing,
    color: color ?? CadenceColors.text,
  );

  static TextStyle body({
    double size = 15,
    Color? color,
    double height = 1.6,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
  }) => TextStyle(
    fontFamily: sans,
    fontSize: size,
    height: height,
    fontWeight: weight,
    letterSpacing: size * letterSpacing,
    color: color ?? CadenceColors.text,
  );

  static TextStyle button({
    double size = 15,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) => TextStyle(
    fontFamily: sans,
    fontSize: size,
    height: 1.0,
    fontWeight: weight,
    color: color ?? CadenceColors.text,
  );
}

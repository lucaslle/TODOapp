import 'package:flutter/widgets.dart';
import 'package:phosphor_glyphs/phosphor_glyphs.dart';

/// The icon set of the design system, named once so screens never repeat the
/// style argument.
abstract final class CadenceIcons {
  static const IconData house = PhosphorIconsRegular.house;
  static const IconData houseFilled = PhosphorIconsFill.house;

  static const IconData flame = PhosphorIconsRegular.flame;
  static const IconData flameFilled = PhosphorIconsFill.flame;

  static const IconData chart = PhosphorIconsRegular.chartBar;
  static const IconData chartFilled = PhosphorIconsFill.chartBar;

  static const IconData user = PhosphorIconsRegular.user;
  static const IconData userFilled = PhosphorIconsFill.user;

  static const IconData check = PhosphorIconsRegular.check;
  static const IconData checkFilled = PhosphorIconsBold.check;

  static const IconData plus = PhosphorIconsRegular.plus;
  static const IconData minus = PhosphorIconsRegular.minus;
  static const IconData trash = PhosphorIconsRegular.trash;
  static const IconData arrowRight = PhosphorIconsRegular.arrowRight;
  static const IconData arrowUpRight = PhosphorIconsRegular.arrowUpRight;
  static const IconData pencil = PhosphorIconsRegular.pencilSimple;
}

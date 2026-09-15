import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The icon set of the design system, named once so screens never repeat the
/// style argument.
abstract final class CadenceIcons {
  static IconData get house => PhosphorIcons.house();
  static IconData get houseFilled => PhosphorIcons.house(PhosphorIconsStyle.fill);

  static IconData get flame => PhosphorIcons.flame();
  static IconData get flameFilled => PhosphorIcons.flame(PhosphorIconsStyle.fill);

  static IconData get chart => PhosphorIcons.chartBar();
  static IconData get chartFilled =>
      PhosphorIcons.chartBar(PhosphorIconsStyle.fill);

  static IconData get user => PhosphorIcons.user();
  static IconData get userFilled => PhosphorIcons.user(PhosphorIconsStyle.fill);

  static IconData get check => PhosphorIcons.check();
  static IconData get checkFilled => PhosphorIcons.check(PhosphorIconsStyle.bold);

  static IconData get plus => PhosphorIcons.plus();
  static IconData get minus => PhosphorIcons.minus();
  static IconData get trash => PhosphorIcons.trash();
  static IconData get arrowRight => PhosphorIcons.arrowRight();
  static IconData get arrowUpRight => PhosphorIcons.arrowUpRight();
  static IconData get pencil => PhosphorIcons.pencilSimple();
}

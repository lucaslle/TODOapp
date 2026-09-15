import 'package:flutter/material.dart';

import 'cadence_colors.dart';
import 'cadence_text_styles.dart';

abstract final class CadenceTheme {
  static ThemeData build() {
    final ThemeData base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: CadenceColors.background,
      canvasColor: CadenceColors.background,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      colorScheme: base.colorScheme.copyWith(
        surface: CadenceColors.background,
        primary: CadenceColors.white,
        onPrimary: CadenceColors.onWhite,
        secondary: CadenceColors.white,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: CadenceColors.white,
        selectionColor: CadenceColors.textAt(0.24),
        selectionHandleColor: CadenceColors.white,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: CadenceTextStyles.sans,
        bodyColor: CadenceColors.text,
        displayColor: CadenceColors.text,
      ),
    );
  }
}

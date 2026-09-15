import 'package:flutter/widgets.dart';

import '../cadence_colors.dart';
import '../cadence_text_styles.dart';
import 'pressable.dart';

/// Selectable pill: white filled when chosen, hairline outline otherwise.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.minHeight = 42,
    this.radius = 999,
    this.isMono = false,
    this.fontSize = 13,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final double minHeight;
  final double radius;
  final bool isMono;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = isMono
        ? CadenceTextStyles.monoMeta(
            size: fontSize,
            weight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? CadenceColors.onWhite : CadenceColors.textAt(0.55),
          )
        : CadenceTextStyles.button(
            size: fontSize,
            weight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected ? CadenceColors.onWhite : CadenceColors.textAt(0.65),
          );

    return Pressable(
      onPressed: onPressed,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.symmetric(horizontal: radius == 999 ? 16 : 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? CadenceColors.white : null,
          borderRadius: BorderRadius.circular(radius),
          border: isSelected ? null : Border.all(color: CadenceColors.outline),
        ),
        child: Text(label, style: style, maxLines: 1),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../cadence_colors.dart';
import '../cadence_text_styles.dart';
import 'pressable.dart';

enum PillButtonVariant { filled, outlined, ghost }

/// The rounded action of the design system: a filled white pill for the
/// primary move, an outlined one for the escape hatch.
class PillButton extends StatelessWidget {
  const PillButton({
    required this.label,
    required this.onPressed,
    this.variant = PillButtonVariant.filled,
    this.icon,
    this.trailingIcon,
    this.minHeight = 52,
    this.fontSize = 15,
    this.horizontalPadding,
    this.isExpanded = false,
    this.isAnimated = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final PillButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final double minHeight;
  final double fontSize;
  final double? horizontalPadding;
  final bool isExpanded;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final bool isFilled = variant == PillButtonVariant.filled;
    final Color foreground = switch (variant) {
      PillButtonVariant.filled => CadenceColors.onWhite,
      PillButtonVariant.outlined => CadenceColors.textAt(0.7),
      PillButtonVariant.ghost => CadenceColors.textAt(0.45),
    };

    final Widget labelRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: fontSize + 1, color: foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CadenceTextStyles.button(
              size: fontSize,
              color: foreground,
              weight: isFilled ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    final Widget content = Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? (trailingIcon != null ? 22 : 20),
      ),
      decoration: BoxDecoration(
        color: isFilled ? CadenceColors.white : null,
        borderRadius: BorderRadius.circular(999),
        border: variant == PillButtonVariant.outlined
            ? Border.all(color: CadenceColors.textAt(0.14))
            : null,
      ),
      child: trailingIcon == null
          ? Center(widthFactor: isExpanded ? null : 1, child: labelRow)
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(child: labelRow),
                Icon(trailingIcon, size: 18, color: foreground),
              ],
            ),
    );

    return Pressable(
      onPressed: onPressed,
      isAnimated: isAnimated,
      pressedScale: 0.98,
      child: isExpanded ? SizedBox(width: double.infinity, child: content) : content,
    );
  }
}

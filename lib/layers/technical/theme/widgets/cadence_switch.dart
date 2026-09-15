import 'package:flutter/widgets.dart';

import '../cadence_colors.dart';
import '../cadence_motion.dart';

/// 48x28 monochrome switch: white track when on, hollow outline when off.
class CadenceSwitch extends StatelessWidget {
  const CadenceSwitch({
    required this.isOn,
    required this.onChanged,
    required this.semanticLabel,
    this.isAnimated = true,
    super.key,
  });

  final bool isOn;
  final ValueChanged<bool> onChanged;
  final String semanticLabel;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    final Duration duration = isAnimated ? CadenceMotion.base : CadenceMotion.instant;
    return Semantics(
      toggled: isOn,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!isOn),
        child: AnimatedContainer(
          duration: duration,
          curve: CadenceMotion.ease,
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isOn ? CadenceColors.white : null,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isOn ? CadenceColors.white : CadenceColors.outlineStrong,
            ),
          ),
          child: AnimatedAlign(
            duration: duration,
            curve: CadenceMotion.ease,
            alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: duration,
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOn ? CadenceColors.onWhite : CadenceColors.textAt(0.35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../cadence_motion.dart';

/// Tap target that shrinks slightly while held, the single press feedback of
/// the design system (Material ink is disabled app-wide).
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    required this.onPressed,
    this.pressedScale = 0.96,
    this.isAnimated = true,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double pressedScale;
  final bool isAnimated;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: isEnabled ? (_) => _setPressed(true) : null,
        onTapUp: isEnabled ? (_) => _setPressed(false) : null,
        onTapCancel: isEnabled ? () => _setPressed(false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed && isEnabled ? widget.pressedScale : 1.0,
          duration: widget.isAnimated ? CadenceMotion.quick : CadenceMotion.instant,
          curve: CadenceMotion.ease,
          child: widget.child,
        ),
      ),
    );
  }
}

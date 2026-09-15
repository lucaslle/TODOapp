import 'package:flutter/widgets.dart';

import '../cadence_colors.dart';

/// Grey block that groups a section. Every screen stacks these under its one
/// white card.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 18),
    this.radius = 20,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: CadenceColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// The single white card a screen is allowed to carry.
class HighlightCard extends StatelessWidget {
  const HighlightCard({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 18),
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: CadenceColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}

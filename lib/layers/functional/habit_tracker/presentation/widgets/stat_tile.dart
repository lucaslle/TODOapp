import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/section_card.dart';

/// Small grey tile: a mono label over a large mono figure.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.caption,
    this.figureSize = 24,
    this.radius = 16,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final double figureSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      radius: radius,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label.toUpperCase(),
            style: CadenceTextStyles.label(size: 9, letterSpacing: 0.18),
          ),
          const SizedBox(height: 9),
          Text(value, style: CadenceTextStyles.figure(size: figureSize)),
          if (caption != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: CadenceTextStyles.body(
                size: 11,
                height: 1.2,
                color: CadenceColors.textFaint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

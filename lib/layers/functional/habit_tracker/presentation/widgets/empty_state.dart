import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_text_styles.dart';

/// Shown instead of a list when there is genuinely nothing yet. It says what
/// the screen will hold rather than apologising for being empty.
class EmptyState extends StatelessWidget {
  const EmptyState({required this.title, required this.body, super.key});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: CadenceTextStyles.body(
              size: 16,
              height: 1.35,
              color: CadenceColors.textAt(0.72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: CadenceTextStyles.body(
              size: 13,
              height: 1.55,
              color: CadenceColors.textFaint,
            ),
          ),
        ],
      ),
    );
  }
}

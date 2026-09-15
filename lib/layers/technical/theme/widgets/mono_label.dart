import 'package:flutter/widgets.dart';

import '../cadence_text_styles.dart';

/// Uppercase mono caption used as a section heading everywhere in the app.
class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {this.color, this.size = 10, super.key});

  final String text;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: CadenceTextStyles.label(size: size, color: color),
    );
  }
}

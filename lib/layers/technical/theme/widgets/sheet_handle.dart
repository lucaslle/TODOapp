import 'package:flutter/widgets.dart';

import '../cadence_colors.dart';

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 3,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: CadenceColors.textAt(0.2),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

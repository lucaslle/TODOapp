import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/pill_button.dart';
import 'cadence_sheet.dart';

enum PhotoAction { choose, remove }

/// Offered when the profile already has a photo: swap it or drop it.
class PhotoActionsSheet extends StatelessWidget {
  const PhotoActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CadenceSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Photo de profil',
            style: CadenceTextStyles.display(size: 24, letterSpacing: -0.035),
          ),
          const SizedBox(height: 22),
          PillButton(
            label: 'Choisir une autre photo',
            isExpanded: true,
            onPressed: () => Navigator.of(context).pop(PhotoAction.choose),
          ),
          const SizedBox(height: 10),
          PillButton(
            label: 'Retirer la photo',
            variant: PillButtonVariant.outlined,
            isExpanded: true,
            fontSize: 14,
            onPressed: () => Navigator.of(context).pop(PhotoAction.remove),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/pressable.dart';
import '../../domain/entities/level.dart';

/// Crossing a level inverts the whole screen — the one moment the app goes
/// white edge to edge.
class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    required this.level,
    required this.isAnimated,
    required this.onDismiss,
    super.key,
  });

  final Level level;
  final bool isAnimated;
  final VoidCallback onDismiss;

  /// What the new rung unlocks, in the app's own terms.
  static const String _blurb =
      'Tes soirées tiennent aussi bien que tes matins. Les quêtes paient un '
      'bonus et les gels se rechargent deux fois par mois.';

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CadenceColors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'NIVEAU SUPÉRIEUR',
                style: CadenceTextStyles.label(
                  letterSpacing: 0.22,
                  color: CadenceColors.onWhiteAt(0.5),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${level.rank}',
                    style: CadenceTextStyles.figure(
                      size: 140,
                      height: 0.8,
                      letterSpacing: -0.08,
                      color: CadenceColors.onWhite,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'NIV',
                      style: CadenceTextStyles.label(
                        size: 11,
                        letterSpacing: 0.14,
                        color: CadenceColors.onWhiteAt(0.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                level.name,
                style: CadenceTextStyles.display(
                  size: 38,
                  color: CadenceColors.onWhite,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _blurb,
                style: CadenceTextStyles.body(
                  height: 1.55,
                  color: CadenceColors.onWhiteAt(0.62),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.only(top: 18),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: CadenceColors.onWhiteAt(0.16)),
                  ),
                ),
                child: Text(
                  'BONUS DE QUÊTE DÉBLOQUÉ',
                  style: CadenceTextStyles.label(
                    size: 11,
                    letterSpacing: 0.14,
                    color: CadenceColors.onWhiteAt(0.55),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Pressable(
                onPressed: onDismiss,
                pressedScale: 0.98,
                isAnimated: isAnimated,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: CadenceColors.onWhite,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Continuer',
                    style: CadenceTextStyles.button(color: CadenceColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

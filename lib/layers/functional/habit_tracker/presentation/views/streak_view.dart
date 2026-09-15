import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_motion.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/mono_label.dart';
import '../../../../technical/theme/widgets/section_card.dart';
import '../../domain/entities/month_calendar.dart';
import '../../domain/entities/streak_summary.dart';
import '../widgets/streak_calendar.dart';

class StreakView extends StatelessWidget {
  const StreakView({
    required this.streak,
    required this.calendar,
    required this.isAnimated,
    super.key,
  });

  final StreakSummary streak;
  final MonthCalendar calendar;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 110),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'Série',
            style: CadenceTextStyles.display(size: 30, letterSpacing: -0.04),
          ),
        ),
        const SizedBox(height: 16),
        HighlightCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'JOURS D’AFFILÉE',
                style: CadenceTextStyles.label(
                  color: CadenceColors.onWhiteAt(0.5),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${streak.currentDays}',
                    style: CadenceTextStyles.figure(
                      size: 76,
                      height: 0.82,
                      letterSpacing: -0.07,
                      color: CadenceColors.onWhite,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Record ${streak.recordDays}\n${streak.protectionLabel}',
                        style: CadenceTextStyles.body(
                          size: 13,
                          height: 1.4,
                          color: CadenceColors.onWhiteAt(0.6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _RecordBar(
                fraction: streak.recordDays == 0
                    ? 0
                    : streak.currentDays / streak.recordDays,
                isAnimated: isAnimated,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        StreakCalendar(calendar: calendar),
        const SizedBox(height: 8),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Une seule tâche garde la série en vie. Un jour manqué, un gel '
                'le couvre — deux par mois.',
                style: CadenceTextStyles.body(size: 14, height: 1.55),
              ),
              const SizedBox(height: 10),
              MonoLabel(
                streak.freezesLabel,
                size: 11,
                color: CadenceColors.textAt(0.42),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordBar extends StatelessWidget {
  const _RecordBar({required this.fraction, required this.isAnimated});

  final double fraction;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Container(
          height: 3,
          decoration: BoxDecoration(
            color: CadenceColors.onWhiteAt(0.14),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: isAnimated
                  ? CadenceMotion.progress
                  : CadenceMotion.instant,
              curve: CadenceMotion.ease,
              width: constraints.maxWidth * fraction.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: CadenceColors.onWhite,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        );
      },
    );
  }
}

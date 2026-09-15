import 'package:flutter/widgets.dart';

import '../../../../technical/formatting/french_calendar.dart';
import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_motion.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/mono_label.dart';
import '../../../../technical/theme/widgets/section_card.dart';
import '../../domain/entities/habit_stats.dart';

/// XP closed per day of the current week. Bars are relative to the best day,
/// and the best days are the ones drawn in solid white.
class WeeklyXpChart extends StatelessWidget {
  const WeeklyXpChart({
    required this.dailyXp,
    required this.weekXp,
    required this.weekXpGoal,
    required this.isAnimated,
    super.key,
  });

  final List<DailyXp> dailyXp;
  final int weekXp;
  final int weekXpGoal;
  final bool isAnimated;

  static const double _chartHeight = 126;

  @override
  Widget build(BuildContext context) {
    final int best = dailyXp.fold(
      0,
      (int top, DailyXp day) => day.xp > top ? day.xp : top,
    );

    return SectionCard(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const MonoLabel('XP par jour'),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  '$weekXp / $weekXpGoal',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CadenceTextStyles.monoMeta(
                    size: 11,
                    weight: FontWeight.w500,
                    color: CadenceColors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: _chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                for (final DailyXp day in dailyXp)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _Bar(
                        heightFactor: best == 0 ? 0 : day.xp / best,
                        initial:
                            FrenchCalendar.weekdayInitials[day.weekdayIndex],
                        isBest: day.xp > 0 && day.xp >= best,
                        isAnimated: isAnimated,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.heightFactor,
    required this.initial,
    required this.isBest,
    required this.isAnimated,
  });

  final double heightFactor;
  final String initial;
  final bool isBest;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: heightFactor.clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: isAnimated ? CadenceMotion.bar : CadenceMotion.instant,
              curve: CadenceMotion.ease,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isBest
                    ? CadenceColors.white
                    : CadenceColors.textAt(0.26),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          initial,
          style: CadenceTextStyles.monoMeta(
            size: 10,
            color: CadenceColors.textAt(0.34),
          ),
        ),
      ],
    );
  }
}

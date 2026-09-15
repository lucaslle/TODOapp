import 'package:flutter/widgets.dart';

import '../../../../technical/formatting/french_calendar.dart';
import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/mono_label.dart';
import '../../../../technical/theme/widgets/section_card.dart';
import '../../domain/entities/month_calendar.dart';

/// The month as a grid of squares: solid white for a day fully closed, a
/// lighter grey when it was partial, near-black when it asked nothing.
class StreakCalendar extends StatelessWidget {
  const StreakCalendar({required this.calendar, super.key});

  final MonthCalendar calendar;

  Color _backgroundFor(DayCellStatus status) => switch (status) {
    DayCellStatus.full => CadenceColors.white,
    DayCellStatus.partial => CadenceColors.textAt(0.34),
    DayCellStatus.rest => CadenceColors.textAt(0.07),
    DayCellStatus.upcoming => CadenceColors.textAt(0.04),
  };

  Color _foregroundFor(DayCellStatus status) => switch (status) {
    DayCellStatus.full => CadenceColors.onWhite,
    DayCellStatus.partial => CadenceColors.onWhite,
    DayCellStatus.rest => CadenceColors.textAt(0.72),
    DayCellStatus.upcoming => CadenceColors.textAt(0.26),
  };

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MonoLabel(
            FrenchCalendar.monthAndYear(
              year: calendar.year,
              month: calendar.month,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              for (final String initial in FrenchCalendar.weekdayInitials)
                Expanded(
                  child: Center(
                    child: Text(
                      initial,
                      style: CadenceTextStyles.monoMeta(
                        size: 9,
                        color: CadenceColors.textGhost,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            mainAxisSpacing: 5,
            crossAxisSpacing: 5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              for (int blank = 0; blank < calendar.leadingBlanks; blank++)
                const SizedBox.shrink(),
              for (final DayCell cell in calendar.cells)
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: _backgroundFor(cell.status),
                    borderRadius: BorderRadius.circular(8),
                    border: cell.isToday
                        ? Border.all(color: CadenceColors.white, width: 1.5)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${cell.dayNumber}',
                      style: CadenceTextStyles.monoMeta(
                        size: 12,
                        color: _foregroundFor(cell.status),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _LegendItem(
                color: CadenceColors.white,
                label: 'Tout',
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: CadenceColors.textAt(0.34),
                label: 'Partiel',
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: CadenceColors.textAt(0.09),
                label: 'Repos',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label.toUpperCase(),
          style: CadenceTextStyles.monoMeta(
            size: 9,
            letterSpacing: 0.1,
            color: CadenceColors.textAt(0.38),
          ),
        ),
      ],
    );
  }
}

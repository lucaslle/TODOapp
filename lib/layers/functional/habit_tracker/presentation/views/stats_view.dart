import 'package:flutter/widgets.dart';

import '../../../../technical/formatting/french_calendar.dart';
import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/mono_label.dart';
import '../../../../technical/theme/widgets/section_card.dart';
import '../../domain/entities/habit_stats.dart';
import '../widgets/empty_state.dart';
import '../widgets/stat_tile.dart';
import '../widgets/weekly_xp_chart.dart';

class StatsView extends StatelessWidget {
  const StatsView({required this.stats, required this.isAnimated, super.key});

  final HabitStats stats;
  final bool isAnimated;

  /// Each insight carries figures; the sentence is written here.
  String _sentenceFor(TrendInsight insight) => switch (insight) {
    TimeOfDayInsight(:final int percent, isMorning: true) =>
      'Les matins te portent — $percent% des tâches closes avant '
          '${TimeOfDayInsight.cutoffHour}h.',
    TimeOfDayInsight(:final int percent) =>
      'Tu closes surtout plus tard — $percent% des tâches après '
          '${TimeOfDayInsight.cutoffHour}h.',
    WeakWeekdayInsight(
      :final int weekdayIndex,
      :final int suggestedWeekdayIndex,
      :final int completionPercent,
    ) =>
      'Le ${FrenchCalendar.weekdayName(weekdayIndex)} bloque — '
          '$completionPercent% seulement. Déplace deux tâches au '
          '${FrenchCalendar.weekdayName(suggestedWeekdayIndex)}.',
    LongestHabitInsight(:final String title, :final int days) =>
      '$title : ta plus longue habitude, $days jours.',
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 110),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'Stats',
            style: CadenceTextStyles.display(size: 30, letterSpacing: -0.04),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: StatTile(
                label: 'Semaine',
                value: '${stats.weekCompletedCount}',
                caption: 'tâches closes',
                figureSize: 30,
                radius: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: 'Régularité',
                value: '${stats.consistencyPercent}%',
                caption: stats.consistencyDeltaLabel,
                figureSize: 30,
                radius: 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        WeeklyXpChart(
          dailyXp: stats.dailyXp,
          weekXp: stats.weekXp,
          weekXpGoal: stats.weekXpGoal,
          isAnimated: isAnimated,
        ),
        const SizedBox(height: 8),
        SectionCard(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MonoLabel('Tendances'),
              if (stats.insights.isEmpty)
                const EmptyState(
                  title: 'Pas encore de tendance.',
                  body: 'Quelques jours de plus et Momentum pourra dire quelque '
                      'chose d’utile sur ton rythme.',
                ),
              for (int index = 0; index < stats.insights.length; index++)
                _InsightRow(
                  number: (index + 1).toString().padLeft(2, '0'),
                  text: _sentenceFor(stats.insights[index]),
                  hasDivider: index < stats.insights.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.number,
    required this.text,
    required this.hasDivider,
  });

  final String number;
  final String text;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: hasDivider
            ? Border(bottom: BorderSide(color: CadenceColors.hairline))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              number,
              style: CadenceTextStyles.monoMeta(
                size: 11,
                color: CadenceColors.textAt(0.34),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: CadenceTextStyles.body(size: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

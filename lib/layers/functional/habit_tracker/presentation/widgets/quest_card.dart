import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_motion.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/pressable.dart';
import '../../../../technical/theme/widgets/section_card.dart';
import '../../domain/entities/daily_quest.dart';
import '../../domain/entities/level.dart';

/// The one white card of the Today screen: the quest, where the user stands,
/// and the two ways to act on the next task.
class QuestCard extends StatelessWidget {
  const QuestCard({
    required this.quest,
    required this.level,
    required this.streakDays,
    required this.isAnimated,
    required this.onOpenNextTask,
    required this.onCompleteNextTask,
    super.key,
  });

  final DailyQuest quest;
  final Level level;
  final int streakDays;
  final bool isAnimated;
  final VoidCallback? onOpenNextTask;
  final VoidCallback? onCompleteNextTask;

  @override
  Widget build(BuildContext context) {
    return HighlightCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'QUÊTE DU JOUR',
                style: CadenceTextStyles.label(
                  color: CadenceColors.onWhiteAt(0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: CadenceColors.onWhiteAt(0.3)),
                ),
                child: Text(
                  quest.counterLabel,
                  style: CadenceTextStyles.label(
                    letterSpacing: 0.14,
                    color: CadenceColors.onWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            DailyQuest.title,
            style: CadenceTextStyles.display(
              size: 27,
              height: 1.08,
              letterSpacing: -0.035,
              color: CadenceColors.onWhite,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            quest.subtitle,
            style: CadenceTextStyles.body(
              size: 13,
              height: 1.4,
              color: CadenceColors.onWhiteAt(0.6),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              _Figure(label: 'Niveau', value: '${level.rank}'),
              const SizedBox(width: 26),
              _Figure(label: 'XP', value: '${level.totalXp}'),
              const SizedBox(width: 26),
              _Figure(label: 'Série', value: '${streakDays}j'),
            ],
          ),
          const SizedBox(height: 18),
          _ProgressBar(percent: level.progressPercent, isAnimated: isAnimated),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                level.name,
                style: CadenceTextStyles.monoMeta(
                  size: 10,
                  color: CadenceColors.onWhiteAt(0.5),
                ),
              ),
              Text(
                '${level.xpLeft} XP restants',
                style: CadenceTextStyles.monoMeta(
                  size: 10,
                  color: CadenceColors.onWhiteAt(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: Pressable(
                  onPressed: onOpenNextTask,
                  pressedScale: 0.98,
                  isAnimated: isAnimated,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: onOpenNextTask == null
                          ? CadenceColors.onWhiteAt(0.25)
                          : CadenceColors.onWhite,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      onOpenNextTask == null
                          ? 'Tout est fait'
                          : 'Voir la prochaine tâche',
                      style: CadenceTextStyles.button(
                        size: 14,
                        color: CadenceColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pressable(
                onPressed: onCompleteNextTask,
                pressedScale: 0.92,
                isAnimated: isAnimated,
                semanticLabel: 'Valider la prochaine tâche',
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: CadenceColors.onWhiteAt(0.3)),
                  ),
                  child: Icon(
                    CadenceIcons.check,
                    size: 19,
                    color: onCompleteNextTask == null
                        ? CadenceColors.onWhiteAt(0.3)
                        : CadenceColors.onWhite,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: CadenceTextStyles.label(
            size: 9,
            letterSpacing: 0.18,
            color: CadenceColors.onWhiteAt(0.5),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: CadenceTextStyles.figure(
            size: 26,
            color: CadenceColors.onWhite,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.percent, required this.isAnimated});

  final int percent;
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
              width: constraints.maxWidth * percent / 100,
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

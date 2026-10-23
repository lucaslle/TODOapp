import 'package:flutter/widgets.dart';

import '../../../../technical/media/stored_image.dart';
import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/cadence_switch.dart';
import '../../../../technical/theme/widgets/mono_label.dart';
import '../../../../technical/theme/widgets/pill_button.dart';
import '../../../../technical/theme/widgets/pressable.dart';
import '../../../../technical/theme/widgets/section_card.dart';
import '../../domain/entities/habit_board.dart';
import '../../domain/entities/routine.dart';
import '../widgets/empty_state.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({
    required this.board,
    required this.isAnimated,
    required this.onEditName,
    required this.onEditAvatar,
    required this.onCreateRoutine,
    required this.onToggleRoutine,
    required this.onDeleteRoutine,
    required this.onToggleReminder,
    required this.onToggleEffects,
    required this.onReplayOnboarding,
    super.key,
  });

  final HabitBoard board;
  final bool isAnimated;
  final VoidCallback onEditName;
  final VoidCallback onEditAvatar;
  final VoidCallback onCreateRoutine;
  final void Function(Routine routine, bool isEnabled) onToggleRoutine;
  final ValueChanged<Routine> onDeleteRoutine;
  final ValueChanged<bool> onToggleReminder;
  final ValueChanged<bool> onToggleEffects;
  final VoidCallback onReplayOnboarding;

  @override
  Widget build(BuildContext context) {
    final String displayName = board.preferences.displayName;
    final String? avatarPath = board.preferences.avatarPath;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 110),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            'Profil',
            style: CadenceTextStyles.display(size: 30, letterSpacing: -0.04),
          ),
        ),
        const SizedBox(height: 16),
        Pressable(
          onPressed: onEditName,
          pressedScale: 0.99,
          isAnimated: isAnimated,
          child: SectionCard(
            child: Row(
              children: <Widget>[
                Pressable(
                  onPressed: onEditAvatar,
                  semanticLabel: 'Changer la photo de profil',
                  isAnimated: isAnimated,
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: CadenceColors.textAt(0.16)),
                    ),
                    child: avatarPath == null
                        ? _AvatarInitial(displayName: displayName)
                        : storedImage(
                            avatarPath,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _AvatarInitial(displayName: displayName),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        displayName.isEmpty ? 'Ton prénom' : displayName,
                        style: CadenceTextStyles.body(
                          size: 19,
                          height: 1.2,
                          weight: FontWeight.w600,
                          letterSpacing: -0.02,
                          color: displayName.isEmpty
                              ? CadenceColors.textAt(0.45)
                              : CadenceColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      MonoLabel(
                        'NIV ${board.level.rank} · ${board.level.name} · '
                        '${board.level.totalXp} XP',
                        size: 11,
                        color: CadenceColors.textAt(0.42),
                      ),
                    ],
                  ),
                ),
                Icon(
                  CadenceIcons.pencil,
                  size: 16,
                  color: CadenceColors.textFaint,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MonoLabel('Sur cet appareil'),
              const SizedBox(height: 12),
              Text(
                'Tâches, séries et stats vivent dans une base locale. Aucun '
                'compte, aucune synchronisation, rien qui sorte du téléphone.',
                style: CadenceTextStyles.body(
                  size: 13,
                  height: 1.55,
                  color: CadenceColors.textAt(0.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const MonoLabel('Routines'),
                  PillButton(
                    label: 'Créer',
                    icon: CadenceIcons.plus,
                    fontSize: 12,
                    minHeight: 40,
                    horizontalPadding: 14,
                    isAnimated: isAnimated,
                    onPressed: onCreateRoutine,
                  ),
                ],
              ),
              if (board.routines.isEmpty)
                const EmptyState(
                  title: 'Aucune routine.',
                  body: 'Une routine imprime ses étapes toute seule les jours '
                      'choisis — c’est ce qui nourrit la quête du jour.',
                ),
              for (int index = 0; index < board.routines.length; index++)
                _RoutineRow(
                  routine: board.routines[index],
                  isAnimated: isAnimated,
                  hasDivider: index < board.routines.length - 1,
                  onToggle: (bool isEnabled) =>
                      onToggleRoutine(board.routines[index], isEnabled),
                  onDelete: () => onDeleteRoutine(board.routines[index]),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SectionCard(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const MonoLabel('Réglages'),
              _SettingRow(
                title: 'Rappel du soir',
                caption: '20h30, seulement s’il reste quelque chose',
                isOn: board.preferences.isReminderEnabled,
                isAnimated: isAnimated,
                onChanged: onToggleReminder,
              ),
              _SettingRow(
                title: 'Effets de validation',
                caption: 'Animation courte quand une tâche se ferme',
                isOn: board.preferences.areEffectsEnabled,
                isAnimated: isAnimated,
                hasDivider: false,
                onChanged: onToggleEffects,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PillButton(
          label: 'Revoir l’onboarding',
          variant: PillButtonVariant.outlined,
          fontSize: 13,
          isExpanded: true,
          isAnimated: isAnimated,
          onPressed: onReplayOnboarding,
        ),
      ],
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Text(
      displayName.isEmpty ? '—' : displayName.substring(0, 1).toUpperCase(),
      style: CadenceTextStyles.figure(
        size: 22,
        color: CadenceColors.textAt(0.7),
      ),
    );
  }
}

class _RoutineRow extends StatelessWidget {
  const _RoutineRow({
    required this.routine,
    required this.isAnimated,
    required this.hasDivider,
    required this.onToggle,
    required this.onDelete,
  });

  final Routine routine;
  final bool isAnimated;
  final bool hasDivider;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onDelete,
      child: Container(
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: hasDivider
              ? Border(bottom: BorderSide(color: CadenceColors.hairline))
              : null,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    routine.name,
                    style: CadenceTextStyles.body(size: 15, height: 1.25),
                  ),
                  const SizedBox(height: 5),
                  MonoLabel(
                    routine.describe(),
                    color: CadenceColors.textAt(0.38),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            CadenceSwitch(
              isOn: routine.isEnabled,
              isAnimated: isAnimated,
              semanticLabel: 'Activer ${routine.name}',
              onChanged: onToggle,
            ),
            const SizedBox(width: 12),
            Pressable(
              onPressed: onDelete,
              semanticLabel: 'Supprimer ${routine.name}',
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CadenceColors.outline),
                ),
                child: Icon(
                  CadenceIcons.trash,
                  size: 14,
                  color: CadenceColors.textAt(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.caption,
    required this.isOn,
    required this.isAnimated,
    required this.onChanged,
    this.hasDivider = true,
  });

  final String title;
  final String caption;
  final bool isOn;
  final bool isAnimated;
  final ValueChanged<bool> onChanged;
  final bool hasDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: hasDivider
            ? Border(bottom: BorderSide(color: CadenceColors.hairline))
            : null,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: CadenceTextStyles.body(size: 15, height: 1.2),
                ),
                const SizedBox(height: 5),
                Text(
                  caption,
                  style: CadenceTextStyles.monoMeta(
                    size: 10,
                    color: CadenceColors.textAt(0.38),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          CadenceSwitch(
            isOn: isOn,
            isAnimated: isAnimated,
            semanticLabel: title,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

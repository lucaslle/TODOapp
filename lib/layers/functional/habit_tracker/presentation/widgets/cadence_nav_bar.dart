import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_motion.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../cubit/habit_state.dart';

/// Floating glass pill at the bottom of every screen. The active tab is a
/// solid lighter chip — the only place in the app where two whites meet.
class CadenceNavBar extends StatelessWidget {
  const CadenceNavBar({
    required this.currentTab,
    required this.onTabSelected,
    required this.isAnimated,
    super.key,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;
  final bool isAnimated;

  static const List<({AppTab tab, String label})> _items =
      <({AppTab tab, String label})>[
        (tab: AppTab.today, label: 'Aujourd’hui'),
        (tab: AppTab.streak, label: 'Série'),
        (tab: AppTab.stats, label: 'Stats'),
        (tab: AppTab.profile, label: 'Profil'),
      ];

  IconData _iconFor(AppTab tab, {required bool isActive}) => switch (tab) {
    AppTab.today => isActive ? CadenceIcons.houseFilled : CadenceIcons.house,
    AppTab.streak => isActive ? CadenceIcons.flameFilled : CadenceIcons.flame,
    AppTab.stats => isActive ? CadenceIcons.chartFilled : CadenceIcons.chart,
    AppTab.profile => isActive ? CadenceIcons.userFilled : CadenceIcons.user,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0x61FFFFFF),
            Color(0x0AFFFFFF),
            Color(0x00FFFFFF),
            Color(0x24FFFFFF),
          ],
          stops: <double>[0, 0.32, 0.58, 1],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x80000000),
            blurRadius: 38,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.all(6),
          color: const Color(0x14FFFFFF),
          child: Row(
            children: <Widget>[
              for (final ({AppTab tab, String label}) item in _items)
                Expanded(
                  child: _NavItem(
                    label: item.label,
                    icon: _iconFor(item.tab, isActive: item.tab == currentTab),
                    isActive: item.tab == currentTab,
                    isAnimated: isAnimated,
                    onPressed: () => onTabSelected(item.tab),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isAnimated,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final bool isAnimated;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color foreground = isActive
        ? const Color(0xFFFFFFFF)
        : const Color(0x8CFFFFFF);

    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: AnimatedContainer(
          duration: isAnimated ? CadenceMotion.base : CadenceMotion.instant,
          curve: CadenceMotion.ease,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(0, 9, 0, 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isActive ? const Color(0x80FFFFFF) : CadenceColors.textAt(0),
            ),
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[Color(0x42FFFFFF), Color(0x1AFFFFFF)],
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 19, color: foreground),
              const SizedBox(height: 5),
              Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: CadenceTextStyles.label(
                  size: 8,
                  letterSpacing: 0.1,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

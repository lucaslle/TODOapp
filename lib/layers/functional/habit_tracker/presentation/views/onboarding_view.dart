import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_motion.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../../../../technical/theme/widgets/momentum_logo.dart';
import '../../../../technical/theme/widgets/pill_button.dart';

/// Four cards: what the app is for, how progress works, where the data lives,
/// and the only thing it needs to know — what to call you.
class OnboardingView extends StatefulWidget {
  const OnboardingView({
    required this.step,
    required this.isAnimated,
    required this.onNext,
    required this.onFinish,
    this.initialDisplayName = '',
    super.key,
  });

  final int step;
  final bool isAnimated;
  final VoidCallback onNext;
  final void Function(String displayName) onFinish;

  /// What the name field starts with, so replaying the cards or skipping
  /// them never erases a name already given.
  final String initialDisplayName;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.initialDisplayName,
  );

  static const List<({String title, String body, String cta})> _cards =
      <({String title, String body, String cta})>[
        (
          title: 'Des petites choses, tenues.',
          body: 'Momentum transforme une liste quotidienne en un rythme que tu '
              'vois.',
          cta: 'Continuer',
        ),
        (
          title: 'Une progression lisible.',
          body: 'Chaque tâche paie en XP. Les séries montent doucement, les '
              'niveaux arrivent quand ils sont mérités.',
          cta: 'Continuer',
        ),
        (
          title: 'Tout reste sur ce téléphone.',
          body: 'Aucun compte, aucun serveur. Tes listes, ta série et tes '
              'stats ne quittent pas l’appareil.',
          cta: 'Continuer',
        ),
        (
          title: 'On t’appelle comment ?',
          body: 'Juste pour le bonjour du matin. Tu pourras le changer depuis '
              'le profil.',
          cta: 'Commencer ma journée',
        ),
      ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _advance() {
    if (widget.step == _cards.length - 1) {
      widget.onFinish(_nameController.text);
      return;
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final ({String title, String body, String cta}) card = _cards[widget.step];
    final bool isLastStep = widget.step == _cards.length - 1;

    // The name field lifts the keyboard over half the screen. The ring is
    // decorative, so it gives up its space rather than pushing the call to
    // action out of reach.
    final double keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final bool isKeyboardOpen = keyboardInset > 0;

    return ColoredBox(
      color: CadenceColors.background,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, 30, 22, 26 + keyboardInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  for (int index = 0; index < _cards.length; index++) ...<Widget>[
                    if (index > 0) const SizedBox(width: 4),
                    Expanded(
                      child: AnimatedContainer(
                        duration: widget.isAnimated
                            ? CadenceMotion.base
                            : CadenceMotion.instant,
                        height: 2,
                        decoration: BoxDecoration(
                          color: index <= widget.step
                              ? CadenceColors.white
                              : CadenceColors.textAt(0.16),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: isKeyboardOpen ? 28 : 36),
                      if (!isKeyboardOpen) ...<Widget>[
                        Center(
                          child: _StepRing(
                            step: widget.step + 1,
                            totalSteps: _cards.length,
                            isAnimated: widget.isAnimated,
                          ),
                        ),
                        const SizedBox(height: 44),
                      ],
                      Text(
                        card.title,
                        style: CadenceTextStyles.display(
                          size: 36,
                          height: 1.03,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.body,
                        style: CadenceTextStyles.body(
                          color: CadenceColors.textAt(0.55),
                        ),
                      ),
                      if (isLastStep) ...<Widget>[
                        const SizedBox(height: 22),
                        TextField(
                          controller: _nameController,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _advance(),
                          cursorColor: CadenceColors.white,
                          style: CadenceTextStyles.display(size: 28, height: 1.2),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Ton prénom',
                            hintStyle: CadenceTextStyles.display(
                              size: 28,
                              height: 1.2,
                              color: CadenceColors.textAt(0.25),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: CadenceColors.textAt(0.2),
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: CadenceColors.white),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  if (!isLastStep)
                    PillButton(
                      label: 'Passer',
                      variant: PillButtonVariant.ghost,
                      fontSize: 13,
                      horizontalPadding: 10,
                      isAnimated: widget.isAnimated,
                      onPressed: () => widget.onFinish(widget.initialDisplayName),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PillButton(
                      label: card.cta,
                      trailingIcon: CadenceIcons.arrowRight,
                      minHeight: 56,
                      isExpanded: true,
                      isAnimated: widget.isAnimated,
                      onPressed: _advance,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ring that fills one quarter per card. The first card carries the logo,
/// the others the step number.
class _StepRing extends StatelessWidget {
  const _StepRing({
    required this.step,
    required this.totalSteps,
    required this.isAnimated,
  });

  final int step;
  final int totalSteps;
  final bool isAnimated;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 208,
      height: 208,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: step / totalSteps),
            duration: isAnimated
                ? const Duration(milliseconds: 340)
                : CadenceMotion.instant,
            curve: CadenceMotion.ease,
            builder: (BuildContext context, double value, Widget? child) {
              return CustomPaint(
                size: const Size.square(208),
                painter: _RingPainter(fraction: value),
              );
            },
          ),
          if (step == 1)
            const MomentumLogo(size: 84)
          else
            Text(
            step.toString().padLeft(2, '0'),
            style: CadenceTextStyles.figure(
              size: 44,
              weight: FontWeight.w500,
              letterSpacing: -0.04,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction});

  final double fraction;

  static const double _strokeWidth = 20;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Rect arcRect = rect.deflate(_strokeWidth / 2);

    final Paint track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = CadenceColors.textAt(0.12);
    final Paint progress = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = CadenceColors.white;

    canvas.drawArc(arcRect, 0, math.pi * 2, false, track);
    canvas.drawArc(
      arcRect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      progress,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}

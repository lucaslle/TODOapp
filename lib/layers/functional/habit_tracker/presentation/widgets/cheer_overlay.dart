import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../technical/theme/cadence_colors.dart';
import '../../../../technical/theme/cadence_icons.dart';
import '../../../../technical/theme/cadence_motion.dart';
import '../../../../technical/theme/cadence_text_styles.dart';
import '../cubit/habit_state.dart';

/// The 0.8 s celebration when a task closes: a white disc, ten sparks, the XP
/// it paid and what it was for.
class CheerOverlay extends StatefulWidget {
  const CheerOverlay({required this.cheer, super.key});

  final CheerSignal cheer;

  @override
  State<CheerOverlay> createState() => _CheerOverlayState();
}

class _CheerOverlayState extends State<CheerOverlay>
    with SingleTickerProviderStateMixin {
  static const List<Offset> _sparkOffsets = <Offset>[
    Offset(-54, -30),
    Offset(48, -38),
    Offset(-30, 50),
    Offset(38, 46),
    Offset(-64, 8),
    Offset(60, 6),
    Offset(8, -62),
    Offset(-10, 60),
    Offset(-44, -54),
    Offset(50, -12),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: CadenceColors.scrimStrong,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            final double pop = Curves.easeOutBack.transform(
              math.min(1, _controller.value * 3),
            );
            return Transform.scale(scale: 0.7 + 0.3 * pop, child: child);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                width: 240,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    for (int index = 0; index < _sparkOffsets.length; index++)
                      _Spark(
                        controller: _controller,
                        offset: _sparkOffsets[index],
                        delay: index * 0.028,
                        color: index.isEven
                            ? CadenceColors.white
                            : CadenceColors.textAt(0.5),
                      ),
                    Container(
                      width: 104,
                      height: 104,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: CadenceColors.white,
                      ),
                      child: Icon(
                        CadenceIcons.checkFilled,
                        size: 44,
                        color: CadenceColors.onWhite,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+${widget.cheer.xpGained}',
                style: CadenceTextStyles.figure(size: 30, letterSpacing: -0.05),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  widget.cheer.line.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: CadenceTextStyles.label(
                    letterSpacing: 0.16,
                    weight: FontWeight.w400,
                    color: CadenceColors.textAt(0.5),
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

class _Spark extends StatelessWidget {
  const _Spark({
    required this.controller,
    required this.offset,
    required this.delay,
    required this.color,
  });

  final AnimationController controller;
  final Offset offset;
  final double delay;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        final double progress = ((controller.value - delay) / (1 - delay)).clamp(
          0.0,
          1.0,
        );
        final double eased = CadenceMotion.ease.transform(progress);
        return Transform.translate(
          offset: offset * eased,
          child: Opacity(
            opacity: (1 - progress).clamp(0.0, 1.0),
            child: Transform.rotate(
              angle: math.atan2(offset.dy, offset.dx) + math.pi / 2,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 4,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

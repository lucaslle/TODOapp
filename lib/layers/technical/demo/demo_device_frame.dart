import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/cadence_colors.dart';
import '../theme/cadence_text_styles.dart';
import 'demo_build.dart';

/// Inside the iPhone frame of the web demo, draws the status bar, the Dynamic
/// Island and the home indicator, and reserves their space the way a real
/// phone would, through [MediaQuery] padding.
///
/// Outside the frame — a real phone, a narrow browser — it is invisible.
class DemoDeviceFrame extends StatelessWidget {
  const DemoDeviceFrame({required this.child, super.key});

  static const double statusBarHeight = 54;
  static const double homeIndicatorHeight = 30;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!DemoBuild.isFramed) return child;

    final MediaQueryData media = MediaQuery.of(context);
    const EdgeInsets insets = EdgeInsets.only(
      top: statusBarHeight,
      bottom: homeIndicatorHeight,
    );

    return Stack(
      children: <Widget>[
        MediaQuery(
          data: media.copyWith(padding: insets, viewPadding: insets),
          child: child,
        ),
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: statusBarHeight,
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: Material(
                type: MaterialType.transparency,
                child: _StatusBar(),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Center(
              child: Container(
                width: 134,
                height: 5,
                decoration: BoxDecoration(
                  color: CadenceColors.text,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The clock, the island and the three indicators. Refreshes itself so the
/// clock stays right during a long demo.
class _StatusBar extends StatefulWidget {
  const _StatusBar();

  @override
  State<_StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<_StatusBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _clock(DateTime now) {
    final String hour = now.hour.toString().padLeft(2, '0');
    final String minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: 11,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 126,
              height: 37,
              decoration: BoxDecoration(
                color: const Color(0xFF000000),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(44, 4, 30, 0),
            child: Row(
              children: <Widget>[
                Text(
                  _clock(DateTime.now()),
                  style: CadenceTextStyles.body(
                    size: 16,
                    height: 1,
                    weight: FontWeight.w600,
                    letterSpacing: -0.01,
                  ),
                ),
                const Spacer(),
                const _CellularBars(),
                const SizedBox(width: 6),
                const _WifiArcs(),
                const SizedBox(width: 6),
                const _Battery(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CellularBars extends StatelessWidget {
  const _CellularBars();

  static const List<double> _heights = <double>[4, 6, 8.5, 11];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final double height in _heights) ...<Widget>[
          Container(
            width: 3,
            height: height,
            decoration: BoxDecoration(
              color: CadenceColors.text,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 1.5),
        ],
      ],
    );
  }
}

class _WifiArcs extends StatelessWidget {
  const _WifiArcs();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(17, 12),
      painter: _WifiPainter(color: CadenceColors.text),
    );
  }
}

class _WifiPainter extends CustomPainter {
  const _WifiPainter({required this.color});

  final Color color;

  static const List<double> _radii = <double>[4, 7.5, 11];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = color;
    final Offset center = Offset(size.width / 2, size.height);
    for (final double radius in _radii) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -2.35,
        1.57,
        false,
        stroke,
      );
    }
    canvas.drawCircle(center.translate(0, -1), 1.2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WifiPainter oldDelegate) => oldDelegate.color != color;
}

class _Battery extends StatelessWidget {
  const _Battery();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 25,
          height: 12,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            border: Border.all(color: CadenceColors.textAt(0.4)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.8,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: CadenceColors.text,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 1),
        Container(
          width: 2,
          height: 4,
          decoration: BoxDecoration(
            color: CadenceColors.textAt(0.4),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

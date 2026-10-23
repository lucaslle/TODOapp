import 'package:flutter/widgets.dart';

/// The Momentum mark — the two strokes of the M — in white, for dark surfaces.
class MomentumLogo extends StatelessWidget {
  const MomentumLogo({required this.size, super.key});

  static const String _asset = 'assets/logo/momentum-mark-white.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Image.asset(
        _asset,
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

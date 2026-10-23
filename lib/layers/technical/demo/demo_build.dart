import 'package:flutter/foundation.dart';

/// What a build knows about being the online demo.
///
/// `flutter build web --dart-define=MOMENTUM_DEMO=true` produces the demo
/// published on GitHub Pages: it starts with sample data instead of an empty
/// board. The `?frame=iphone` query is added by the page when the browser is
/// wide enough to show the app inside a phone frame.
abstract final class DemoBuild {
  static const bool isDemo = bool.fromEnvironment('MOMENTUM_DEMO');

  static bool get isFramed =>
      kIsWeb && Uri.base.queryParameters['frame'] == 'iphone';
}

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// An image the app stored itself: a file path on the phone, a data URL in the
/// browser (see `ProfilePhotoService`). The caller does not need to know
/// which.
Image storedImage(
  String path, {
  double? width,
  double? height,
  BoxFit? fit,
  ImageErrorWidgetBuilder? errorBuilder,
}) {
  if (kIsWeb) {
    return Image.network(
      path,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: errorBuilder,
    );
  }
  return Image.file(
    File(path),
    width: width,
    height: height,
    fit: fit,
    errorBuilder: errorBuilder,
  );
}

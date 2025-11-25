import 'dart:io';

import 'package:flutter/widgets.dart' show WidgetsBinding;
import 'package:jni/jni.dart';
import 'package:screen_corners_ffi/screen_corners_ffi_platform_interface.dart';

import 'jni_bindings.dart' as jb;

class ScreenCornersAndroid extends ScreenCornersPlatform {
  ScreenCornersAndroid();

  @override
  ScreenCornersDataPartial? screenCorners() => _screenCorners();

  static void registerWith() {
    ScreenCornersPlatform.instance = ScreenCornersAndroid();
  }

  static JObject? _androidActivity() {
    if (!Platform.isAndroid) return null;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final engineId = platformDispatcher.engineId;
    return engineId != null ? Jni.androidActivity(engineId) : null;
  }

  static ScreenCornersDataPartial _screenCornersFromNative(
    jb.ScreenCorners object,
  ) => ScreenCornersDataPartial.from(
    topLeft: object.getTopLeft()?.doubleValue(releaseOriginal: true),
    topRight: object.getTopRight()?.doubleValue(releaseOriginal: true),
    bottomLeft: object.getBottomLeft()?.doubleValue(releaseOriginal: true),
    bottomRight: object.getBottomRight()?.doubleValue(releaseOriginal: true),
  );

  static ScreenCornersDataPartial? _screenCorners() => Platform.isAndroid
      ? _androidActivity()
            ?.use(jb.ScreenCorners.fromActivity)
            .use(_screenCornersFromNative)
      : null;
}

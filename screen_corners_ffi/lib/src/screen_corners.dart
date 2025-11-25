import 'package:flutter/widgets.dart'
    show BorderRadius, BuildContext, MediaQuery;
import 'package:screen_corners_ffi/screen_corners_ffi_platform_interface.dart';

abstract final class ScreenCorners {
  static ScreenCornersData? maybeOf(BuildContext context) {
    // Important: listen to devicePixelRatio updates
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);
    return devicePixelRatio != null
        ? ScreenCornersPlatform.instance.screenCorners()?.applyDevicePixelRatio(
            devicePixelRatio: devicePixelRatio,
          )
        : null;
  }

  static ScreenCornersData of(BuildContext context) =>
      maybeOf(context) ?? const .from();

  static BorderRadius? maybeBorderRadiusOf(BuildContext context) =>
      maybeOf(context)?.toBorderRadius();

  static BorderRadius borderRadiusOf(BuildContext context) =>
      of(context).toBorderRadius();
}

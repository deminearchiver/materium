import 'package:screen_corners_ffi/screen_corners_ffi_platform_interface.dart';

class ScreenCornersDefault extends ScreenCornersPlatform {
  ScreenCornersDefault();

  @override
  ScreenCornersDataPartial? screenCorners() => null;

  static void registerWith() {
    ScreenCornersPlatform.instance = ScreenCornersDefault();
  }
}

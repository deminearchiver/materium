import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:screen_corners_ffi/screen_corners_ffi.dart';

abstract class ScreenCornersPlatform extends PlatformInterface {
  ScreenCornersPlatform() : super(token: _token);

  ScreenCornersDataPartial? screenCorners() {
    throw UnimplementedError("screenCorners() has not been implemented.");
  }

  static final Object _token = Object();

  static ScreenCornersPlatform _instance = ScreenCornersDefault();

  static ScreenCornersPlatform get instance => _instance;

  static set instance(ScreenCornersPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }
}

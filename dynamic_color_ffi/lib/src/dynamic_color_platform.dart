import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';

abstract class DynamicColorPlatform extends PlatformInterface {
  DynamicColorPlatform() : super(token: _token);

  bool isDynamicColorAvailable() {
    throw UnimplementedError(
      "isDynamicColorAvailable() has not been implemented.",
    );
  }

  DynamicColorScheme? dynamicLightColorScheme() {
    throw UnimplementedError(
      "dynamicLightColorScheme() has not been implemented.",
    );
  }

  DynamicColorScheme? dynamicDarkColorScheme() {
    throw UnimplementedError(
      "dynamicDarkColorScheme() has not been implemented.",
    );
  }

  static final Object _token = Object();

  static DynamicColorPlatform _instance = DynamicColorDefault();

  static DynamicColorPlatform get instance => _instance;

  static set instance(DynamicColorPlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }
}

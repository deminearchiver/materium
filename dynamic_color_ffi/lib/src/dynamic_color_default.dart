import 'package:dynamic_color_ffi/dynamic_color_ffi_platform_interface.dart';

class DynamicColorDefault extends DynamicColorPlatform {
  DynamicColorDefault();

  @override
  bool isDynamicColorAvailable() => false;

  @override
  DynamicColorScheme? dynamicLightColorScheme() => null;

  @override
  DynamicColorScheme? dynamicDarkColorScheme() => null;

  static void registerWith() {
    DynamicColorPlatform.instance = DynamicColorDefault();
  }
}

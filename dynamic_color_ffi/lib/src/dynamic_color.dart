import 'dart:ui';

import 'package:dynamic_color_ffi/dynamic_color_ffi_platform_interface.dart';

abstract final class DynamicColor {
  static bool isDynamicColorAvailable() =>
      DynamicColorPlatform.instance.isDynamicColorAvailable();

  static DynamicColorScheme? dynamicLightColorScheme() =>
      DynamicColorPlatform.instance.dynamicLightColorScheme();

  static DynamicColorScheme? dynamicDarkColorScheme() =>
      DynamicColorPlatform.instance.dynamicDarkColorScheme();

  static DynamicColorScheme? dynamicColorScheme(Brightness brightness) =>
      switch (brightness) {
        .light => dynamicLightColorScheme(),
        .dark => dynamicDarkColorScheme(),
      };
}

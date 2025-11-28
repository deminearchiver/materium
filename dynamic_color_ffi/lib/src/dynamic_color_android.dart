import 'dart:io';

import 'package:flutter/material.dart' show Brightness, Color;
import 'package:jni/jni.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi_platform_interface.dart';

import 'jni_bindings.dart' as jb;

class DynamicColorAndroid extends DynamicColorPlatform {
  DynamicColorAndroid();

  @override
  bool isDynamicColorAvailable() {
    if (!Platform.isAndroid) return false;
    return jb.DynamicColorPlugin.isDynamicColorAvailable();
  }

  @override
  DynamicColorScheme? dynamicLightColorScheme() => Platform.isAndroid
      ? Jni.androidApplicationContext
            .use(jb.DynamicColorPlugin.dynamicLightColorScheme)
            .use(_dynamicLightColorSchemeFromNative)
      : null;

  @override
  DynamicColorScheme? dynamicDarkColorScheme() => Platform.isAndroid
      ? Jni.androidApplicationContext
            .use(jb.DynamicColorPlugin.dynamicDarkColorScheme)
            .use(_dynamicDarkColorSchemeFromNative)
      : null;

  static void registerWith() {
    DynamicColorPlatform.instance = DynamicColorAndroid();
  }

  static DynamicColorScheme _dynamicLightColorSchemeFromNative(
    jb.DynamicColorScheme object,
  ) => _dynamicColorSchemeFromNative(object, brightness: .light);

  static DynamicColorScheme _dynamicDarkColorSchemeFromNative(
    jb.DynamicColorScheme object,
  ) => _dynamicColorSchemeFromNative(object, brightness: .dark);

  static DynamicColorScheme _dynamicColorSchemeFromNative(
    jb.DynamicColorScheme object, {
    required Brightness brightness,
  }) => DynamicColorScheme.from(
    brightness: brightness,
    primaryPaletteKeyColor: object.getPrimaryPaletteKeyColor()?._colorValue(
      releaseOriginal: true,
    ),
    secondaryPaletteKeyColor: object.getSecondaryPaletteKeyColor()?._colorValue(
      releaseOriginal: true,
    ),
    tertiaryPaletteKeyColor: object.getTertiaryPaletteKeyColor()?._colorValue(
      releaseOriginal: true,
    ),
    neutralPaletteKeyColor: object.getNeutralPaletteKeyColor()?._colorValue(
      releaseOriginal: true,
    ),
    neutralVariantPaletteKeyColor: object
        .getNeutralVariantPaletteKeyColor()
        ?._colorValue(releaseOriginal: true),
    errorPaletteKeyColor: object.getErrorPaletteKeyColor()?._colorValue(
      releaseOriginal: true,
    ),
    background: object.getBackground()?._colorValue(releaseOriginal: true),
    onBackground: object.getOnBackground()?._colorValue(releaseOriginal: true),
    surface: object.getSurface()?._colorValue(releaseOriginal: true),
    surfaceDim: object.getSurfaceDim()?._colorValue(releaseOriginal: true),
    surfaceBright: object.getSurfaceBright()?._colorValue(
      releaseOriginal: true,
    ),
    surfaceContainerLowest: object.getSurfaceContainerLowest()?._colorValue(
      releaseOriginal: true,
    ),
    surfaceContainerLow: object.getSurfaceContainerLow()?._colorValue(
      releaseOriginal: true,
    ),
    surfaceContainer: object.getSurfaceContainer()?._colorValue(
      releaseOriginal: true,
    ),
    surfaceContainerHigh: object.getSurfaceContainerHigh()?._colorValue(
      releaseOriginal: true,
    ),
    surfaceContainerHighest: object.getSurfaceContainerHighest()?._colorValue(
      releaseOriginal: true,
    ),
    onSurface: object.getOnSurface()?._colorValue(releaseOriginal: true),
    surfaceVariant: object.getSurfaceVariant()?._colorValue(
      releaseOriginal: true,
    ),
    onSurfaceVariant: object.getOnSurfaceVariant()?._colorValue(
      releaseOriginal: true,
    ),
    outline: object.getOutline()?._colorValue(releaseOriginal: true),
    outlineVariant: object.getOutlineVariant()?._colorValue(
      releaseOriginal: true,
    ),
    inverseSurface: object.getInverseSurface()?._colorValue(
      releaseOriginal: true,
    ),
    inverseOnSurface: object.getInverseOnSurface()?._colorValue(
      releaseOriginal: true,
    ),
    shadow: object.getShadow()?._colorValue(releaseOriginal: true),
    scrim: object.getScrim()?._colorValue(releaseOriginal: true),
    surfaceTint: object.getSurfaceTint()?._colorValue(releaseOriginal: true),
    primary: object.getPrimary()?._colorValue(releaseOriginal: true),
    primaryDim: object.getPrimaryDim()?._colorValue(releaseOriginal: true),
    onPrimary: object.getOnPrimary()?._colorValue(releaseOriginal: true),
    primaryContainer: object.getPrimaryContainer()?._colorValue(
      releaseOriginal: true,
    ),
    onPrimaryContainer: object.getOnPrimaryContainer()?._colorValue(
      releaseOriginal: true,
    ),
    primaryFixed: object.getPrimaryFixed()?._colorValue(releaseOriginal: true),
    primaryFixedDim: object.getPrimaryFixedDim()?._colorValue(
      releaseOriginal: true,
    ),
    onPrimaryFixed: object.getOnPrimaryFixed()?._colorValue(
      releaseOriginal: true,
    ),
    onPrimaryFixedVariant: object.getOnPrimaryFixedVariant()?._colorValue(
      releaseOriginal: true,
    ),
    inversePrimary: object.getInversePrimary()?._colorValue(
      releaseOriginal: true,
    ),
    secondary: object.getSecondary()?._colorValue(releaseOriginal: true),
    secondaryDim: object.getSecondaryDim()?._colorValue(releaseOriginal: true),
    onSecondary: object.getOnSecondary()?._colorValue(releaseOriginal: true),
    secondaryContainer: object.getSecondaryContainer()?._colorValue(
      releaseOriginal: true,
    ),
    onSecondaryContainer: object.getOnSecondaryContainer()?._colorValue(
      releaseOriginal: true,
    ),
    secondaryFixed: object.getSecondaryFixed()?._colorValue(
      releaseOriginal: true,
    ),
    secondaryFixedDim: object.getSecondaryFixedDim()?._colorValue(
      releaseOriginal: true,
    ),
    onSecondaryFixed: object.getOnSecondaryFixed()?._colorValue(
      releaseOriginal: true,
    ),
    onSecondaryFixedVariant: object.getOnSecondaryFixedVariant()?._colorValue(
      releaseOriginal: true,
    ),
    tertiary: object.getTertiary()?._colorValue(releaseOriginal: true),
    tertiaryDim: object.getTertiaryDim()?._colorValue(releaseOriginal: true),
    onTertiary: object.getOnTertiary()?._colorValue(releaseOriginal: true),
    tertiaryContainer: object.getTertiaryContainer()?._colorValue(
      releaseOriginal: true,
    ),
    onTertiaryContainer: object.getOnTertiaryContainer()?._colorValue(
      releaseOriginal: true,
    ),
    tertiaryFixed: object.getTertiaryFixed()?._colorValue(
      releaseOriginal: true,
    ),
    tertiaryFixedDim: object.getTertiaryFixedDim()?._colorValue(
      releaseOriginal: true,
    ),
    onTertiaryFixed: object.getOnTertiaryFixed()?._colorValue(
      releaseOriginal: true,
    ),
    onTertiaryFixedVariant: object.getOnTertiaryFixedVariant()?._colorValue(
      releaseOriginal: true,
    ),
    error: object.getError()?._colorValue(releaseOriginal: true),
    errorDim: object.getErrorDim()?._colorValue(releaseOriginal: true),
    onError: object.getOnError()?._colorValue(releaseOriginal: true),
    errorContainer: object.getErrorContainer()?._colorValue(
      releaseOriginal: true,
    ),
    onErrorContainer: object.getOnErrorContainer()?._colorValue(
      releaseOriginal: true,
    ),
  );
}

extension on JInteger {
  @pragma("vm:prefer-inline")
  Color _colorValue({bool releaseOriginal = false}) =>
      Color(intValue(releaseOriginal: releaseOriginal));
}

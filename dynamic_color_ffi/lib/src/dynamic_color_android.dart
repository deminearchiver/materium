import 'dart:io';

import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:dynamic_color_ffi/dynamic_color_ffi_platform_interface.dart';
import 'package:flutter/material.dart' show Brightness, Color;
import 'package:jni/jni.dart';

import 'jni_bindings.dart' as jb;

class DynamicColorAndroid extends DynamicColorPlatform {
  DynamicColorAndroid();

  @override
  bool isDynamicColorAvailable() {
    if (!Platform.isAndroid) return false;
    return jb.DynamicColorPlugin.isDynamicColorAvailable();
  }

  @override
  DynamicColorScheme? dynamicLightColorScheme() {
    if (!Platform.isAndroid) return null;

    final context = Jni.androidApplicationContext;
    final object = jb.DynamicColorPlugin.dynamicLightColorScheme(context);
    final result = _dynamicColorSchemeFromNative(object, brightness: .light);
    object.release();
    context.release();
    return result;
  }

  @override
  DynamicColorScheme? dynamicDarkColorScheme() {
    if (!Platform.isAndroid) return null;

    final context = Jni.androidApplicationContext;
    final object = jb.DynamicColorPlugin.dynamicDarkColorScheme(context);
    final result = _dynamicColorSchemeFromNative(object, brightness: .dark);
    object.release();
    context.release();
    return result;
  }

  static DynamicColorScheme _dynamicColorSchemeFromNative(
    jb.DynamicColorScheme object, {
    required Brightness brightness,
  }) => DynamicColorScheme(
    brightness: brightness,
    primaryPaletteKeyColor: object
        .getPrimaryPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    secondaryPaletteKeyColor: object
        .getSecondaryPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    tertiaryPaletteKeyColor: object
        .getTertiaryPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    neutralPaletteKeyColor: object
        .getNeutralPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    neutralVariantPaletteKeyColor: object
        .getNeutralVariantPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    errorPaletteKeyColor: object
        .getErrorPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    background: object
        .getBackground()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onBackground: object
        .getOnBackground()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    surface: object.getSurface()?.intValue(releaseOriginal: true)._asColor,
    surfaceDim: object
        .getSurfaceDim()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    surfaceBright: object
        .getSurfaceBright()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    surfaceContainerLowest: object
        .getSurfaceContainerLowest()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    surfaceContainerLow: object
        .getSurfaceContainerLow()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    surfaceContainer: object
        .getSurfaceContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    surfaceContainerHigh: object
        .getSurfaceContainerHigh()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    surfaceContainerHighest: object
        .getSurfaceContainerHighest()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onSurface: object.getOnSurface()?.intValue(releaseOriginal: true)._asColor,
    surfaceVariant: object
        .getSurfaceVariant()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onSurfaceVariant: object
        .getOnSurfaceVariant()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    outline: object.getOutline()?.intValue(releaseOriginal: true)._asColor,
    outlineVariant: object
        .getOutlineVariant()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    inverseSurface: object
        .getInverseSurface()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    inverseOnSurface: object
        .getInverseOnSurface()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    shadow: object.getShadow()?.intValue(releaseOriginal: true)._asColor,
    scrim: object.getScrim()?.intValue(releaseOriginal: true)._asColor,
    surfaceTint: object
        .getSurfaceTint()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    primary: object.getPrimary()?.intValue(releaseOriginal: true)._asColor,
    primaryDim: object
        .getPrimaryDim()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onPrimary: object.getOnPrimary()?.intValue(releaseOriginal: true)._asColor,
    primaryContainer: object
        .getPrimaryContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onPrimaryContainer: object
        .getOnPrimaryContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    primaryFixed: object
        .getPrimaryFixed()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    primaryFixedDim: object
        .getPrimaryFixedDim()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onPrimaryFixed: object
        .getOnPrimaryFixed()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onPrimaryFixedVariant: object
        .getOnPrimaryFixedVariant()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    inversePrimary: object
        .getInversePrimary()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    secondary: object.getSecondary()?.intValue(releaseOriginal: true)._asColor,
    secondaryDim: object
        .getSecondaryDim()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onSecondary: object
        .getOnSecondary()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    secondaryContainer: object
        .getSecondaryContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onSecondaryContainer: object
        .getOnSecondaryContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    secondaryFixed: object
        .getSecondaryFixed()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    secondaryFixedDim: object
        .getSecondaryFixedDim()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onSecondaryFixed: object
        .getOnSecondaryFixed()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onSecondaryFixedVariant: object
        .getOnSecondaryFixedVariant()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    tertiary: object.getTertiary()?.intValue(releaseOriginal: true)._asColor,
    tertiaryDim: object
        .getTertiaryDim()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onTertiary: object
        .getOnTertiary()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    tertiaryContainer: object
        .getTertiaryContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onTertiaryContainer: object
        .getOnTertiaryContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    tertiaryFixed: object
        .getTertiaryFixed()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    tertiaryFixedDim: object
        .getTertiaryFixedDim()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onTertiaryFixed: object
        .getOnTertiaryFixed()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onTertiaryFixedVariant: object
        .getOnTertiaryFixedVariant()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    error: object.getError()?.intValue(releaseOriginal: true)._asColor,
    errorDim: object.getErrorDim()?.intValue(releaseOriginal: true)._asColor,
    onError: object.getOnError()?.intValue(releaseOriginal: true)._asColor,
    errorContainer: object
        .getErrorContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
    onErrorContainer: object
        .getOnErrorContainer()
        ?.intValue(releaseOriginal: true)
        ._asColor,
  );

  static void registerWith() {
    DynamicColorPlatform.instance = DynamicColorAndroid();
  }
}

extension on int {
  Color get _asColor => Color(this);
}

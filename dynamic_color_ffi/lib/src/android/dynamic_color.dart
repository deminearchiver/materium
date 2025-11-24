import 'dart:io';

import 'package:flutter/material.dart' show Brightness, Color;
import 'package:jni/jni.dart';

import 'jni_bindings.dart' as jb;

extension on int {
  Color _toColor() => Color(this);
}

class DynamicColorScheme {
  const DynamicColorScheme({
    required this.brightness,
    this.primaryPaletteKeyColor,
    this.secondaryPaletteKeyColor,
    this.tertiaryPaletteKeyColor,
    this.neutralPaletteKeyColor,
    this.neutralVariantPaletteKeyColor,
    this.errorPaletteKeyColor,
    this.background,
    this.onBackground,
    this.surface,
    this.surfaceDim,
    this.surfaceBright,
    this.surfaceContainerLowest,
    this.surfaceContainerLow,
    this.surfaceContainer,
    this.surfaceContainerHigh,
    this.surfaceContainerHighest,
    this.onSurface,
    this.surfaceVariant,
    this.onSurfaceVariant,
    this.outline,
    this.outlineVariant,
    this.inverseSurface,
    this.inverseOnSurface,
    this.shadow,
    this.scrim,
    this.surfaceTint,
    this.primary,
    this.primaryDim,
    this.onPrimary,
    this.primaryContainer,
    this.onPrimaryContainer,
    this.primaryFixed,
    this.primaryFixedDim,
    this.onPrimaryFixed,
    this.onPrimaryFixedVariant,
    this.inversePrimary,
    this.secondary,
    this.secondaryDim,
    this.onSecondary,
    this.secondaryContainer,
    this.onSecondaryContainer,
    this.secondaryFixed,
    this.secondaryFixedDim,
    this.onSecondaryFixed,
    this.onSecondaryFixedVariant,
    this.tertiary,
    this.tertiaryDim,
    this.onTertiary,
    this.tertiaryContainer,
    this.onTertiaryContainer,
    this.tertiaryFixed,
    this.tertiaryFixedDim,
    this.onTertiaryFixed,
    this.onTertiaryFixedVariant,
    this.error,
    this.errorDim,
    this.onError,
    this.errorContainer,
    this.onErrorContainer,
  });

  factory DynamicColorScheme._fromNative(
    jb.DynamicColorScheme object, {
    required Brightness brightness,
  }) => DynamicColorScheme(
    brightness: brightness,
    primaryPaletteKeyColor: object
        .getPrimaryPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    secondaryPaletteKeyColor: object
        .getSecondaryPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    tertiaryPaletteKeyColor: object
        .getTertiaryPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    neutralPaletteKeyColor: object
        .getNeutralPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    neutralVariantPaletteKeyColor: object
        .getNeutralVariantPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    errorPaletteKeyColor: object
        .getErrorPaletteKeyColor()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    background: object
        .getBackground()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onBackground: object
        .getOnBackground()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surface: object.getSurface()?.intValue(releaseOriginal: true)._toColor(),
    surfaceDim: object
        .getSurfaceDim()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surfaceBright: object
        .getSurfaceBright()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surfaceContainerLowest: object
        .getSurfaceContainerLowest()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surfaceContainerLow: object
        .getSurfaceContainerLow()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surfaceContainer: object
        .getSurfaceContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surfaceContainerHigh: object
        .getSurfaceContainerHigh()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surfaceContainerHighest: object
        .getSurfaceContainerHighest()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onSurface: object
        .getOnSurface()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    surfaceVariant: object
        .getSurfaceVariant()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onSurfaceVariant: object
        .getOnSurfaceVariant()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    outline: object.getOutline()?.intValue(releaseOriginal: true)._toColor(),
    outlineVariant: object
        .getOutlineVariant()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    inverseSurface: object
        .getInverseSurface()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    inverseOnSurface: object
        .getInverseOnSurface()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    shadow: object.getShadow()?.intValue(releaseOriginal: true)._toColor(),
    scrim: object.getScrim()?.intValue(releaseOriginal: true)._toColor(),
    surfaceTint: object
        .getSurfaceTint()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    primary: object.getPrimary()?.intValue(releaseOriginal: true)._toColor(),
    primaryDim: object
        .getPrimaryDim()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onPrimary: object
        .getOnPrimary()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    primaryContainer: object
        .getPrimaryContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onPrimaryContainer: object
        .getOnPrimaryContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    primaryFixed: object
        .getPrimaryFixed()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    primaryFixedDim: object
        .getPrimaryFixedDim()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onPrimaryFixed: object
        .getOnPrimaryFixed()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onPrimaryFixedVariant: object
        .getOnPrimaryFixedVariant()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    inversePrimary: object
        .getInversePrimary()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    secondary: object
        .getSecondary()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    secondaryDim: object
        .getSecondaryDim()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onSecondary: object
        .getOnSecondary()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    secondaryContainer: object
        .getSecondaryContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onSecondaryContainer: object
        .getOnSecondaryContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    secondaryFixed: object
        .getSecondaryFixed()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    secondaryFixedDim: object
        .getSecondaryFixedDim()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onSecondaryFixed: object
        .getOnSecondaryFixed()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onSecondaryFixedVariant: object
        .getOnSecondaryFixedVariant()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    tertiary: object.getTertiary()?.intValue(releaseOriginal: true)._toColor(),
    tertiaryDim: object
        .getTertiaryDim()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onTertiary: object
        .getOnTertiary()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    tertiaryContainer: object
        .getTertiaryContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onTertiaryContainer: object
        .getOnTertiaryContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    tertiaryFixed: object
        .getTertiaryFixed()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    tertiaryFixedDim: object
        .getTertiaryFixedDim()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onTertiaryFixed: object
        .getOnTertiaryFixed()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onTertiaryFixedVariant: object
        .getOnTertiaryFixedVariant()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    error: object.getError()?.intValue(releaseOriginal: true)._toColor(),
    errorDim: object.getErrorDim()?.intValue(releaseOriginal: true)._toColor(),
    onError: object.getOnError()?.intValue(releaseOriginal: true)._toColor(),
    errorContainer: object
        .getErrorContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
    onErrorContainer: object
        .getOnErrorContainer()
        ?.intValue(releaseOriginal: true)
        ._toColor(),
  );

  final Brightness brightness;
  final Color? primaryPaletteKeyColor;
  final Color? secondaryPaletteKeyColor;
  final Color? tertiaryPaletteKeyColor;
  final Color? neutralPaletteKeyColor;
  final Color? neutralVariantPaletteKeyColor;
  final Color? errorPaletteKeyColor;
  final Color? background;
  final Color? onBackground;
  final Color? surface;
  final Color? surfaceDim;
  final Color? surfaceBright;
  final Color? surfaceContainerLowest;
  final Color? surfaceContainerLow;
  final Color? surfaceContainer;
  final Color? surfaceContainerHigh;
  final Color? surfaceContainerHighest;
  final Color? onSurface;
  final Color? surfaceVariant;
  final Color? onSurfaceVariant;
  final Color? outline;
  final Color? outlineVariant;
  final Color? inverseSurface;
  final Color? inverseOnSurface;
  final Color? shadow;
  final Color? scrim;
  final Color? surfaceTint;
  final Color? primary;
  final Color? primaryDim;
  final Color? onPrimary;
  final Color? primaryContainer;
  final Color? onPrimaryContainer;
  final Color? primaryFixed;
  final Color? primaryFixedDim;
  final Color? onPrimaryFixed;
  final Color? onPrimaryFixedVariant;
  final Color? inversePrimary;
  final Color? secondary;
  final Color? secondaryDim;
  final Color? onSecondary;
  final Color? secondaryContainer;
  final Color? onSecondaryContainer;
  final Color? secondaryFixed;
  final Color? secondaryFixedDim;
  final Color? onSecondaryFixed;
  final Color? onSecondaryFixedVariant;
  final Color? tertiary;
  final Color? tertiaryDim;
  final Color? onTertiary;
  final Color? tertiaryContainer;
  final Color? onTertiaryContainer;
  final Color? tertiaryFixed;
  final Color? tertiaryFixedDim;
  final Color? onTertiaryFixed;
  final Color? onTertiaryFixedVariant;
  final Color? error;
  final Color? errorDim;
  final Color? onError;
  final Color? errorContainer;
  final Color? onErrorContainer;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DynamicColorScheme &&
          primaryPaletteKeyColor == other.primaryPaletteKeyColor &&
          secondaryPaletteKeyColor == other.secondaryPaletteKeyColor &&
          tertiaryPaletteKeyColor == other.tertiaryPaletteKeyColor &&
          neutralPaletteKeyColor == other.neutralPaletteKeyColor &&
          neutralVariantPaletteKeyColor ==
              other.neutralVariantPaletteKeyColor &&
          errorPaletteKeyColor == other.errorPaletteKeyColor &&
          background == other.background &&
          onBackground == other.onBackground &&
          surface == other.surface &&
          surfaceDim == other.surfaceDim &&
          surfaceBright == other.surfaceBright &&
          surfaceContainerLowest == other.surfaceContainerLowest &&
          surfaceContainerLow == other.surfaceContainerLow &&
          surfaceContainer == other.surfaceContainer &&
          surfaceContainerHigh == other.surfaceContainerHigh &&
          surfaceContainerHighest == other.surfaceContainerHighest &&
          onSurface == other.onSurface &&
          surfaceVariant == other.surfaceVariant &&
          onSurfaceVariant == other.onSurfaceVariant &&
          outline == other.outline &&
          outlineVariant == other.outlineVariant &&
          inverseSurface == other.inverseSurface &&
          inverseOnSurface == other.inverseOnSurface &&
          shadow == other.shadow &&
          scrim == other.scrim &&
          surfaceTint == other.surfaceTint &&
          primary == other.primary &&
          primaryDim == other.primaryDim &&
          onPrimary == other.onPrimary &&
          primaryContainer == other.primaryContainer &&
          onPrimaryContainer == other.onPrimaryContainer &&
          primaryFixed == other.primaryFixed &&
          primaryFixedDim == other.primaryFixedDim &&
          onPrimaryFixed == other.onPrimaryFixed &&
          onPrimaryFixedVariant == other.onPrimaryFixedVariant &&
          inversePrimary == other.inversePrimary &&
          secondary == other.secondary &&
          secondaryDim == other.secondaryDim &&
          onSecondary == other.onSecondary &&
          secondaryContainer == other.secondaryContainer &&
          onSecondaryContainer == other.onSecondaryContainer &&
          secondaryFixed == other.secondaryFixed &&
          secondaryFixedDim == other.secondaryFixedDim &&
          onSecondaryFixed == other.onSecondaryFixed &&
          onSecondaryFixedVariant == other.onSecondaryFixedVariant &&
          tertiary == other.tertiary &&
          tertiaryDim == other.tertiaryDim &&
          onTertiary == other.onTertiary &&
          tertiaryContainer == other.tertiaryContainer &&
          onTertiaryContainer == other.onTertiaryContainer &&
          tertiaryFixed == other.tertiaryFixed &&
          tertiaryFixedDim == other.tertiaryFixedDim &&
          onTertiaryFixed == other.onTertiaryFixed &&
          onTertiaryFixedVariant == other.onTertiaryFixedVariant &&
          error == other.error &&
          errorDim == other.errorDim &&
          onError == other.onError &&
          errorContainer == other.errorContainer &&
          onErrorContainer == other.onErrorContainer;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    brightness,
    primaryPaletteKeyColor,
    secondaryPaletteKeyColor,
    tertiaryPaletteKeyColor,
    neutralPaletteKeyColor,
    neutralVariantPaletteKeyColor,
    errorPaletteKeyColor,
    background,
    onBackground,
    surface,
    surfaceDim,
    surfaceBright,
    surfaceContainerLowest,
    surfaceContainerLow,
    surfaceContainer,
    surfaceContainerHigh,
    surfaceContainerHighest,
    onSurface,
    Object.hash(
      surfaceVariant,
      onSurfaceVariant,
      outline,
      outlineVariant,
      inverseSurface,
      inverseOnSurface,
      shadow,
      scrim,
      surfaceTint,
      primary,
      primaryDim,
      onPrimary,
      primaryContainer,
      onPrimaryContainer,
      primaryFixed,
      primaryFixedDim,
      onPrimaryFixed,
      onPrimaryFixedVariant,
      inversePrimary,
      Object.hash(
        secondary,
        secondaryDim,
        onSecondary,
        secondaryContainer,
        onSecondaryContainer,
        secondaryFixed,
        secondaryFixedDim,
        onSecondaryFixed,
        onSecondaryFixedVariant,
        tertiary,
        tertiaryDim,
        onTertiary,
        tertiaryContainer,
        onTertiaryContainer,
        tertiaryFixed,
        tertiaryFixedDim,
        onTertiaryFixed,
        onTertiaryFixedVariant,
        error,
        Object.hash(errorDim, onError, errorContainer, onErrorContainer),
      ),
    ),
  );
}

abstract final class DynamicColor {
  static bool isDynamicColorAvailable() {
    if (!Platform.isAndroid) return false;
    return jb.DynamicColorPlugin.isDynamicColorAvailable();
  }

  static DynamicColorScheme dynamicLightColorScheme() {
    if (!Platform.isAndroid) {
      return const DynamicColorScheme(brightness: .light);
    }
    final context = Jni.androidApplicationContext;
    final object = jb.DynamicColorPlugin.dynamicLightColorScheme(context);
    final result = DynamicColorScheme._fromNative(object, brightness: .light);
    object.release();
    context.release();
    return result;
  }

  static DynamicColorScheme dynamicDarkColorScheme() {
    if (!Platform.isAndroid) {
      return const DynamicColorScheme(brightness: .dark);
    }
    final context = Jni.androidApplicationContext;
    final object = jb.DynamicColorPlugin.dynamicDarkColorScheme(context);
    final result = DynamicColorScheme._fromNative(object, brightness: .dark);
    object.release();
    context.release();
    return result;
  }

  static DynamicColorScheme dynamicColorScheme(Brightness brightness) =>
      switch (brightness) {
        .light => dynamicLightColorScheme(),
        .dark => dynamicDarkColorScheme(),
      };
}

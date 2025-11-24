import 'dart:ui' show Color, Brightness;

import 'package:dynamic_color_ffi/dynamic_color_ffi_platform_interface.dart';

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

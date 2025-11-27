package dev.deminearchiver.dynamic_color_ffi

import android.content.Context
import android.content.res.Resources
import android.os.Build
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.annotation.FloatRange
import androidx.annotation.Keep
import androidx.annotation.RequiresApi
import androidx.core.content.res.ResourcesCompat
import com.google.android.material.color.DynamicColors
import dev.deminearchiver.dynamic_color_ffi.utils.Cam
import dev.deminearchiver.dynamic_color_ffi.utils.CamUtils

@Suppress("unused")
@Keep
object DynamicColorPlugin {
  @JvmStatic
  fun isDynamicColorAvailable(): Boolean = DynamicColors.isDynamicColorAvailable()

  @JvmStatic
  fun dynamicLightColorScheme(context: Context): DynamicColorScheme {
    return if (Build.VERSION.SDK_INT >= 34) {
      dynamicLightColorScheme34(context)
    } else if (Build.VERSION.SDK_INT >= 31) {
      val tonalPalette = dynamicTonalPalette31(context)
      dynamicLightColorScheme31(tonalPalette)
    } else {
      DynamicColorScheme()
    }
  }

  @JvmStatic
  fun dynamicDarkColorScheme(context: Context): DynamicColorScheme {
    return if (Build.VERSION.SDK_INT >= 34) {
      dynamicDarkColorScheme34(context)
    } else if (Build.VERSION.SDK_INT >= 31) {
      val tonalPalette = dynamicTonalPalette31(context)
      dynamicDarkColorScheme31(tonalPalette)
    } else {
      DynamicColorScheme()
    }
  }


  @RequiresApi(31)
  internal fun dynamicTonalPalette31(context: Context) =
    DynamicTonalPalette(
      // The neutral tonal range from the generated dynamic color palette.
      neutral100 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_0),
      neutral99 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_10),
      neutral98 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(98f),
      neutral96 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(96f),
      neutral95 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_50),
      neutral94 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(94f),
      neutral92 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(92f),
      neutral90 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_100),
      neutral87 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(87f),
      neutral80 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_200),
      neutral70 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_300),
      neutral60 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_400),
      neutral50 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_500),
      neutral40 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600),
      neutral30 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_700),
      neutral24 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(24f),
      neutral22 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(22f),
      neutral20 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_800),
      neutral17 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(17f),
      neutral12 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(12f),
      neutral10 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_900),
      neutral6 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(6f),
      neutral4 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral1_600)
          ?.setLuminance(4f),
      neutral0 = ColorResourceHelper.getColor(context, android.R.color.system_neutral1_1000),

      // The neutral variant tonal range, sometimes called "neutral 2",  from the
      // generated dynamic color palette.
      neutralVariant100 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_0),
      neutralVariant99 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_10),
      neutralVariant98 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(98f),
      neutralVariant96 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(96f),
      neutralVariant95 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_50),
      neutralVariant94 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(94f),
      neutralVariant92 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(92f),
      neutralVariant90 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_100),
      neutralVariant87 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(87f),
      neutralVariant80 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_200),
      neutralVariant70 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_300),
      neutralVariant60 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_400),
      neutralVariant50 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_500),
      neutralVariant40 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600),
      neutralVariant30 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_700),
      neutralVariant24 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(24f),
      neutralVariant22 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(22f),
      neutralVariant20 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_800),
      neutralVariant17 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(17f),
      neutralVariant12 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(12f),
      neutralVariant10 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_900),
      neutralVariant6 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(6f),
      neutralVariant4 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_600)
          ?.setLuminance(4f),
      neutralVariant0 =
        ColorResourceHelper.getColor(context, android.R.color.system_neutral2_1000),

      // The primary tonal range from the generated dynamic color palette.
      primary100 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_0),
      primary99 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_10),
      primary95 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_50),
      primary90 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_100),
      primary80 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_200),
      primary70 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_300),
      primary60 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_400),
      primary50 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_500),
      primary40 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_600),
      primary30 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_700),
      primary20 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_800),
      primary10 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_900),
      primary0 = ColorResourceHelper.getColor(context, android.R.color.system_accent1_1000),

      // The secondary tonal range from the generated dynamic color palette.
      secondary100 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_0),
      secondary99 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_10),
      secondary95 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_50),
      secondary90 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_100),
      secondary80 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_200),
      secondary70 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_300),
      secondary60 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_400),
      secondary50 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_500),
      secondary40 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_600),
      secondary30 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_700),
      secondary20 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_800),
      secondary10 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_900),
      secondary0 = ColorResourceHelper.getColor(context, android.R.color.system_accent2_1000),

      // The tertiary tonal range from the generated dynamic color palette.
      tertiary100 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_0),
      tertiary99 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_10),
      tertiary95 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_50),
      tertiary90 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_100),
      tertiary80 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_200),
      tertiary70 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_300),
      tertiary60 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_400),
      tertiary50 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_500),
      tertiary40 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_600),
      tertiary30 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_700),
      tertiary20 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_800),
      tertiary10 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_900),
      tertiary0 = ColorResourceHelper.getColor(context, android.R.color.system_accent3_1000),
    )


  @RequiresApi(31)
  internal fun dynamicLightColorScheme31(tonalPalette: DynamicTonalPalette) =
    DynamicColorScheme(
      primary = tonalPalette.primary40,
      onPrimary = tonalPalette.primary100,
      primaryContainer = tonalPalette.primary90,
      onPrimaryContainer = tonalPalette.primary10,
      inversePrimary = tonalPalette.primary80,
      secondary = tonalPalette.secondary40,
      onSecondary = tonalPalette.secondary100,
      secondaryContainer = tonalPalette.secondary90,
      onSecondaryContainer = tonalPalette.secondary10,
      tertiary = tonalPalette.tertiary40,
      onTertiary = tonalPalette.tertiary100,
      tertiaryContainer = tonalPalette.tertiary90,
      onTertiaryContainer = tonalPalette.tertiary10,
      background = tonalPalette.neutralVariant98,
      onBackground = tonalPalette.neutralVariant10,
      surface = tonalPalette.neutralVariant98,
      onSurface = tonalPalette.neutralVariant10,
      surfaceVariant = tonalPalette.neutralVariant90,
      onSurfaceVariant = tonalPalette.neutralVariant30,
      inverseSurface = tonalPalette.neutralVariant20,
      inverseOnSurface = tonalPalette.neutralVariant95,
      outline = tonalPalette.neutralVariant50,
      outlineVariant = tonalPalette.neutralVariant80,
      scrim = tonalPalette.neutralVariant0,
      surfaceBright = tonalPalette.neutralVariant98,
      surfaceDim = tonalPalette.neutralVariant87,
      surfaceContainer = tonalPalette.neutralVariant94,
      surfaceContainerHigh = tonalPalette.neutralVariant92,
      surfaceContainerHighest = tonalPalette.neutralVariant90,
      surfaceContainerLow = tonalPalette.neutralVariant96,
      surfaceContainerLowest = tonalPalette.neutralVariant100,
      surfaceTint = tonalPalette.primary40,
      primaryFixed = tonalPalette.primary90,
      primaryFixedDim = tonalPalette.primary80,
      onPrimaryFixed = tonalPalette.primary10,
      onPrimaryFixedVariant = tonalPalette.primary30,
      secondaryFixed = tonalPalette.secondary90,
      secondaryFixedDim = tonalPalette.secondary80,
      onSecondaryFixed = tonalPalette.secondary10,
      onSecondaryFixedVariant = tonalPalette.secondary30,
      tertiaryFixed = tonalPalette.tertiary90,
      tertiaryFixedDim = tonalPalette.tertiary80,
      onTertiaryFixed = tonalPalette.tertiary10,
      onTertiaryFixedVariant = tonalPalette.tertiary30,
    )


  @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
  internal fun dynamicLightColorScheme34(context: Context) = DynamicColorScheme(
    primaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.primary_palette_key_color_light
    ),
    secondaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.secondary_palette_key_color_light
    ),
    tertiaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.tertiary_palette_key_color_light
    ),
    neutralPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.neutral_palette_key_color_light
    ),
    neutralVariantPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.neutral_variant_palette_key_color_light
    ),
    errorPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.error_palette_key_color_light
    ),
    background = ColorResourceHelper.getColor(context, R.color.background_light),
    onBackground = ColorResourceHelper.getColor(context, R.color.on_background_light),
    surface = ColorResourceHelper.getColor(context, R.color.surface_light),
    surfaceDim = ColorResourceHelper.getColor(context, R.color.surface_dim_light),
    surfaceBright = ColorResourceHelper.getColor(context, R.color.surface_bright_light),
    surfaceContainerLowest = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_lowest_light
    ),
    surfaceContainerLow = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_low_light
    ),
    surfaceContainer = ColorResourceHelper.getColor(context, R.color.surface_container_light),
    surfaceContainerHigh = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_high_light
    ),
    surfaceContainerHighest = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_highest_light
    ),
    onSurface = ColorResourceHelper.getColor(context, R.color.on_surface_light),
    surfaceVariant = ColorResourceHelper.getColor(context, R.color.surface_variant_light),
    onSurfaceVariant = ColorResourceHelper.getColor(context, R.color.on_surface_variant_light),
    outline = ColorResourceHelper.getColor(context, R.color.outline_light),
    outlineVariant = ColorResourceHelper.getColor(context, R.color.outline_variant_light),
    inverseSurface = ColorResourceHelper.getColor(context, R.color.inverse_surface_light),
    inverseOnSurface = ColorResourceHelper.getColor(context, R.color.inverse_on_surface_light),
    shadow = ColorResourceHelper.getColor(context, R.color.shadow_light),
    scrim = ColorResourceHelper.getColor(context, R.color.scrim_light),
    surfaceTint = ColorResourceHelper.getColor(context, R.color.surface_tint_light),
    primary = ColorResourceHelper.getColor(context, R.color.primary_light),
    primaryDim = ColorResourceHelper.getColor(context, R.color.primary_dim_light),
    onPrimary = ColorResourceHelper.getColor(context, R.color.on_primary_light),
    primaryContainer = ColorResourceHelper.getColor(context, R.color.primary_container_light),
    onPrimaryContainer = ColorResourceHelper.getColor(context, R.color.on_primary_container_light),
    primaryFixed = ColorResourceHelper.getColor(context, R.color.primary_fixed),
    primaryFixedDim = ColorResourceHelper.getColor(context, R.color.primary_fixed_dim),
    onPrimaryFixed = ColorResourceHelper.getColor(context, R.color.on_primary_fixed),
    onPrimaryFixedVariant = ColorResourceHelper.getColor(context, R.color.on_primary_fixed_variant),
    inversePrimary = ColorResourceHelper.getColor(context, R.color.inverse_primary_light),
    secondary = ColorResourceHelper.getColor(context, R.color.secondary_light),
    secondaryDim = ColorResourceHelper.getColor(context, R.color.secondary_dim_light),
    onSecondary = ColorResourceHelper.getColor(context, R.color.on_secondary_light),
    secondaryContainer = ColorResourceHelper.getColor(context, R.color.secondary_container_light),
    onSecondaryContainer = ColorResourceHelper.getColor(
      context,
      R.color.on_secondary_container_light
    ),
    secondaryFixed = ColorResourceHelper.getColor(context, R.color.secondary_fixed),
    secondaryFixedDim = ColorResourceHelper.getColor(context, R.color.secondary_fixed_dim),
    onSecondaryFixed = ColorResourceHelper.getColor(context, R.color.on_secondary_fixed),
    onSecondaryFixedVariant = ColorResourceHelper.getColor(
      context,
      R.color.on_secondary_fixed_variant
    ),
    tertiary = ColorResourceHelper.getColor(context, R.color.tertiary_light),
    tertiaryDim = ColorResourceHelper.getColor(context, R.color.tertiary_dim_light),
    onTertiary = ColorResourceHelper.getColor(context, R.color.on_tertiary_light),
    tertiaryContainer = ColorResourceHelper.getColor(context, R.color.tertiary_container_light),
    onTertiaryContainer = ColorResourceHelper.getColor(
      context,
      R.color.on_tertiary_container_light
    ),
    tertiaryFixed = ColorResourceHelper.getColor(context, R.color.tertiary_fixed),
    tertiaryFixedDim = ColorResourceHelper.getColor(context, R.color.tertiary_fixed_dim),
    onTertiaryFixed = ColorResourceHelper.getColor(context, R.color.on_tertiary_fixed),
    onTertiaryFixedVariant = ColorResourceHelper.getColor(
      context,
      R.color.on_tertiary_fixed_variant
    ),
    error = ColorResourceHelper.getColor(context, R.color.error_light),
    errorDim = ColorResourceHelper.getColor(context, R.color.error_dim_light),
    onError = ColorResourceHelper.getColor(context, R.color.on_error_light),
    errorContainer = ColorResourceHelper.getColor(context, R.color.error_container_light),
    onErrorContainer = ColorResourceHelper.getColor(context, R.color.on_error_container_light),
  )


  @RequiresApi(31)
  internal fun dynamicDarkColorScheme31(tonalPalette: DynamicTonalPalette) =
    DynamicColorScheme(
      primary = tonalPalette.primary80,
      onPrimary = tonalPalette.primary20,
      primaryContainer = tonalPalette.primary30,
      onPrimaryContainer = tonalPalette.primary90,
      inversePrimary = tonalPalette.primary40,
      secondary = tonalPalette.secondary80,
      onSecondary = tonalPalette.secondary20,
      secondaryContainer = tonalPalette.secondary30,
      onSecondaryContainer = tonalPalette.secondary90,
      tertiary = tonalPalette.tertiary80,
      onTertiary = tonalPalette.tertiary20,
      tertiaryContainer = tonalPalette.tertiary30,
      onTertiaryContainer = tonalPalette.tertiary90,
      background = tonalPalette.neutralVariant6,
      onBackground = tonalPalette.neutralVariant90,
      surface = tonalPalette.neutralVariant6,
      onSurface = tonalPalette.neutralVariant90,
      surfaceVariant = tonalPalette.neutralVariant30,
      onSurfaceVariant = tonalPalette.neutralVariant80,
      inverseSurface = tonalPalette.neutralVariant90,
      inverseOnSurface = tonalPalette.neutralVariant20,
      outline = tonalPalette.neutralVariant60,
      outlineVariant = tonalPalette.neutralVariant30,
      scrim = tonalPalette.neutralVariant0,
      surfaceBright = tonalPalette.neutralVariant24,
      surfaceDim = tonalPalette.neutralVariant6,
      surfaceContainer = tonalPalette.neutralVariant12,
      surfaceContainerHigh = tonalPalette.neutralVariant17,
      surfaceContainerHighest = tonalPalette.neutralVariant22,
      surfaceContainerLow = tonalPalette.neutralVariant10,
      surfaceContainerLowest = tonalPalette.neutralVariant4,
      surfaceTint = tonalPalette.primary80,
      primaryFixed = tonalPalette.primary90,
      primaryFixedDim = tonalPalette.primary80,
      onPrimaryFixed = tonalPalette.primary10,
      onPrimaryFixedVariant = tonalPalette.primary30,
      secondaryFixed = tonalPalette.secondary90,
      secondaryFixedDim = tonalPalette.secondary80,
      onSecondaryFixed = tonalPalette.secondary10,
      onSecondaryFixedVariant = tonalPalette.secondary30,
      tertiaryFixed = tonalPalette.tertiary90,
      tertiaryFixedDim = tonalPalette.tertiary80,
      onTertiaryFixed = tonalPalette.tertiary10,
      onTertiaryFixedVariant = tonalPalette.tertiary30,
    )

  @RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
  internal fun dynamicDarkColorScheme34(context: Context): DynamicColorScheme = DynamicColorScheme(
    primaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.primary_palette_key_color_dark
    ),
    secondaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.secondary_palette_key_color_dark
    ),
    tertiaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.tertiary_palette_key_color_dark
    ),
    neutralPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.neutral_palette_key_color_dark
    ),
    neutralVariantPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.neutral_variant_palette_key_color_dark
    ),
    errorPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      R.color.error_palette_key_color_dark
    ),
    background = ColorResourceHelper.getColor(context, R.color.background_dark),
    onBackground = ColorResourceHelper.getColor(context, R.color.on_background_dark),
    surface = ColorResourceHelper.getColor(context, R.color.surface_dark),
    surfaceDim = ColorResourceHelper.getColor(context, R.color.surface_dim_dark),
    surfaceBright = ColorResourceHelper.getColor(context, R.color.surface_bright_dark),
    surfaceContainerLowest = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_lowest_dark
    ),
    surfaceContainerLow = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_low_dark
    ),
    surfaceContainer = ColorResourceHelper.getColor(context, R.color.surface_container_dark),
    surfaceContainerHigh = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_high_dark
    ),
    surfaceContainerHighest = ColorResourceHelper.getColor(
      context,
      R.color.surface_container_highest_dark
    ),
    onSurface = ColorResourceHelper.getColor(context, R.color.on_surface_dark),
    surfaceVariant = ColorResourceHelper.getColor(context, R.color.surface_variant_dark),
    onSurfaceVariant = ColorResourceHelper.getColor(context, R.color.on_surface_variant_dark),
    outline = ColorResourceHelper.getColor(context, R.color.outline_dark),
    outlineVariant = ColorResourceHelper.getColor(context, R.color.outline_variant_dark),
    inverseSurface = ColorResourceHelper.getColor(context, R.color.inverse_surface_dark),
    inverseOnSurface = ColorResourceHelper.getColor(context, R.color.inverse_on_surface_dark),
    shadow = ColorResourceHelper.getColor(context, R.color.shadow_dark),
    scrim = ColorResourceHelper.getColor(context, R.color.scrim_dark),
    surfaceTint = ColorResourceHelper.getColor(context, R.color.surface_tint_dark),
    primary = ColorResourceHelper.getColor(context, R.color.primary_dark),
    primaryDim = ColorResourceHelper.getColor(context, R.color.primary_dim_dark),
    onPrimary = ColorResourceHelper.getColor(context, R.color.on_primary_dark),
    primaryContainer = ColorResourceHelper.getColor(context, R.color.primary_container_dark),
    onPrimaryContainer = ColorResourceHelper.getColor(context, R.color.on_primary_container_dark),
    primaryFixed = ColorResourceHelper.getColor(context, R.color.primary_fixed),
    primaryFixedDim = ColorResourceHelper.getColor(context, R.color.primary_fixed_dim),
    onPrimaryFixed = ColorResourceHelper.getColor(context, R.color.on_primary_fixed),
    onPrimaryFixedVariant = ColorResourceHelper.getColor(context, R.color.on_primary_fixed_variant),
    inversePrimary = ColorResourceHelper.getColor(context, R.color.inverse_primary_dark),
    secondary = ColorResourceHelper.getColor(context, R.color.secondary_dark),
    secondaryDim = ColorResourceHelper.getColor(context, R.color.secondary_dim_dark),
    onSecondary = ColorResourceHelper.getColor(context, R.color.on_secondary_dark),
    secondaryContainer = ColorResourceHelper.getColor(context, R.color.secondary_container_dark),
    onSecondaryContainer = ColorResourceHelper.getColor(
      context,
      R.color.on_secondary_container_dark
    ),
    secondaryFixed = ColorResourceHelper.getColor(context, R.color.secondary_fixed),
    secondaryFixedDim = ColorResourceHelper.getColor(context, R.color.secondary_fixed_dim),
    onSecondaryFixed = ColorResourceHelper.getColor(context, R.color.on_secondary_fixed),
    onSecondaryFixedVariant = ColorResourceHelper.getColor(
      context,
      R.color.on_secondary_fixed_variant
    ),
    tertiary = ColorResourceHelper.getColor(context, R.color.tertiary_dark),
    tertiaryDim = ColorResourceHelper.getColor(context, R.color.tertiary_dim_dark),
    onTertiary = ColorResourceHelper.getColor(context, R.color.on_tertiary_dark),
    tertiaryContainer = ColorResourceHelper.getColor(context, R.color.tertiary_container_dark),
    onTertiaryContainer = ColorResourceHelper.getColor(
      context,
      R.color.on_tertiary_container_dark
    ),
    tertiaryFixed = ColorResourceHelper.getColor(context, R.color.tertiary_fixed),
    tertiaryFixedDim = ColorResourceHelper.getColor(context, R.color.tertiary_fixed_dim),
    onTertiaryFixed = ColorResourceHelper.getColor(context, R.color.on_tertiary_fixed),
    onTertiaryFixedVariant = ColorResourceHelper.getColor(
      context,
      R.color.on_tertiary_fixed_variant
    ),
    error = ColorResourceHelper.getColor(context, R.color.error_dark),
    errorDim = ColorResourceHelper.getColor(context, R.color.error_dim_dark),
    onError = ColorResourceHelper.getColor(context, R.color.on_error_dark),
    errorContainer = ColorResourceHelper.getColor(context, R.color.error_container_dark),
    onErrorContainer = ColorResourceHelper.getColor(context, R.color.on_error_container_dark),
  )
}

/**
 * Set the luminance(tone) of this color. Chroma may decrease because chroma has a different maximum
 * for any given hue and luminance.
 *
 * @param newLuminance 0 <= newLuminance <= 100; invalid values are corrected.
 */
internal fun Int.setLuminance(@FloatRange(from = 0.0, to = 100.0) newLuminance: Float): Int {
  if ((newLuminance < 0.0001) or (newLuminance > 99.9999)) {
    return CamUtils.argbFromLstar(newLuminance.toDouble())
  }
  val baseCam = Cam.fromInt(this)
  val baseColor = Cam.getInt(baseCam.hue, baseCam.chroma, newLuminance)
  return baseColor
}

internal object ColorResourceHelper {
  @ColorInt
  fun getColor(context: Context, @ColorRes id: Int): Int? {
    return if (id == Resources.ID_NULL) null else try {
      context.resources.getColor(id, context.theme)
    } catch (_: Resources.NotFoundException) {
      null
    }
  }
}

package dev.deminearchiver.dynamic_color_ffi

import android.content.Context
import android.os.Build
import androidx.annotation.ColorInt
import androidx.annotation.ColorRes
import androidx.annotation.Keep
import androidx.annotation.RequiresApi
import com.google.android.material.color.DynamicColors

@Keep
object DynamicColorPlugin {
  @JvmStatic
  fun isDynamicColorAvailable(): Boolean = DynamicColors.isDynamicColorAvailable()

  @JvmStatic
  fun dynamicLightColorScheme(context: Context): DynamicColorScheme {
    return if (Build.VERSION.SDK_INT >= 34) {
      // SDKs 34 and greater return appropriate Chroma6 values for neutral palette
      dynamicLightColorScheme34(context)
    } else {
      // SDKs 31-33 return Chroma4 values for neutral palette, we instead leverage neutral
      // variant which provides chroma8 for less grey tones.
      //val tonalPalette = dynamicTonalPalette(context)
      //dynamicDarkColorScheme31(tonalPalette)
      DynamicColorScheme()
    }
  }
}


internal fun dynamicLightColorScheme31(): DynamicColorScheme {
  return DynamicColorScheme()
}

@RequiresApi(Build.VERSION_CODES.UPSIDE_DOWN_CAKE)
internal fun dynamicLightColorScheme34(context: Context): DynamicColorScheme {
  return DynamicColorScheme(
    primaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      android.R.color.system_palette_key_color_primary_light
    ),
    secondaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      android.R.color.system_palette_key_color_secondary_light
    ),
    tertiaryPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      android.R.color.system_palette_key_color_tertiary_light
    ),
    neutralPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      android.R.color.system_palette_key_color_neutral_light
    ),
    neutralVariantPaletteKeyColor = ColorResourceHelper.getColor(
      context,
      android.R.color.system_palette_key_color_neutral_variant_light
    ),
    //errorPaletteKeyColor = ColorResourceHelper.getColor(
    //  context,
    //  android.R.color.system_palette_key_color_error_light
    //),
    background = ColorResourceHelper.getColor(context, android.R.color.system_background_light),
    onBackground = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_background_light
    ),
    surface = ColorResourceHelper.getColor(context, android.R.color.system_surface_light),
    surfaceDim = ColorResourceHelper.getColor(context, android.R.color.system_surface_dim_light),
    surfaceBright = ColorResourceHelper.getColor(
      context,
      android.R.color.system_surface_bright_light
    ),
    surfaceContainerLowest = ColorResourceHelper.getColor(
      context,
      android.R.color.system_surface_container_lowest_light
    ),
    surfaceContainerLow = ColorResourceHelper.getColor(
      context,
      android.R.color.system_surface_container_low_light
    ),
    surfaceContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_surface_container_light
    ),
    surfaceContainerHigh = ColorResourceHelper.getColor(
      context,
      android.R.color.system_surface_container_high_light
    ),
    surfaceContainerHighest = ColorResourceHelper.getColor(
      context,
      android.R.color.system_surface_container_highest_light
    ),
    onSurface = ColorResourceHelper.getColor(context, android.R.color.system_on_surface_light),
    surfaceVariant = ColorResourceHelper.getColor(
      context,
      android.R.color.system_surface_variant_light
    ),
    onSurfaceVariant = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_surface_variant_light
    ),
    outline = ColorResourceHelper.getColor(context, android.R.color.system_outline_light),
    outlineVariant = ColorResourceHelper.getColor(
      context,
      android.R.color.system_outline_variant_light
    ),
    inverseSurface = ColorResourceHelper.getColor(context, android.R.color.system_surface_dark),
    inverseOnSurface = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_surface_dark
    ),
    //shadow = ColorResourceHelper.getColor(context, android.R.color.system_shadow),
    //scrim = ColorResourceHelper.getColor(context, android.R.color.system_scrim),
    surfaceTint = ColorResourceHelper.getColor(context, android.R.color.system_primary_light),
    primary = ColorResourceHelper.getColor(context, android.R.color.system_primary_light),
    primaryDim = ColorResourceHelper.getColor(context, android.R.color.system_primary_light),
    onPrimary = ColorResourceHelper.getColor(context, android.R.color.system_on_primary_light),
    primaryContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_primary_container_light
    ),
    onPrimaryContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_primary_container_light
    ),
    primaryFixed = ColorResourceHelper.getColor(context, android.R.color.system_primary_fixed),
    primaryFixedDim = ColorResourceHelper.getColor(
      context,
      android.R.color.system_primary_fixed_dim
    ),
    onPrimaryFixed = ColorResourceHelper.getColor(context, android.R.color.system_on_primary_fixed),
    onPrimaryFixedVariant = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_primary_fixed_variant
    ),
    inversePrimary = ColorResourceHelper.getColor(context, android.R.color.system_primary_dark),
    secondary = ColorResourceHelper.getColor(context, android.R.color.system_secondary_light),
    secondaryDim = ColorResourceHelper.getColor(context, android.R.color.system_secondary_light),
    onSecondary = ColorResourceHelper.getColor(context, android.R.color.system_on_secondary_light),
    secondaryContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_secondary_container_light
    ),
    onSecondaryContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_secondary_container_light
    ),
    secondaryFixed = ColorResourceHelper.getColor(context, android.R.color.system_secondary_fixed),
    secondaryFixedDim = ColorResourceHelper.getColor(
      context,
      android.R.color.system_secondary_fixed_dim
    ),
    onSecondaryFixed = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_secondary_fixed
    ),
    onSecondaryFixedVariant = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_secondary_fixed_variant
    ),
    tertiary = ColorResourceHelper.getColor(context, android.R.color.system_tertiary_light),
    tertiaryDim = ColorResourceHelper.getColor(context, android.R.color.system_tertiary_light),
    onTertiary = ColorResourceHelper.getColor(context, android.R.color.system_on_tertiary_light),
    tertiaryContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_tertiary_container_light
    ),
    onTertiaryContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_tertiary_container_light
    ),
    tertiaryFixed = ColorResourceHelper.getColor(context, android.R.color.system_tertiary_fixed),
    tertiaryFixedDim = ColorResourceHelper.getColor(
      context,
      android.R.color.system_tertiary_fixed_dim
    ),
    onTertiaryFixed = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_tertiary_fixed
    ),
    onTertiaryFixedVariant = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_tertiary_fixed_variant
    ),
    error = ColorResourceHelper.getColor(context, android.R.color.system_error_light),
    errorDim = ColorResourceHelper.getColor(context, android.R.color.system_error_light),
    onError = ColorResourceHelper.getColor(context, android.R.color.system_on_error_light),
    errorContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_error_container_light
    ),
    onErrorContainer = ColorResourceHelper.getColor(
      context,
      android.R.color.system_on_error_container_light
    ),
    controlActivated = ColorResourceHelper.getColor(
      context,
      android.R.color.system_control_activated_light
    ),
    controlNormal = ColorResourceHelper.getColor(
      context,
      android.R.color.system_control_normal_light
    ),
    controlHighlight = ColorResourceHelper.getColor(
      context,
      android.R.color.system_control_highlight_light
    ),
    textPrimaryInverse = ColorResourceHelper.getColor(
      context,
      android.R.color.system_text_primary_inverse_light
    ),
    textSecondaryAndTertiaryInverse = ColorResourceHelper.getColor(
      context,
      android.R.color.system_text_secondary_and_tertiary_inverse_light
    ),
    textPrimaryInverseDisableOnly = ColorResourceHelper.getColor(
      context,
      android.R.color.system_text_primary_inverse_disable_only_light
    ),
    textSecondaryAndTertiaryInverseDisabled = ColorResourceHelper.getColor(
      context,
      android.R.color.system_text_secondary_and_tertiary_inverse_disabled_light
    ),
    textHintInverse = ColorResourceHelper.getColor(
      context,
      android.R.color.system_text_hint_inverse_light
    ),
  )
}

@RequiresApi(Build.VERSION_CODES.M)
private object ColorResourceHelper {
  @ColorInt
  fun getColor(context: Context, @ColorRes id: Int): Int {
    return context.resources.getColor(id, context.theme)
  }
}

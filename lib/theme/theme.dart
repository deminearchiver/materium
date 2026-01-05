import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:material/material_color_utilities.dart';
import 'package:materium/flutter.dart';

// Open fonts (bundled as assets or available as system fonts)
const _roboto = "Roboto";
const _firaCode = FontFamily.firaCode;
const _googleSans = FontFamily.googleSans;
const _googleSansCode = FontFamily.googleSansCode;
const _googleSansFlex = FontFamily.googleSansFlex;
const _robotoFlex = FontFamily.robotoFlex;

class TypographyDefaults with Diagnosticable {
  const TypographyDefaults.from({
    this.typeface = const .from(),
    this.typescale = const .from(),
  });

  // TODO: implement TypographyDefaults.fromPlatform
  factory TypographyDefaults.fromPlatform(TargetPlatform platform) =>
      switch (platform) {
        _ => const .from(),
      };

  final TypefaceThemeDataPartial typeface;
  final TypescaleThemeDataPartial typescale;

  TypographyDefaults copyWith({
    covariant TypefaceThemeDataPartial? typeface,
    covariant TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? TypographyDefaults.from(
          typeface: typeface ?? this.typeface,
          typescale: typescale ?? this.typescale,
        )
      : this;

  TypographyDefaults mergeWith({
    TypefaceThemeDataPartial? typeface,
    TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? TypographyDefaults.from(
          typeface: this.typeface.merge(typeface),
          typescale: this.typescale.merge(typescale),
        )
      : this;

  TypographyDefaults merge(TypographyDefaults? other) => other != null
      ? mergeWith(typeface: other.typeface, typescale: other.typescale)
      : this;

  Widget build(BuildContext context, Widget child) => TypefaceTheme.merge(
    data: typeface,
    child: TypescaleTheme.merge(data: typescale, child: child),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        DiagnosticsProperty<TypefaceThemeDataPartial>(
          "typeface",
          typeface,
          defaultValue: const TypefaceThemeDataPartial.from(),
        ),
      )
      ..add(
        DiagnosticsProperty<TypescaleThemeDataPartial>(
          "typescale",
          typescale,
          defaultValue: const TypescaleThemeDataPartial.from(),
        ),
      );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is TypographyDefaults &&
          typeface == other.typeface &&
          typescale == other.typescale;

  @override
  int get hashCode => Object.hash(runtimeType, typeface, typescale);

  /// A Material 3 Expressive type scale which uses Roboto Flex.
  static const material3Expressive2025 = TypographyDefaults.from(
    typeface: .from(
      // Material 3 Expressive introduced variable font support
      brand: [_robotoFlex, _roboto],
      plain: [_robotoFlex, _roboto],
    ),
  );

  /// A Material 3 Expressive type scale which uses Google Sans Flex,
  /// a previously restricted but freshly opened Google brand font.
  ///
  /// It falls back to using Roboto Flex, then Roboto.
  static const material3Expressive2026 = TypographyDefaults.from(
    typeface: .from(
      // The ROND axis is currently only available for Google Sans Flex,
      // making it a no-op for most of the other possibly installed fonts.
      // This particular information was ripped from a file
      // located at the path "/product/etc/fonts_customization.xml"
      // on a Google Pixel with Android 16 QPR1 (Material 3 Expressive).
      brand: [_googleSansFlex, _googleSans, _robotoFlex, _roboto],
      plain: [_googleSansFlex, _googleSans, _robotoFlex, _roboto],
    ),
    typescale: .from(
      displayLarge: .from(rond: 0.0),
      displayMedium: .from(rond: 0.0),
      displaySmall: .from(rond: 0.0),
      headlineLarge: .from(rond: 0.0),
      headlineMedium: .from(rond: 0.0),
      headlineSmall: .from(rond: 0.0),
      titleLarge: .from(rond: 0.0),
      titleMedium: .from(rond: 0.0),
      titleSmall: .from(rond: 0.0),
      bodyLarge: .from(rond: 0.0),
      bodyMedium: .from(rond: 0.0),
      bodySmall: .from(rond: 0.0),
      labelLarge: .from(rond: 0.0),
      labelMedium: .from(rond: 0.0),
      labelSmall: .from(rond: 0.0),
      displayLargeEmphasized: .from(rond: 100.0),
      displayMediumEmphasized: .from(rond: 100.0),
      displaySmallEmphasized: .from(rond: 100.0),
      headlineLargeEmphasized: .from(rond: 100.0),
      headlineMediumEmphasized: .from(rond: 100.0),
      headlineSmallEmphasized: .from(rond: 100.0),
      titleLargeEmphasized: .from(rond: 100.0),
      titleMediumEmphasized: .from(rond: 100.0),
      titleSmallEmphasized: .from(rond: 100.0),
      bodyLargeEmphasized: .from(rond: 100.0),
      bodyMediumEmphasized: .from(rond: 100.0),
      bodySmallEmphasized: .from(rond: 100.0),
      labelLargeEmphasized: .from(rond: 100.0),
      labelMediumEmphasized: .from(rond: 100.0),
      labelSmallEmphasized: .from(rond: 100.0),
    ),
  );
}

enum CustomCheckboxColor { standard, listItemPhone, listItemWatch }

enum CustomRadioButtonColor { standard, listItemPhone, listItemWatch }

enum CustomSwitchSize { phone, watch, nowInAndroid }

enum CustomSwitchColor {
  /// Baseline switch (no icons)
  baseline,

  /// Expressive switch (both icons)
  expressive,

  /// Now in Android switch (no icons)
  nowInAndroid,

  /// Inside of a list item on phone
  listItemPhone,

  /// Inside of a list item on watch (standard watch switch)
  listItemWatch,
}

enum CustomListItemVariant { settings, licenses, logs }

abstract final class CustomThemeFactory {
  static CheckboxThemeDataPartial createCheckboxTheme({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    CustomRadioButtonColor color = .standard,
  }) => switch (color) {
    .listItemPhone => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      containerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      containerOutline: .resolveWith(
        (states) => .from(
          color: switch (states) {
            CheckboxEnabledStates(isSelected: true) =>
              colorTheme.secondary.withValues(alpha: 0.0),
            _ => null,
          },
        ),
      ),
      iconColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates() => colorTheme.onSecondary,
          _ => null,
        },
      ),
    ),
    .listItemWatch => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      containerColor: .resolveWith(
        (states) => switch (states) {
          CheckboxDisabledStates(isSelected: false) =>
            colorTheme.surfaceContainer.withValues(alpha: 0.0),
          CheckboxEnabledStates(isSelected: false) =>
            colorTheme.surfaceContainer,
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      containerOutline: .resolveWith(
        (states) => .from(
          color: switch (states) {
            CheckboxEnabledStates(isSelected: false) => colorTheme.outline,
            CheckboxEnabledStates(isSelected: true) =>
              colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
            _ => null,
          },
        ),
      ),
      iconColor: .resolveWith(
        (states) => switch (states) {
          CheckboxEnabledStates(isSelected: true) =>
            colorTheme.primaryContainer,
          _ => null,
        },
      ),
    ),
    _ => const .from(),
  };

  static RadioButtonThemeDataPartial createRadioButtonTheme({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    CustomRadioButtonColor color = .standard,
  }) => switch (color) {
    .listItemPhone => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      // iconBackgroundColor: .resolveWith(
      //   (states) => switch (states) {
      //     RadioButtonEnabledStates(isSelected: true) =>
      //       colorTheme.secondary,
      //     _ => null,
      //   },
      // ),
      iconOutlineColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
      iconDotColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) => colorTheme.secondary,
          _ => null,
        },
      ),
    ),
    .listItemWatch => .from(
      stateLayerColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      iconBackgroundColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonDisabledStates(isSelected: false) =>
            colorTheme.surfaceContainer.withValues(alpha: 0.0),
          RadioButtonDisabledStates(isSelected: true) =>
            colorTheme.primaryContainer.withValues(alpha: 0.0),
          RadioButtonEnabledStates(isSelected: false) =>
            colorTheme.surfaceContainer,
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.primaryContainer,
          _ => null,
        },
      ),
      iconOutlineColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: false) => colorTheme.outline,
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
      iconDotColor: .resolveWith(
        (states) => switch (states) {
          RadioButtonEnabledStates(isSelected: false) => colorTheme.outline,
          RadioButtonEnabledStates(isSelected: true) =>
            colorTheme.onPrimaryContainer,
          _ => null,
        },
      ),
    ),
    _ => const .from(),
  };

  static SwitchThemeDataPartial createSwitchTheme({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    CustomSwitchSize size = .phone,
    CustomSwitchColor color = .expressive,
    bool? showUnselectedIcon,
    bool? showSelectedIcon,
  }) {
    showUnselectedIcon = showUnselectedIcon ?? true;
    showSelectedIcon = showSelectedIcon ?? true;

    return switch (color) {
      .baseline => .from(
        handleSize: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isPressed: true) => const .square(28.0),
            SwitchStates(isSelected: false) => const .square(16.0),
            SwitchStates(isSelected: true) => const .square(24.0),
          },
        ),
        iconTheme: .resolveWith(
          (states) => switch (states) {
            SwitchStates(isSelected: false) => const .from(
              color: Colors.transparent,
            ),
            SwitchStates(isSelected: true) => const .from(
              color: Colors.transparent,
            ),
          },
        ),
      ),
      .expressive => const .from(),
      .listItemPhone => .from(
        trackColor: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => colorTheme.secondary,
            _ => null,
          },
        ),
        trackOutline: .resolveWith(
          (states) => .from(
            color: switch (states) {
              SwitchDisabledStates(isSelected: true) =>
                colorTheme.secondary.withValues(alpha: 0.0),
              SwitchStates(isSelected: true) => colorTheme.secondary.withValues(
                alpha: 0.0,
              ),
              _ => null,
            },
          ),
        ),
        stateLayerColor: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => colorTheme.secondary,
            _ => null,
          },
        ),
        handleColor: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => colorTheme.onSecondary,
            _ => null,
          },
        ),
        iconTheme: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isSelected: true) => .from(
              color: colorTheme.secondary,
            ),
            _ => null,
          },
        ),
      ),
      .listItemWatch => .from(
        handleSize: .resolveWith(
          (states) => switch (states) {
            SwitchEnabledStates(isPressed: true) => const .square(28.0),
            SwitchStates(isSelected: false) => const .square(16.0),
            SwitchStates(isSelected: true) => const .square(24.0),
          },
        ),
        trackColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates(isSelected: false) => null,
            SwitchDisabledStates(isSelected: true) => null,
            SwitchStates(isSelected: false) => colorTheme.surfaceContainer,
            SwitchStates(isSelected: true) => colorTheme.onPrimaryContainer,
          },
        ),
        trackOutline: .resolveWith(
          (states) => .from(
            color: switch (states) {
              SwitchDisabledStates(isSelected: false) => null,
              SwitchDisabledStates(isSelected: true) =>
                colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
              SwitchStates(isSelected: false) => colorTheme.outline,
              SwitchStates(isSelected: true) =>
                colorTheme.onPrimaryContainer.withValues(alpha: 0.0),
            },
          ),
        ),
        handleColor: .resolveWith(
          (states) => switch (states) {
            SwitchDisabledStates(isSelected: false) => null,
            SwitchDisabledStates(isSelected: true) => null,
            SwitchStates(isSelected: false) => colorTheme.outline,
            SwitchStates(isSelected: true) => colorTheme.primaryContainer,
          },
        ),
        iconTheme: .resolveWith(
          (states) => switch (states) {
            SwitchStates(isSelected: false) => const .from(
              color: Colors.transparent,
            ),
            // SwitchDisabledStates(isSelected: false) => null,
            SwitchDisabledStates(isSelected: true) => null,
            // SwitchStates(isSelected: false) => .from(
            //   color: colorTheme.surfaceContainer,
            // ),
            SwitchStates(isSelected: true) => .from(
              color: colorTheme.onPrimaryContainer,
            ),
          },
        ),
      ),
      _ => const .from(),
    };
  }

  static ListItemThemeDataPartial createListItemTheme({
    required ColorThemeData colorTheme,
    required ElevationThemeData elevationTheme,
    required ShapeThemeData shapeTheme,
    required StateThemeData stateTheme,
    required TypescaleThemeData typescaleTheme,
    required CustomListItemVariant variant,
  }) => switch (variant) {
    .settings => .from(
      containerColor: .all(colorTheme.surfaceBright),
      // stateLayerColor: .all(colorTheme.primary),
      // leadingIconTheme: .all(.from(color: colorTheme.primary)),
      // leadingTextStyle: .all(TextStyle(color: colorTheme.primary)),
      overlineTextStyle: .all(
        typescaleTheme.labelMedium.toTextStyle(
          color: colorTheme.onSurfaceVariant,
        ),
      ),
      headlineTextStyle: .all(
        typescaleTheme.bodyLargeEmphasized.toTextStyle(
          color: colorTheme.onSurface,
        ),
      ),
      supportingTextStyle: .all(
        typescaleTheme.bodyMedium.toTextStyle(
          color: colorTheme.onSurfaceVariant,
        ),
      ),
    ),
    .licenses => .from(
      // containerColor: .all(colorTheme.surfaceBright),
      // headlineTextStyle: .all(
      //   typescaleTheme.titleSmallEmphasized.toTextStyle().copyWith(
      //     fontFamily: FontFamily.googleSansCode,
      //     color: colorTheme.onSurface,
      //   ),
      // ),
      // supportingTextStyle: .all(
      //   typescaleTheme.bodySmall.toTextStyle(
      //     color: colorTheme.onSurfaceVariant,
      //   ),
      // ),
    ),
    .logs => .from(
      containerColor: .all(colorTheme.surface),
      overlineTextStyle: .all(
        typescaleTheme.labelSmall
            .mergeWith(font: const [FontFamily.googleSansCode])
            .toTextStyle(color: colorTheme.onSurfaceVariant),
      ),
      headlineTextStyle: .all(
        typescaleTheme.bodyMedium
            .mergeWith(font: const [FontFamily.googleSansCode])
            .toTextStyle(color: colorTheme.onSurface),
      ),
    ),
  };
}

abstract final class MarkdownThemeFactory {
  static MarkdownStyleSheet defaultStylesheetOf({
    required ColorThemeData colorTheme,
    required TypescaleThemeData typescaleTheme,
  }) {
    return MarkdownStyleSheet(
      p: typescaleTheme.bodyMedium.toTextStyle(color: colorTheme.onSurface),
      a: TextStyle(color: colorTheme.tertiary),
      h3: typescaleTheme.headlineSmall.toTextStyle(color: colorTheme.onSurface),
      em: const TextStyle(fontStyle: FontStyle.italic),
      strong: const TextStyle(fontWeight: FontWeight.bold),
      del: const TextStyle(decoration: TextDecoration.lineThrough),
    );
  }
}

extension on DynamicSchemeVariant {
  Variant _toVariant() => switch (this) {
    .monochrome => .monochrome,
    .neutral => .neutral,
    .tonalSpot => .tonalSpot,
    .vibrant => .vibrant,
    .expressive => .expressive,
    .fidelity => .fidelity,
    .content => .content,
    .rainbow => .rainbow,
    .fruitSalad => .fruitSalad,
  };
}

Color _harmonizeColor(Color designColor, Color sourceColor) =>
    designColor != sourceColor
    ? Color(Blend.harmonize(designColor.toARGB32(), sourceColor.toARGB32()))
    : designColor;

extension on Color {
  Hct _toHct() => .fromInt(toARGB32());

  Color _harmonizeWith(Color sourceColor) => _harmonizeColor(this, sourceColor);
}

enum ExtendedColorPalette { primary, secondary, tertiary }

enum ExtendedColorRole {
  color,
  onColor,
  colorContainer,
  onColorContainer,
  colorFixed,
  colorFixedDim,
  onColorFixed,
  onColorFixedVariant;

  Color resolve(ExtendedColor extendedColor) => switch (this) {
    .color => extendedColor.color,
    .onColor => extendedColor.onColor,
    .colorContainer => extendedColor.colorContainer,
    .onColorContainer => extendedColor.onColorContainer,
    .colorFixed => extendedColor.colorFixed,
    .colorFixedDim => extendedColor.colorFixedDim,
    .onColorFixed => extendedColor.onColorFixed,
    .onColorFixedVariant => extendedColor.onColorFixedVariant,
  };
}

class ExtendedColorPairing {
  const ExtendedColorPairing.from({
    required this.containerColorRole,
    required this.contentColorRole,
  });

  final ExtendedColorRole containerColorRole;
  final ExtendedColorRole contentColorRole;

  Color resolveContainerColor(ExtendedColor extendedColor) =>
      containerColorRole.resolve(extendedColor);
  Color resolveContentColor(ExtendedColor extendedColor) =>
      contentColorRole.resolve(extendedColor);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ExtendedColorPairing &&
          containerColorRole == other.containerColorRole &&
          contentColorRole == other.contentColorRole;

  @override
  int get hashCode =>
      Object.hash(runtimeType, containerColorRole, contentColorRole);

  static const normal = ExtendedColorPairing.from(
    containerColorRole: .color,
    contentColorRole: .onColor,
  );

  static const container = ExtendedColorPairing.from(
    containerColorRole: .colorContainer,
    contentColorRole: .onColorContainer,
  );

  static const normalOnFixed = ExtendedColorPairing.from(
    containerColorRole: .colorFixed,
    contentColorRole: .onColorFixed,
  );

  static const normalOnFixedDim = ExtendedColorPairing.from(
    containerColorRole: .colorFixedDim,
    contentColorRole: .onColorFixed,
  );

  static const variantOnFixed = ExtendedColorPairing.from(
    containerColorRole: .colorFixed,
    contentColorRole: .onColorFixedVariant,
  );

  static const variantOnFixedDim = ExtendedColorPairing.from(
    containerColorRole: .colorFixedDim,
    contentColorRole: .onColorFixedVariant,
  );
}

abstract class ExtendedColor with Diagnosticable {
  const ExtendedColor();

  const factory ExtendedColor.from({
    required Color color,
    required Color onColor,
    required Color colorContainer,
    required Color onColorContainer,
    required Color colorFixed,
    required Color colorFixedDim,
    required Color onColorFixed,
    required Color onColorFixedVariant,
  }) = _ExtendedColor;

  factory ExtendedColor.fromDynamicScheme(
    DynamicScheme scheme, {
    ExtendedColorPalette palette = .primary,
  }) => switch (palette) {
    .primary => .from(
      color: Color(scheme.primary),
      onColor: Color(scheme.onPrimary),
      colorContainer: Color(scheme.primaryContainer),
      onColorContainer: Color(scheme.onPrimaryContainer),
      colorFixed: Color(scheme.primaryFixed),
      colorFixedDim: Color(scheme.primaryFixedDim),
      onColorFixed: Color(scheme.onPrimaryFixed),
      onColorFixedVariant: Color(scheme.onPrimaryFixedVariant),
    ),
    .secondary => .from(
      color: Color(scheme.secondary),
      onColor: Color(scheme.onSecondary),
      colorContainer: Color(scheme.secondaryContainer),
      onColorContainer: Color(scheme.onSecondaryContainer),
      colorFixed: Color(scheme.secondaryFixed),
      colorFixedDim: Color(scheme.secondaryFixedDim),
      onColorFixed: Color(scheme.onSecondaryFixed),
      onColorFixedVariant: Color(scheme.onSecondaryFixedVariant),
    ),
    .tertiary => .from(
      color: Color(scheme.tertiary),
      onColor: Color(scheme.onTertiary),
      colorContainer: Color(scheme.tertiaryContainer),
      onColorContainer: Color(scheme.onTertiaryContainer),
      colorFixed: Color(scheme.tertiaryFixed),
      colorFixedDim: Color(scheme.tertiaryFixedDim),
      onColorFixed: Color(scheme.onTertiaryFixed),
      onColorFixedVariant: Color(scheme.onTertiaryFixedVariant),
    ),
  };

  factory ExtendedColor.fromSeed({
    required Color sourceColor,
    DynamicSchemeVariant variant = .tonalSpot,
    required Brightness brightness,
    DynamicSchemePlatform platform = DynamicScheme.defaultPlatform,
    double contrastLevel = 0.0,
    DynamicSchemeSpecVersion? specVersion = DynamicScheme.defaultSpecVersion,
    Color? primaryPaletteKeyColor,
    Color? secondaryPaletteKeyColor,
    Color? tertiaryPaletteKeyColor,
    Color? neutralPaletteKeyColor,
    Color? neutralVariantPaletteKeyColor,
    Color? errorPaletteKeyColor,
    ExtendedColorPalette palette = .primary,
  }) => .fromDynamicScheme(
    .fromPalettesOrKeyColors(
      sourceColorHct: sourceColor._toHct(),
      variant: variant._toVariant(),
      isDark: brightness == .dark, // Always exhaustive
      platform: platform,
      contrastLevel: contrastLevel,
      specVersion: specVersion,
      primaryPaletteKeyColor: primaryPaletteKeyColor?._toHct(),
      secondaryPaletteKeyColor: secondaryPaletteKeyColor?._toHct(),
      tertiaryPaletteKeyColor: tertiaryPaletteKeyColor?._toHct(),
      neutralPaletteKeyColor: neutralPaletteKeyColor?._toHct(),
      neutralVariantPaletteKeyColor: neutralVariantPaletteKeyColor?._toHct(),
      errorPaletteKeyColor: errorPaletteKeyColor?._toHct(),
    ),
    palette: palette,
  );

  factory ExtendedColor.fromColorTheme(
    ColorThemeData colorTheme, {
    ExtendedColorPalette palette = .primary,
  }) => switch (palette) {
    .primary => .from(
      color: colorTheme.primary,
      onColor: colorTheme.onPrimary,
      colorContainer: colorTheme.primaryContainer,
      onColorContainer: colorTheme.onPrimaryContainer,
      colorFixed: colorTheme.primaryFixed,
      colorFixedDim: colorTheme.primaryFixedDim,
      onColorFixed: colorTheme.onPrimaryFixed,
      onColorFixedVariant: colorTheme.onPrimaryFixedVariant,
    ),
    .secondary => .from(
      color: colorTheme.secondary,
      onColor: colorTheme.onSecondary,
      colorContainer: colorTheme.secondaryContainer,
      onColorContainer: colorTheme.onSecondaryContainer,
      colorFixed: colorTheme.secondaryFixed,
      colorFixedDim: colorTheme.secondaryFixedDim,
      onColorFixed: colorTheme.onSecondaryFixed,
      onColorFixedVariant: colorTheme.onSecondaryFixedVariant,
    ),
    .tertiary => .from(
      color: colorTheme.tertiary,
      onColor: colorTheme.onTertiary,
      colorContainer: colorTheme.tertiaryContainer,
      onColorContainer: colorTheme.onTertiaryContainer,
      colorFixed: colorTheme.tertiaryFixed,
      colorFixedDim: colorTheme.tertiaryFixedDim,
      onColorFixed: colorTheme.onTertiaryFixed,
      onColorFixedVariant: colorTheme.onTertiaryFixedVariant,
    ),
  };

  Color get color;

  Color get onColor;

  Color get colorContainer;

  Color get onColorContainer;

  Color get colorFixed;

  Color get colorFixedDim;

  Color get onColorFixed;

  Color get onColorFixedVariant;

  ExtendedColor copyWith({
    Color? color,
    Color? onColor,
    Color? colorContainer,
    Color? onColorContainer,
    Color? colorFixed,
    Color? colorFixedDim,
    Color? onColorFixed,
    Color? onColorFixedVariant,
  }) =>
      color != null ||
          onColor != null ||
          colorContainer != null ||
          onColorContainer != null ||
          colorFixed != null ||
          colorFixedDim != null ||
          onColorFixed != null ||
          onColorFixedVariant != null
      ? .from(
          color: color ?? this.color,
          onColor: onColor ?? this.onColor,
          colorContainer: colorContainer ?? this.colorContainer,
          onColorContainer: onColorContainer ?? this.onColorContainer,
          colorFixed: colorFixed ?? this.colorFixed,
          colorFixedDim: colorFixedDim ?? this.colorFixedDim,
          onColorFixed: onColorFixed ?? this.onColorFixed,
          onColorFixedVariant: onColorFixedVariant ?? this.onColorFixedVariant,
        )
      : this;

  ExtendedColor harmonizeWith(Color sourceColor) => copyWith(
    color: color._harmonizeWith(sourceColor),
    onColor: onColor._harmonizeWith(sourceColor),
    colorContainer: colorContainer._harmonizeWith(sourceColor),
    onColorContainer: onColorContainer._harmonizeWith(sourceColor),
    colorFixed: colorFixed._harmonizeWith(sourceColor),
    colorFixedDim: colorFixedDim._harmonizeWith(sourceColor),
    onColorFixed: onColorFixed._harmonizeWith(sourceColor),
    onColorFixedVariant: onColorFixedVariant._harmonizeWith(sourceColor),
  );

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(ColorProperty("color", color))
      ..add(ColorProperty("onColor", onColor))
      ..add(ColorProperty("colorContainer", colorContainer))
      ..add(ColorProperty("onColorContainer", onColorContainer))
      ..add(ColorProperty("colorFixed", colorFixed))
      ..add(ColorProperty("colorFixedDim", colorFixedDim))
      ..add(ColorProperty("onColorFixed", onColorFixed))
      ..add(ColorProperty("onColorFixedVariant", onColorFixedVariant));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ExtendedColor &&
          color == other.color &&
          onColor == other.onColor &&
          colorContainer == other.colorContainer &&
          onColorContainer == other.onColorContainer &&
          colorFixed == other.colorFixed &&
          colorFixedDim == other.colorFixedDim &&
          onColorFixed == other.onColorFixed &&
          onColorFixedVariant == other.onColorFixedVariant;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    color,
    onColor,
    colorContainer,
    onColorContainer,
    colorFixed,
    colorFixedDim,
    onColorFixed,
    onColorFixedVariant,
  );
}

class _ExtendedColor extends ExtendedColor {
  const _ExtendedColor({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
    required this.colorFixed,
    required this.colorFixedDim,
    required this.onColorFixed,
    required this.onColorFixedVariant,
  });

  @override
  final Color color;

  @override
  final Color onColor;

  @override
  final Color colorContainer;

  @override
  final Color onColorContainer;

  @override
  final Color colorFixed;

  @override
  final Color colorFixedDim;

  @override
  final Color onColorFixed;

  @override
  final Color onColorFixedVariant;
}

abstract class StaticColorsData with Diagnosticable {
  const StaticColorsData();

  const factory StaticColorsData.from({
    required ExtendedColor blue,
    required ExtendedColor yellow,
    required ExtendedColor red,
    required ExtendedColor purple,
    required ExtendedColor cyan,
    required ExtendedColor green,
    required ExtendedColor orange,
    required ExtendedColor pink,
  }) = _StaticColorsData.from;

  factory StaticColorsData.fallback({
    DynamicSchemeVariant variant = .tonalSpot,
    required Brightness brightness,
    DynamicSchemePlatform platform = DynamicScheme.defaultPlatform,
    double contrastLevel = 0.0,
    DynamicSchemeSpecVersion? specVersion = DynamicScheme.defaultSpecVersion,
  }) {
    const palette = StaticPaletteThemeData.fallback();
    return .from(
      blue: .fromSeed(
        sourceColor: palette.blue50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
      yellow: .fromSeed(
        sourceColor: palette.yellow50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
      red: .fromSeed(
        sourceColor: palette.red50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
      purple: .fromSeed(
        sourceColor: palette.purple50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
      cyan: .fromSeed(
        sourceColor: palette.cyan50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
      green: .fromSeed(
        sourceColor: palette.green50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
      orange: .fromSeed(
        sourceColor: palette.orange50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
      pink: .fromSeed(
        sourceColor: palette.pink50,
        variant: variant,
        brightness: brightness,
        platform: platform,
        contrastLevel: contrastLevel,
        specVersion: specVersion,
        palette: .primary,
      ),
    );
  }

  ExtendedColor get blue;
  ExtendedColor get yellow;
  ExtendedColor get red;
  ExtendedColor get purple;
  ExtendedColor get cyan;
  ExtendedColor get green;
  ExtendedColor get orange;
  ExtendedColor get pink;

  StaticColorsData copyWith({
    ExtendedColor? blue,
    ExtendedColor? yellow,
    ExtendedColor? red,
    ExtendedColor? purple,
    ExtendedColor? cyan,
    ExtendedColor? green,
    ExtendedColor? orange,
    ExtendedColor? pink,
  }) =>
      blue != null ||
          yellow != null ||
          red != null ||
          purple != null ||
          cyan != null ||
          green != null ||
          orange != null ||
          pink != null
      ? .from(
          blue: blue ?? this.blue,
          yellow: yellow ?? this.yellow,
          red: red ?? this.red,
          purple: purple ?? this.purple,
          cyan: cyan ?? this.cyan,
          green: green ?? this.green,
          orange: orange ?? this.orange,
          pink: pink ?? this.pink,
        )
      : this;

  StaticColorsData harmonizeWith(Color sourceColor) => copyWith(
    blue: blue.harmonizeWith(sourceColor),
    yellow: yellow.harmonizeWith(sourceColor),
    red: red.harmonizeWith(sourceColor),
    purple: purple.harmonizeWith(sourceColor),
    cyan: cyan.harmonizeWith(sourceColor),
    green: green.harmonizeWith(sourceColor),
    orange: orange.harmonizeWith(sourceColor),
    pink: pink.harmonizeWith(sourceColor),
  );

  StaticColorsData harmonizeWithPrimary(ColorThemeDataPartial colorTheme) {
    final sourceColor = colorTheme.primary;
    return sourceColor != null ? harmonizeWith(sourceColor) : this;
  }

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<ExtendedColor>("blue", blue))
      ..add(DiagnosticsProperty<ExtendedColor>("yellow", yellow))
      ..add(DiagnosticsProperty<ExtendedColor>("red", red))
      ..add(DiagnosticsProperty<ExtendedColor>("purple", purple))
      ..add(DiagnosticsProperty<ExtendedColor>("cyan", cyan))
      ..add(DiagnosticsProperty<ExtendedColor>("green", green))
      ..add(DiagnosticsProperty<ExtendedColor>("orange", orange))
      ..add(DiagnosticsProperty<ExtendedColor>("pink", pink));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is StaticColorsData &&
          blue == other.blue &&
          yellow == other.yellow &&
          red == other.red &&
          purple == other.purple &&
          cyan == other.cyan &&
          green == other.green &&
          orange == other.orange &&
          pink == other.pink;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    blue,
    yellow,
    red,
    purple,
    cyan,
    green,
    orange,
    pink,
  );
}

class _StaticColorsData extends StaticColorsData {
  const _StaticColorsData.from({
    required this.blue,
    required this.yellow,
    required this.red,
    required this.purple,
    required this.cyan,
    required this.green,
    required this.orange,
    required this.pink,
  });

  @override
  final ExtendedColor blue;

  @override
  final ExtendedColor yellow;

  @override
  final ExtendedColor red;

  @override
  final ExtendedColor purple;

  @override
  final ExtendedColor cyan;

  @override
  final ExtendedColor green;

  @override
  final ExtendedColor orange;

  @override
  final ExtendedColor pink;
}

class StaticColors extends InheritedTheme {
  const StaticColors({super.key, required this.data, required super.child});

  final StaticColorsData data;

  @override
  bool updateShouldNotify(StaticColors oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      StaticColors(data: data, child: child);

  static StaticColorsData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StaticColors>()?.data;

  static StaticColorsData of(BuildContext context) {
    final result = maybeOf(context);
    if (result != null) return result;
    final colorTheme = ColorTheme.of(context);
    final highContarst = MediaQuery.highContrastOf(context);
    return .fallback(
      brightness: colorTheme.brightness,
      contrastLevel: highContarst ? 1.0 : 0.0,
      platform: .phone,
      variant: .tonalSpot,
      specVersion: .spec2025,
    ).harmonizeWith(colorTheme.primary);
  }
}

// TODO(deminearchiver): return success (4E7D4D) and warning (FFC107) semantic colors

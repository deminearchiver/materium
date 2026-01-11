import 'package:material/material_color_utilities.dart';
import 'package:materium/flutter.dart';

extension on DynamicSchemeVariant {
  Variant get _asVariant => switch (this) {
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

  static const normalInverse = ExtendedColorPairing.from(
    containerColorRole: .onColor,
    contentColorRole: .color,
  );

  static const container = ExtendedColorPairing.from(
    containerColorRole: .colorContainer,
    contentColorRole: .onColorContainer,
  );

  static const containerInverse = ExtendedColorPairing.from(
    containerColorRole: .onColorContainer,
    contentColorRole: .colorContainer,
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
      variant: variant._asVariant,
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

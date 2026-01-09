// Open fonts (bundled as assets or available as system fonts)
import 'package:materium/flutter.dart';

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

// Open fonts (bundled as assets or available as system fonts)
import 'package:materium/flutter.dart';

const _roboto = "Roboto";
const _firaCode = FontFamily.firaCode;
const _googleSans = FontFamily.googleSans;
const _googleSansCode = FontFamily.googleSansCode;
const _googleSansFlex = FontFamily.googleSansFlex;
const _monaspaceArgon = FontFamily.monaspaceArgon;
const _robotoFlex = FontFamily.robotoFlex;

abstract class TypographyThemeDataPartial with Diagnosticable {
  const TypographyThemeDataPartial();

  const factory TypographyThemeDataPartial.from({
    TypefaceThemeDataPartial? typeface,
    TypescaleThemeDataPartial? typescale,
  }) = _TypographyThemeDataPartial;

  TypefaceThemeDataPartial? get typeface;

  TypescaleThemeDataPartial? get typescale;

  TypographyThemeDataPartial copyWith({
    covariant TypefaceThemeDataPartial? typeface,
    covariant TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? .from(
          typeface: typeface ?? this.typeface,
          typescale: typescale ?? this.typescale,
        )
      : this;

  TypographyThemeDataPartial mergeWith({
    TypefaceThemeDataPartial? typeface,
    TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? .from(
          typeface: this.typeface?.merge(typeface) ?? typeface,
          typescale: this.typescale?.merge(typescale) ?? typescale,
        )
      : this;

  TypographyThemeDataPartial merge(TypographyThemeDataPartial? other) =>
      other != null
      ? mergeWith(typeface: other.typeface, typescale: other.typescale)
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(
        DiagnosticsProperty<TypefaceThemeDataPartial>(
          "typeface",
          typeface,
          defaultValue: null,
        ),
      )
      ..add(
        DiagnosticsProperty<TypescaleThemeDataPartial>(
          "typescale",
          typescale,
          defaultValue: null,
        ),
      );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is TypographyThemeDataPartial &&
          typeface == other.typeface &&
          typescale == other.typescale;

  @override
  int get hashCode => Object.hash(runtimeType, typeface, typescale);

  /// A Material 3 Expressive type scale which uses Roboto Flex.
  static const material3Expressive2025 = TypographyThemeDataPartial.from(
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
  static const material3Expressive2026 = TypographyThemeDataPartial.from(
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

class _TypographyThemeDataPartial extends TypographyThemeDataPartial {
  const _TypographyThemeDataPartial({this.typeface, this.typescale});

  @override
  final TypefaceThemeDataPartial? typeface;

  @override
  final TypescaleThemeDataPartial? typescale;
}

abstract class TypographyThemeData extends TypographyThemeDataPartial {
  const TypographyThemeData();

  const factory TypographyThemeData.from({
    required TypefaceThemeData typeface,
    required TypescaleThemeData typescale,
  }) = _TypographyThemeData;

  @override
  TypefaceThemeData get typeface;

  @override
  TypescaleThemeData get typescale;

  @override
  TypographyThemeData copyWith({
    covariant TypefaceThemeData? typeface,
    covariant TypescaleThemeData? typescale,
  }) => typeface != null || typescale != null
      ? .from(
          typeface: typeface ?? this.typeface,
          typescale: typescale ?? this.typescale,
        )
      : this;

  @override
  TypographyThemeData mergeWith({
    TypefaceThemeDataPartial? typeface,
    TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? .from(
          typeface: this.typeface.merge(typeface),
          typescale: this.typescale.merge(typescale),
        )
      : this;

  @override
  TypographyThemeData merge(TypographyThemeDataPartial? other) => other != null
      ? mergeWith(typeface: other.typeface, typescale: other.typescale)
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty<TypefaceThemeData>("typeface", typeface))
      ..add(DiagnosticsProperty<TypescaleThemeData>("typescale", typescale));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is TypographyThemeData &&
          typeface == other.typeface &&
          typescale == other.typescale;

  @override
  int get hashCode => Object.hash(runtimeType, typeface, typescale);
}

class _TypographyThemeData extends TypographyThemeData {
  const _TypographyThemeData({required this.typeface, required this.typescale});

  @override
  final TypefaceThemeData typeface;

  @override
  final TypescaleThemeData typescale;
}

class TypographyTheme extends StatelessWidget implements ProxyWidget {
  const TypographyTheme({super.key, required this.data, required this.child});

  final TypographyThemeData data;

  @override
  final Widget child;

  @override
  Widget build(BuildContext context) => TypefaceTheme(
    data: data.typeface,
    child: TypescaleTheme(data: data.typescale, child: child),
  );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TypographyThemeData>("data", data));
  }

  static Widget merge({
    Key? key,
    required TypographyThemeDataPartial data,
    required Widget child,
  }) => Builder(
    builder: (context) =>
        TypographyTheme(key: key, data: of(context).merge(data), child: child),
  );

  static TypographyThemeData? maybeOf(BuildContext context) {
    final typefaceTheme = TypefaceTheme.maybeOf(context);
    final typescaleTheme = TypescaleTheme.maybeOf(context);
    return typefaceTheme != null && typescaleTheme != null
        ? .from(typeface: typefaceTheme, typescale: typescaleTheme)
        : null;
  }

  static TypographyThemeData of(BuildContext context) => .from(
    typeface: TypefaceTheme.of(context),
    typescale: TypescaleTheme.of(context),
  );
}

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
      ? .from(
          typeface: typeface ?? this.typeface,
          typescale: typescale ?? this.typescale,
        )
      : this;

  TypographyDefaults mergeWith({
    TypefaceThemeDataPartial? typeface,
    TypescaleThemeDataPartial? typescale,
  }) => typeface != null || typescale != null
      ? .from(
          typeface: this.typeface.merge(typeface),
          typescale: this.typescale.merge(typescale),
        )
      : this;

  TypographyDefaults merge(TypographyDefaults? other) => other != null
      ? mergeWith(typeface: other.typeface, typescale: other.typescale)
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
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

/// A widget that provides localized text geometry to its descendants.
class DefaultTextGeometry extends StatelessWidget implements ProxyWidget {
  const DefaultTextGeometry({
    super.key,
    this.scriptCategory,
    required this.style,
    required this.child,
  });

  /// The [ScriptCategory] used to determine the geometric properties of the
  /// text.
  ///
  /// If this is null, the value is fetched from the nearest
  /// [MaterialLocalizations] ancestor delegate. If no [MaterialLocalizations]
  /// are found, it defaults to [ScriptCategory.englishLike].
  final ScriptCategory? scriptCategory;

  /// Default [TextStyle] to use.
  ///
  /// Geometry defaults will be provided for this text style.
  final TextStyle style;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  @override
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scriptCategory = this.scriptCategory;
    final resolvedStyle = scriptCategory != null
        ? geometryStyleFor(scriptCategory)
        : geometryStyleOf(context);
    return DefaultTextStyle.merge(style: resolvedStyle, child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        EnumProperty<ScriptCategory>(
          "scriptCategory",
          scriptCategory,
          defaultValue: null,
        ),
      )
      ..add(DiagnosticsProperty<TextStyle>("style", style));
  }

  /// Defines text geometry for `ScriptCategory.englishLike` scripts, such as
  /// English, French, Russian, etc.
  static const englishLike = TextStyle(
    debugLabel: "englishLike default 2021",
    inherit: true,
    decoration: .none,
    textBaseline: .alphabetic,
    leadingDistribution: .even,
  );

  /// Defines text geometry for dense scripts, such as Chinese, Japanese
  /// and Korean.
  static const dense = TextStyle(
    debugLabel: "dense default 2021",
    inherit: true,
    decoration: .none,
    textBaseline: .ideographic,
    leadingDistribution: .even,
  );

  /// Defines text geometry for tall scripts, such as Farsi, Hindi, and Thai.
  static const tall = TextStyle(
    debugLabel: "tall default 2021",
    inherit: true,
    decoration: .none,
    textBaseline: .alphabetic,
    leadingDistribution: .even,
  );

  /// Returns the [TextStyle] containing geometric defaults for the
  /// specified [scriptCategory].
  static TextStyle geometryStyleFor(ScriptCategory scriptCategory) =>
      switch (scriptCategory) {
        .englishLike => englishLike,
        .dense => dense,
        .tall => tall,
      };

  /// Returns the [ScriptCategory] from the closest [MaterialLocalizations]
  /// ancestor delegate, or `null` if none is found.
  static ScriptCategory? maybeScriptCategoryOf(BuildContext context) =>
      Localizations.of<MaterialLocalizations>(
        context,
        MaterialLocalizations,
      )?.scriptCategory;

  /// Returns the [ScriptCategory] from the closest [MaterialLocalizations]
  /// ancestor delegate, defaulting to [.englishLike] if none is found.
  static ScriptCategory scriptCategoryOf(BuildContext context) =>
      maybeScriptCategoryOf(context) ?? .englishLike;

  /// Returns the geometric [TextStyle] for the ambient [ScriptCategory],
  /// or `null` if no [MaterialLocalizations] are found.
  static TextStyle? maybeGeometryStyleOf(BuildContext context) {
    final scriptCategory = maybeScriptCategoryOf(context);
    return scriptCategory != null ? geometryStyleFor(scriptCategory) : null;
  }

  /// Returns the geometric [TextStyle] for the ambient [ScriptCategory].
  ///
  /// Defaults to [englishLike] if no [MaterialLocalizations] ancestor delegate
  /// exists.
  static TextStyle geometryStyleOf(BuildContext context) =>
      geometryStyleFor(scriptCategoryOf(context));
}

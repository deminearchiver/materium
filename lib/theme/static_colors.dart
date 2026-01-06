import 'package:material/material_color_utilities.dart';
import 'package:materium/flutter.dart';

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

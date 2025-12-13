import 'package:material/src/material/flutter.dart';
import 'package:flutter/material.dart' as flutter;

typedef IconThemeLegacy = flutter.IconTheme;
typedef IconThemeDataLegacy = flutter.IconThemeData;

@immutable
abstract class IconThemeDataPartial with Diagnosticable {
  const IconThemeDataPartial();

  const factory IconThemeDataPartial.from({
    Color? color,
    double? size,
    double? weight,
    double? grade,
    double? opticalSize,
    double? fill,
  }) = _IconThemeDataPartial;

  Color? get color;

  double? get size;

  double? get weight;

  double? get grade;

  double? get opticalSize;

  double? get fill;

  IconThemeDataPartial copyWith({
    Color? color,
    double? size,
    double? weight,
    double? grade,
    double? opticalSize,
    double? fill,
  }) =>
      color != null ||
          size != null ||
          weight != null ||
          grade != null ||
          opticalSize != null ||
          fill != null
      ? .from(
          color: color ?? this.color,
          size: size ?? this.size,
          weight: weight ?? this.weight,
          grade: grade ?? this.grade,
          opticalSize: opticalSize ?? this.opticalSize,
          fill: fill ?? this.fill,
        )
      : this;

  IconThemeDataPartial merge(IconThemeDataPartial? other) => other != null
      ? copyWith(
          color: other.color,
          size: other.size,
          weight: other.weight,
          grade: other.grade,
          opticalSize: other.opticalSize,
          fill: other.fill,
        )
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(ColorProperty("color", color, defaultValue: null))
      ..add(DoubleProperty("size", size, defaultValue: null))
      ..add(DoubleProperty("weight", weight, defaultValue: null))
      ..add(DoubleProperty("grade", grade, defaultValue: null))
      ..add(DoubleProperty("opticalSize", opticalSize, defaultValue: null))
      ..add(DoubleProperty("fill", fill, defaultValue: null));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is IconThemeDataPartial &&
          color == other.color &&
          size == other.size &&
          weight == other.weight &&
          grade == other.grade &&
          opticalSize == other.opticalSize &&
          fill == other.fill;

  @override
  int get hashCode =>
      Object.hash(runtimeType, color, size, weight, grade, opticalSize, fill);
}

@immutable
class _IconThemeDataPartial extends IconThemeDataPartial {
  const _IconThemeDataPartial({
    this.color,
    this.size,
    this.weight,
    this.grade,
    this.opticalSize,
    this.fill,
  });

  @override
  final Color? color;

  @override
  final double? size;

  @override
  final double? weight;

  @override
  final double? grade;

  @override
  final double? opticalSize;

  @override
  final double? fill;
}

@immutable
abstract class IconThemeData extends IconThemeDataPartial {
  const IconThemeData();

  const factory IconThemeData.from({
    required Color color,
    required double size,
    required double weight,
    required double grade,
    required double opticalSize,
    required double fill,
  }) = _IconThemeData;

  @override
  Color get color;

  @override
  double get size;

  @override
  double get weight;

  @override
  double get grade;

  @override
  double get opticalSize;

  @override
  double get fill;

  @override
  IconThemeData copyWith({
    Color? color,
    double? size,
    double? weight,
    double? grade,
    double? opticalSize,
    double? fill,
  }) =>
      color != null ||
          size != null ||
          weight != null ||
          grade != null ||
          opticalSize != null ||
          fill != null
      ? IconThemeData.from(
          color: color ?? this.color,
          size: size ?? this.size,
          weight: weight ?? this.weight,
          grade: grade ?? this.grade,
          opticalSize: opticalSize ?? this.opticalSize,
          fill: fill ?? this.fill,
        )
      : this;

  @override
  IconThemeData merge(IconThemeDataPartial? other) => other != null
      ? copyWith(
          color: other.color,
          size: other.size,
          weight: other.weight,
          grade: other.grade,
          opticalSize: other.opticalSize,
          fill: other.fill,
        )
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(ColorProperty("color", color))
      ..add(DoubleProperty("size", size))
      ..add(DoubleProperty("weight", weight))
      ..add(DoubleProperty("grade", grade))
      ..add(DoubleProperty("opticalSize", opticalSize))
      ..add(DoubleProperty("fill", fill));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is IconThemeData &&
          color == other.color &&
          size == other.size &&
          weight == other.weight &&
          grade == other.grade &&
          opticalSize == other.opticalSize &&
          fill == other.fill;

  @override
  int get hashCode =>
      Object.hash(runtimeType, color, size, weight, grade, opticalSize, fill);
}

@immutable
class _IconThemeData extends IconThemeData {
  const _IconThemeData({
    required this.color,
    required this.size,
    required this.weight,
    required this.grade,
    required this.opticalSize,
    required this.fill,
  });

  @override
  final Color color;

  @override
  final double size;

  @override
  final double weight;

  @override
  final double grade;

  @override
  final double opticalSize;

  @override
  final double fill;
}

class _IconThemeDataFallback extends IconThemeData {
  const _IconThemeDataFallback({required ColorThemeData colorTheme})
    : _colorTheme = colorTheme,
      size = 24.0,
      weight = 400.0,
      grade = 0.0,
      opticalSize = 24.0,
      fill = 0.0;

  final ColorThemeData _colorTheme;

  @override
  Color get color => _colorTheme.onSurface;

  @override
  final double size;

  @override
  final double weight;

  @override
  final double grade;

  @override
  final double opticalSize;

  @override
  final double fill;
}

@immutable
class IconTheme extends InheritedTheme {
  const IconTheme({super.key, required this.data, required super.child});

  final IconThemeData data;

  @override
  bool updateShouldNotify(IconTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      IconTheme(data: data, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<IconThemeData>("data", data));
  }

  static Widget merge({
    Key? key,
    required IconThemeDataPartial data,
    required Widget child,
  }) => Builder(
    builder: (context) =>
        IconTheme(key: key, data: of(context).merge(data), child: child),
  );

  static IconThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<IconTheme>()?.data;

  static IconThemeData of(BuildContext context) {
    final result = maybeOf(context);
    if (result != null) return result;
    final colorTheme = ColorTheme.of(context);
    return _IconThemeDataFallback(colorTheme: colorTheme);
  }
}

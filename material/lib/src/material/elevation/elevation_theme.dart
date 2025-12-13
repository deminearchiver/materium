import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

@immutable
abstract class ElevationThemeDataPartial with Diagnosticable {
  const ElevationThemeDataPartial();

  const factory ElevationThemeDataPartial.from({
    double? level0,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
    double? level5,
  }) = _ElevationThemeDataPartial.from;

  /// `md.sys.elevation.level0`
  double? get level0;

  /// `md.sys.elevation.level1`
  double? get level1;

  /// `md.sys.elevation.level2`
  double? get level2;

  /// `md.sys.elevation.level3`
  double? get level3;

  /// `md.sys.elevation.level4`
  double? get level4;

  /// `md.sys.elevation.level5`
  double? get level5;

  ElevationThemeDataPartial copyWith({
    double? level0,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
    double? level5,
  }) =>
      level0 != null ||
          level1 != null ||
          level2 != null ||
          level3 != null ||
          level4 != null ||
          level5 != null
      ? .from(
          level0: level0 ?? this.level0,
          level1: level1 ?? this.level1,
          level2: level2 ?? this.level2,
          level3: level3 ?? this.level3,
          level4: level4 ?? this.level4,
          level5: level5 ?? this.level5,
        )
      : this;

  ElevationThemeDataPartial merge(ElevationThemeDataPartial? other) =>
      other != null
      ? copyWith(
          level0: other.level0,
          level1: other.level1,
          level2: other.level2,
          level3: other.level3,
          level4: other.level4,
          level5: other.level5,
        )
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DoubleProperty("level0", level0, defaultValue: null))
      ..add(DoubleProperty("level1", level1, defaultValue: null))
      ..add(DoubleProperty("level2", level2, defaultValue: null))
      ..add(DoubleProperty("level3", level3, defaultValue: null))
      ..add(DoubleProperty("level4", level4, defaultValue: null))
      ..add(DoubleProperty("level5", level5, defaultValue: null));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ElevationThemeDataPartial &&
          level0 == other.level0 &&
          level1 == other.level1 &&
          level2 == other.level2 &&
          level3 == other.level3 &&
          level4 == other.level4 &&
          level5 == other.level5;

  @override
  int get hashCode =>
      Object.hash(runtimeType, level0, level1, level2, level3, level4, level5);
}

@immutable
class _ElevationThemeDataPartial extends ElevationThemeDataPartial {
  const _ElevationThemeDataPartial.from({
    this.level0,
    this.level1,
    this.level2,
    this.level3,
    this.level4,
    this.level5,
  });

  @override
  final double? level0;

  @override
  final double? level1;

  @override
  final double? level2;

  @override
  final double? level3;

  @override
  final double? level4;

  @override
  final double? level5;
}

@immutable
abstract class ElevationThemeData extends ElevationThemeDataPartial {
  const ElevationThemeData();

  const factory ElevationThemeData.from({
    required double level0,
    required double level1,
    required double level2,
    required double level3,
    required double level4,
    required double level5,
  }) = _ElevationThemeData;

  const factory ElevationThemeData.fallback() = _ElevationThemeData.fallback;

  @override
  double get level0;

  @override
  double get level1;

  @override
  double get level2;

  @override
  double get level3;

  @override
  double get level4;

  @override
  double get level5;

  @override
  ElevationThemeData copyWith({
    double? level0,
    double? level1,
    double? level2,
    double? level3,
    double? level4,
    double? level5,
  }) =>
      level0 != null ||
          level1 != null ||
          level2 != null ||
          level3 != null ||
          level4 != null ||
          level5 != null
      ? .from(
          level0: level0 ?? this.level0,
          level1: level1 ?? this.level1,
          level2: level2 ?? this.level2,
          level3: level3 ?? this.level3,
          level4: level4 ?? this.level4,
          level5: level5 ?? this.level5,
        )
      : this;

  @override
  ElevationThemeData merge(ElevationThemeDataPartial? other) => other != null
      ? copyWith(
          level0: other.level0,
          level1: other.level1,
          level2: other.level2,
          level3: other.level3,
          level4: other.level4,
          level5: other.level5,
        )
      : this;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DoubleProperty("level0", level0))
      ..add(DoubleProperty("level1", level1))
      ..add(DoubleProperty("level2", level2))
      ..add(DoubleProperty("level3", level3))
      ..add(DoubleProperty("level4", level4))
      ..add(DoubleProperty("level5", level5));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ElevationThemeData &&
          level0 == other.level0 &&
          level1 == other.level1 &&
          level2 == other.level2 &&
          level3 == other.level3 &&
          level4 == other.level4 &&
          level5 == other.level5;

  @override
  int get hashCode =>
      Object.hash(runtimeType, level0, level1, level2, level3, level4, level5);
}

@immutable
class _ElevationThemeData extends ElevationThemeData {
  const _ElevationThemeData({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });

  const _ElevationThemeData.fallback()
    : level0 = 0.0,
      level1 = 1.0,
      level2 = 3.0,
      level3 = 6.0,
      level4 = 9.0,
      level5 = 12.0;

  @override
  final double level0;

  @override
  final double level1;

  @override
  final double level2;

  @override
  final double level3;

  @override
  final double level4;

  @override
  final double level5;
}

@immutable
class ElevationTheme extends InheritedTheme {
  const ElevationTheme({super.key, required this.data, required super.child});

  final ElevationThemeData data;

  @override
  bool updateShouldNotify(ElevationTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      ElevationTheme(data: data, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ElevationThemeData>("data", data));
  }

  static Widget merge({
    Key? key,
    required ElevationThemeDataPartial data,
    required Widget child,
  }) => Builder(
    builder: (context) =>
        ElevationTheme(key: key, data: of(context).merge(data), child: child),
  );

  static ElevationThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ElevationTheme>()?.data;

  static ElevationThemeData of(BuildContext context) =>
      maybeOf(context) ?? const ElevationThemeData.fallback();
}

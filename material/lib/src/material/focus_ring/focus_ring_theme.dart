import 'package:material/src/material/flutter.dart';

abstract class FocusRingThemeDataPartial {
  const FocusRingThemeDataPartial();

  const factory FocusRingThemeDataPartial.from({
    double? activeWidth,
    Color? color,
    Duration? duration,
    double? inwardOffset,
    double? outwardOffset,
    CornersGeometry? shape,
    double? width,
  }) = _FocusRingThemeDataPartial;

  double? get activeWidth;

  Color? get color;

  Duration? get duration;

  double? get inwardOffset;

  double? get outwardOffset;

  CornersGeometry? get shape;

  double? get width;

  FocusRingThemeDataPartial copyWith({
    double? activeWidth,
    Color? color,
    Duration? duration,
    double? inwardOffset,
    double? outwardOffset,
    CornersGeometry? shape,
    double? width,
  }) =>
      activeWidth != null ||
          color != null ||
          duration != null ||
          inwardOffset != null ||
          outwardOffset != null ||
          shape != null ||
          width != null
      ? .from(
          activeWidth: activeWidth ?? this.activeWidth,
          color: color ?? this.color,
          duration: duration ?? this.duration,
          inwardOffset: inwardOffset ?? this.inwardOffset,
          outwardOffset: outwardOffset ?? this.outwardOffset,
          shape: shape ?? this.shape,
          width: width ?? this.width,
        )
      : this;

  FocusRingThemeDataPartial merge(FocusRingThemeDataPartial? other) =>
      other != null
      ? copyWith(
          activeWidth: other.activeWidth,
          color: other.color,
          duration: other.duration,
          inwardOffset: other.inwardOffset,
          outwardOffset: other.outwardOffset,
          shape: other.shape,
          width: other.width,
        )
      : this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is FocusRingThemeDataPartial &&
          activeWidth == other.activeWidth &&
          color == other.color &&
          duration == other.duration &&
          inwardOffset == other.inwardOffset &&
          outwardOffset == other.outwardOffset &&
          shape == other.shape &&
          width == other.width;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    activeWidth,
    color,
    duration,
    inwardOffset,
    outwardOffset,
    shape,
    width,
  );
}

class _FocusRingThemeDataPartial extends FocusRingThemeDataPartial {
  const _FocusRingThemeDataPartial({
    this.activeWidth,
    this.color,
    this.duration,
    this.inwardOffset,
    this.outwardOffset,
    this.shape,
    this.width,
  });

  @override
  final double? activeWidth;

  @override
  final Color? color;

  @override
  final Duration? duration;

  @override
  final double? inwardOffset;

  @override
  final double? outwardOffset;

  @override
  final CornersGeometry? shape;

  @override
  final double? width;
}

abstract class FocusRingThemeData extends FocusRingThemeDataPartial {
  const FocusRingThemeData();

  const factory FocusRingThemeData.from({
    required double activeWidth,
    required Color color,
    required Duration duration,
    required double inwardOffset,
    required double outwardOffset,
    required CornersGeometry shape,
    required double width,
  }) = _FocusRingThemeData;

  @override
  double get activeWidth;

  @override
  Color get color;

  @override
  Duration get duration;

  @override
  double get inwardOffset;

  @override
  double get outwardOffset;

  @override
  CornersGeometry get shape;

  @override
  double get width;

  @override
  FocusRingThemeData copyWith({
    double? activeWidth,
    Color? color,
    Duration? duration,
    double? inwardOffset,
    double? outwardOffset,
    CornersGeometry? shape,
    double? width,
  }) =>
      activeWidth != null ||
          color != null ||
          duration != null ||
          inwardOffset != null ||
          outwardOffset != null ||
          shape != null ||
          width != null
      ? .from(
          activeWidth: activeWidth ?? this.activeWidth,
          color: color ?? this.color,
          duration: duration ?? this.duration,
          inwardOffset: inwardOffset ?? this.inwardOffset,
          outwardOffset: outwardOffset ?? this.outwardOffset,
          shape: shape ?? this.shape,
          width: width ?? this.width,
        )
      : this;

  @override
  FocusRingThemeData merge(FocusRingThemeDataPartial? other) => other != null
      ? copyWith(
          activeWidth: other.activeWidth,
          color: other.color,
          duration: other.duration,
          inwardOffset: other.inwardOffset,
          outwardOffset: other.outwardOffset,
          shape: other.shape,
          width: other.width,
        )
      : this;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is FocusRingThemeData &&
          activeWidth == other.activeWidth &&
          color == other.color &&
          duration == other.duration &&
          inwardOffset == other.inwardOffset &&
          outwardOffset == other.outwardOffset &&
          shape == other.shape &&
          width == other.width;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    activeWidth,
    color,
    duration,
    inwardOffset,
    outwardOffset,
    shape,
    width,
  );
}

class _FocusRingThemeData extends FocusRingThemeData {
  const _FocusRingThemeData({
    required this.activeWidth,
    required this.color,
    required this.duration,
    required this.inwardOffset,
    required this.outwardOffset,
    required this.shape,
    required this.width,
  });

  @override
  final double activeWidth;

  @override
  final Color color;

  @override
  final Duration duration;

  @override
  final double inwardOffset;

  @override
  final double outwardOffset;

  @override
  final CornersGeometry shape;

  @override
  final double width;
}

class _FocusRingThemeDataFallback extends FocusRingThemeData {
  const _FocusRingThemeDataFallback({
    required ColorThemeData colorTheme,
    required ShapeThemeData shapeTheme,
    required DurationThemeData durationTheme,
  }) : _colorTheme = colorTheme,
       _shapeTheme = shapeTheme,
       _durationTheme = durationTheme;

  final ColorThemeData _colorTheme;
  final ShapeThemeData _shapeTheme;
  final DurationThemeData _durationTheme;

  @override
  double get activeWidth => 8.0;

  @override
  Color get color => _colorTheme.secondary;

  @override
  Duration get duration => _durationTheme.long4;

  @override
  double get inwardOffset => 0.0;

  @override
  double get outwardOffset => 2.0;

  @override
  CornersGeometry get shape => Corners.all(_shapeTheme.corner.full);

  @override
  double get width => 3.0;
}

class FocusRingTheme extends InheritedTheme {
  const FocusRingTheme({super.key, required this.data, required super.child});

  final FocusRingThemeData data;

  @override
  bool updateShouldNotify(FocusRingTheme oldWidget) => data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      FocusRingTheme(data: data, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<FocusRingThemeData>("data", data));
  }

  static Widget merge({
    Key? key,
    required FocusRingThemeDataPartial data,
    required Widget child,
  }) => Builder(
    builder: (context) =>
        FocusRingTheme(key: key, data: of(context).merge(data), child: child),
  );

  static FocusRingThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<FocusRingTheme>()?.data;

  static FocusRingThemeData of(BuildContext context) =>
      maybeOf(context) ??
      _FocusRingThemeDataFallback(
        colorTheme: ColorTheme.of(context),
        shapeTheme: ShapeTheme.of(context),
        durationTheme: DurationTheme.of(context),
      );
}

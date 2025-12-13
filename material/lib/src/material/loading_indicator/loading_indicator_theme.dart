import 'package:material/src/material/flutter.dart';

@immutable
abstract class LoadingIndicatorThemeDataPartial with Diagnosticable {
  const LoadingIndicatorThemeDataPartial();

  const factory LoadingIndicatorThemeDataPartial.from({
    Color? indicatorColor,
    Color? containedContainerColor,
    Color? containedIndicatorColor,
  }) = _LoadingIndicatorThemeDataPartial.from;

  Color? get indicatorColor;

  Color? get containedContainerColor;

  Color? get containedIndicatorColor;

  LoadingIndicatorThemeDataPartial copyWith({
    Color? indicatorColor,
    Color? containedContainerColor,
    Color? containedIndicatorColor,
  }) =>
      indicatorColor != null ||
          containedIndicatorColor != null ||
          containedContainerColor != null
      ? .from(
          indicatorColor: indicatorColor ?? this.indicatorColor,
          containedContainerColor:
              containedContainerColor ?? this.containedContainerColor,
          containedIndicatorColor:
              containedIndicatorColor ?? this.containedIndicatorColor,
        )
      : this;

  LoadingIndicatorThemeDataPartial merge(
    LoadingIndicatorThemeDataPartial? other,
  ) => other != null
      ? copyWith(
          indicatorColor: other.indicatorColor,
          containedContainerColor: other.containedContainerColor,
          containedIndicatorColor: other.containedIndicatorColor,
        )
      : this;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(
        ColorProperty(
          "activeIndicatorColor",
          indicatorColor,
          defaultValue: null,
        ),
      )
      ..add(
        ColorProperty(
          "containedContainerColor",
          containedContainerColor,
          defaultValue: null,
        ),
      )
      ..add(
        ColorProperty(
          "containedIndicatorColor",
          containedIndicatorColor,
          defaultValue: null,
        ),
      );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is LoadingIndicatorThemeDataPartial &&
          indicatorColor == other.indicatorColor &&
          containedContainerColor == other.containedContainerColor &&
          containedIndicatorColor == other.containedIndicatorColor;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    indicatorColor,
    containedContainerColor,
    containedIndicatorColor,
  );

  static LoadingIndicatorThemeDataPartial? lerp(
    LoadingIndicatorThemeDataPartial? a,
    LoadingIndicatorThemeDataPartial? b,
    double t,
  ) {
    if (a == b) return a;
    return .from(
      indicatorColor: Color.lerp(a?.indicatorColor, b?.indicatorColor, t),
      containedContainerColor: Color.lerp(
        a?.containedContainerColor,
        b?.containedContainerColor,
        t,
      ),
      containedIndicatorColor: Color.lerp(
        a?.containedIndicatorColor,
        b?.containedIndicatorColor,
        t,
      ),
    );
  }
}

class _LoadingIndicatorThemeDataPartial
    extends LoadingIndicatorThemeDataPartial {
  const _LoadingIndicatorThemeDataPartial.from({
    this.indicatorColor,
    this.containedContainerColor,
    this.containedIndicatorColor,
  });

  @override
  final Color? indicatorColor;

  @override
  final Color? containedContainerColor;

  @override
  final Color? containedIndicatorColor;
}

@immutable
abstract class LoadingIndicatorThemeData
    extends LoadingIndicatorThemeDataPartial {
  const LoadingIndicatorThemeData();

  const factory LoadingIndicatorThemeData.from({
    required Color indicatorColor,
    required Color containedContainerColor,
    required Color containedIndicatorColor,
  }) = _LoadingIndicatorThemeData.from;

  @override
  Color get indicatorColor;

  @override
  Color get containedContainerColor;

  @override
  Color get containedIndicatorColor;

  @override
  LoadingIndicatorThemeData copyWith({
    Color? indicatorColor,
    Color? containedContainerColor,
    Color? containedIndicatorColor,
  }) =>
      indicatorColor != null ||
          containedContainerColor != null ||
          containedIndicatorColor != null
      ? LoadingIndicatorThemeData.from(
          indicatorColor: indicatorColor ?? this.indicatorColor,
          containedContainerColor:
              containedContainerColor ?? this.containedContainerColor,
          containedIndicatorColor:
              containedIndicatorColor ?? this.containedIndicatorColor,
        )
      : this;

  @override
  LoadingIndicatorThemeData merge(LoadingIndicatorThemeDataPartial? other) =>
      other != null
      ? copyWith(
          indicatorColor: other.indicatorColor,
          containedContainerColor: other.containedContainerColor,
          containedIndicatorColor: other.containedIndicatorColor,
        )
      : this;

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(ColorProperty("activeIndicatorColor", indicatorColor))
      ..add(ColorProperty("containedContainerColor", containedContainerColor))
      ..add(ColorProperty("containedIndicatorColor", containedIndicatorColor));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is LoadingIndicatorThemeData &&
          indicatorColor == other.indicatorColor &&
          containedContainerColor == other.containedContainerColor &&
          containedIndicatorColor == other.containedIndicatorColor;

  @override
  int get hashCode => Object.hash(
    runtimeType,
    indicatorColor,
    containedContainerColor,
    containedIndicatorColor,
  );

  static LoadingIndicatorThemeData lerp(
    LoadingIndicatorThemeData a,
    LoadingIndicatorThemeData b,
    double t,
  ) {
    if (a == b) return a;
    return .from(
      indicatorColor: Color.lerp(a.indicatorColor, b.indicatorColor, t)!,
      containedContainerColor: Color.lerp(
        a.containedContainerColor,
        b.containedContainerColor,
        t,
      )!,
      containedIndicatorColor: Color.lerp(
        a.containedIndicatorColor,
        b.containedIndicatorColor,
        t,
      )!,
    );
  }
}

class _LoadingIndicatorThemeData extends LoadingIndicatorThemeData {
  const _LoadingIndicatorThemeData.from({
    required this.indicatorColor,
    required this.containedIndicatorColor,
    required this.containedContainerColor,
  });

  @override
  final Color indicatorColor;

  @override
  final Color containedContainerColor;

  @override
  final Color containedIndicatorColor;
}

class _LoadingIndicatorThemeDataDefaults extends LoadingIndicatorThemeData {
  const _LoadingIndicatorThemeDataDefaults({required ColorThemeData colorTheme})
    : _colorTheme = colorTheme;

  final ColorThemeData _colorTheme;

  @override
  Color get indicatorColor => _colorTheme.primary;

  @override
  Color get containedContainerColor => _colorTheme.primaryContainer;

  @override
  Color get containedIndicatorColor => _colorTheme.onPrimaryContainer;
}

class LoadingIndicatorTheme extends InheritedTheme {
  const LoadingIndicatorTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final LoadingIndicatorThemeData data;

  @override
  bool updateShouldNotify(LoadingIndicatorTheme oldWidget) =>
      data != oldWidget.data;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      LoadingIndicatorTheme(data: data, child: child);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<LoadingIndicatorThemeData>("data", data),
    );
  }

  static Widget merge({
    Key? key,
    required LoadingIndicatorThemeDataPartial data,
    required Widget child,
  }) => Builder(
    builder: (context) => LoadingIndicatorTheme(
      key: key,
      data: of(context).merge(data),
      child: child,
    ),
  );

  static LoadingIndicatorThemeData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LoadingIndicatorTheme>()?.data;

  static LoadingIndicatorThemeData of(BuildContext context) =>
      maybeOf(context) ??
      _LoadingIndicatorThemeDataDefaults(colorTheme: ColorTheme.of(context));
}

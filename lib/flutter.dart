library;

// SDK packages

export 'package:flutter/foundation.dart';

export 'package:flutter/services.dart';

export 'package:flutter/physics.dart';

export 'package:flutter/rendering.dart'
    hide
        RenderPadding,
        FlexParentData,
        RenderFlex,
        FloatingHeaderSnapConfiguration,
        PersistentHeaderShowOnScreenConfiguration,
        OverScrollHeaderStretchConfiguration;

export 'package:flutter/material.dart'
    hide
        // package:layout
        // ---
        Padding,
        Align,
        Center,
        Flex,
        Row,
        Column,
        Flexible,
        Expanded,
        Spacer,
        // ---
        // package:material
        // ---
        WidgetStateProperty,
        WidgetStatesConstraint,
        WidgetStateMap,
        WidgetStateMapper,
        WidgetStatePropertyAll,
        WidgetStatesController,
        // ---
        Material,
        MaterialType,
        // ---
        Icon,
        IconTheme,
        IconThemeData,
        // ---
        // Force migration to Material Symbols
        Icons,
        AnimatedIcons,
        // ---
        CircularProgressIndicator,
        LinearProgressIndicator,
        ProgressIndicator,
        // ---
        Checkbox,
        CheckboxTheme,
        CheckboxThemeData,
        // ---
        Switch,
        SwitchTheme,
        SwitchThemeData;

// Third-party packages

export 'package:meta/meta.dart';
export 'package:material_symbols_icons/material_symbols_icons.dart';

// Internal packages

export 'package:layout/layout.dart';
export 'package:material/material.dart';

// Adjacent libraries

export 'assets/assets.gen.dart';
export 'assets/fonts.dart';
export 'assets/fonts.gen.dart';
export 'i18n/strings.g.dart';

// Shared utilities

import 'package:dynamic_color_ffi/dynamic_color_ffi.dart';
import 'package:materium/flutter.dart';
import 'package:screen_corners_ffi/screen_corners_ffi.dart';

@immutable
class CombiningBuilder extends StatelessWidget {
  const CombiningBuilder({
    super.key,
    this.useOuterContext = false,
    required this.builders,
    required this.child,
  });

  final bool useOuterContext;

  final List<Widget Function(BuildContext context, Widget child)> builders;

  /// The child widget to pass to the last of [builders].
  ///
  /// {@macro flutter.widgets.transitions.ListenableBuilder.optimizations}
  final Widget child;

  @override
  Widget build(BuildContext outerContext) {
    return builders.reversed.fold(child, (child, buildOuter) {
      return useOuterContext
          ? buildOuter(outerContext, child)
          : Builder(builder: (innerContext) => buildOuter(innerContext, child));
    });
  }
}

extension DynamicColorSchemeToColorTheme on DynamicColorScheme {
  ColorThemeDataPartial toColorTheme() => ColorThemeDataPartial.from(
    primaryPaletteKeyColor: primaryPaletteKeyColor,
    secondaryPaletteKeyColor: secondaryPaletteKeyColor,
    tertiaryPaletteKeyColor: tertiaryPaletteKeyColor,
    neutralPaletteKeyColor: neutralPaletteKeyColor,
    neutralVariantPaletteKeyColor: neutralVariantPaletteKeyColor,
    errorPaletteKeyColor: errorPaletteKeyColor,
    background: background,
    onBackground: onBackground,
    surface: surface,
    surfaceDim: surfaceDim,
    surfaceBright: surfaceBright,
    surfaceContainerLowest: surfaceContainerLowest,
    surfaceContainerLow: surfaceContainerLow,
    surfaceContainer: surfaceContainer,
    surfaceContainerHigh: surfaceContainerHigh,
    surfaceContainerHighest: surfaceContainerHighest,
    onSurface: onSurface,
    surfaceVariant: surfaceVariant,
    onSurfaceVariant: onSurfaceVariant,
    outline: outline,
    outlineVariant: outlineVariant,
    inverseSurface: inverseSurface,
    inverseOnSurface: inverseOnSurface,
    shadow: shadow,
    scrim: scrim,
    surfaceTint: surfaceTint,
    primary: primary,
    primaryDim: primaryDim,
    onPrimary: onPrimary,
    primaryContainer: primaryContainer,
    onPrimaryContainer: onPrimaryContainer,
    primaryFixed: primaryFixed,
    primaryFixedDim: primaryFixedDim,
    onPrimaryFixed: onPrimaryFixed,
    onPrimaryFixedVariant: onPrimaryFixedVariant,
    inversePrimary: inversePrimary,
    secondary: secondary,
    secondaryDim: secondaryDim,
    onSecondary: onSecondary,
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: onSecondaryContainer,
    secondaryFixed: secondaryFixed,
    secondaryFixedDim: secondaryFixedDim,
    onSecondaryFixed: onSecondaryFixed,
    onSecondaryFixedVariant: onSecondaryFixedVariant,
    tertiary: tertiary,
    tertiaryDim: tertiaryDim,
    onTertiary: onTertiary,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: onTertiaryContainer,
    tertiaryFixed: tertiaryFixed,
    tertiaryFixedDim: tertiaryFixedDim,
    onTertiaryFixed: onTertiaryFixed,
    onTertiaryFixedVariant: onTertiaryFixedVariant,
    error: error,
    errorDim: errorDim,
    onError: onError,
    errorContainer: errorContainer,
    onErrorContainer: onErrorContainer,
  );
}

extension ScreenCornersDataExtension on ScreenCornersData {
  Corners toCorners() => Corners.only(
    topLeft: Corner.circular(topLeft),
    topRight: Corner.circular(topRight),
    bottomLeft: Corner.circular(bottomLeft),
    bottomRight: Corner.circular(bottomRight),
  );
}

extension EdgeInsetsGeometryExtension on EdgeInsetsGeometry {
  // TODO: improve and optimize this implementation
  EdgeInsetsGeometry _clampAxis({
    required double minHorizontal,
    required double maxHorizontal,
    required double minVertical,
    required double maxVertical,
  }) {
    final minNormal = EdgeInsets.symmetric(
      horizontal: minHorizontal,
      vertical: minVertical,
    );
    final maxNormal =
        EdgeInsets.symmetric(
          horizontal: maxHorizontal,
          vertical: maxVertical,
        ).add(
          EdgeInsetsDirectional.symmetric(
            horizontal: maxHorizontal,
            vertical: 0.0,
          ),
        );
    final minDirectional = EdgeInsetsDirectional.symmetric(
      horizontal: minHorizontal,
      vertical: minVertical,
    );
    final maxDirectional = EdgeInsetsDirectional.symmetric(
      horizontal: maxHorizontal,
      vertical: maxVertical,
    ).add(EdgeInsets.symmetric(horizontal: maxHorizontal, vertical: 0.0));
    final result = clamp(
      minNormal,
      maxNormal,
    ).clamp(minDirectional, maxDirectional);
    return result;
  }

  EdgeInsetsGeometry _horizontalInsetsMixed() => _clampAxis(
    minHorizontal: 0.0,
    maxHorizontal: double.infinity,
    minVertical: 0.0,
    maxVertical: 0.0,
  );

  EdgeInsetsGeometry _verticalInsetsMixed() => _clampAxis(
    minHorizontal: 0.0,
    maxHorizontal: 0.0,
    minVertical: 0.0,
    maxVertical: double.infinity,
  );

  EdgeInsetsGeometry horizontalInsets() => switch (this) {
    // final value when kDebugMode => _ClampedEdgeInsets(
    //   value,
    //   minHorizontal: 0.0,
    //   maxHorizotal: double.infinity,
    //   minVertical: 0.0,
    //   maxVertical: 0.0,
    // ),
    final EdgeInsets value => value._horizontalInsets(),
    final EdgeInsetsDirectional value => value._horizontalInsets(),
    final value => value._horizontalInsetsMixed(),
  };

  EdgeInsetsGeometry verticalInsets() => switch (this) {
    // final value when kDebugMode => _ClampedEdgeInsets(
    //   this,
    //   minHorizontal: 0.0,
    //   maxHorizotal: 0.0,
    //   minVertical: 0.0,
    //   maxVertical: double.infinity,
    // ),
    final EdgeInsets value => value._verticalInsets(),
    final EdgeInsetsDirectional value => value._verticalInsets(),
    final value => value._verticalInsetsMixed(),
  };
}

extension EdgeInsetsExtension on EdgeInsets {
  EdgeInsets _horizontalInsets() => EdgeInsets.fromLTRB(left, 0.0, right, 0.0);

  EdgeInsets _verticalInsets() => EdgeInsets.fromLTRB(0.0, top, 0.0, bottom);

  EdgeInsets horizontalInsets() => _horizontalInsets();

  EdgeInsets verticalInsets() => _verticalInsets();
}

extension EdgeInsetsDirectionalExtension on EdgeInsetsDirectional {
  EdgeInsetsDirectional _horizontalInsets() =>
      EdgeInsetsDirectional.fromSTEB(start, 0.0, end, 0.0);

  EdgeInsetsDirectional _verticalInsets() =>
      EdgeInsetsDirectional.fromSTEB(0.0, top, 0.0, bottom);

  EdgeInsetsDirectional horizontalInsets() => _horizontalInsets();

  EdgeInsetsDirectional verticalInsets() => _verticalInsets();
}

class _ClampedEdgeInsets implements EdgeInsetsGeometry {
  const _ClampedEdgeInsets(
    this._parent, {
    this.minHorizontal = 0.0,
    this.minVertical = 0.0,
    this.maxHorizontal = .infinity,
    this.maxVertical = .infinity,
    EdgeInsets Function(EdgeInsets value) transform = defaultTransform,
  }) : _transform = transform;

  final EdgeInsetsGeometry _parent;
  final double minHorizontal;
  final double minVertical;
  final double maxHorizontal;
  final double maxVertical;
  final EdgeInsets Function(EdgeInsets value) _transform;

  _ClampedEdgeInsets _transformed(
    EdgeInsets Function(EdgeInsets value) transform,
  ) => _ClampedEdgeInsets(
    _parent,
    minHorizontal: minHorizontal,
    minVertical: minVertical,
    maxHorizontal: maxHorizontal,
    maxVertical: maxVertical,
    transform: (value) => transform(_transform(value)),
  );

  @override
  EdgeInsetsGeometry operator %(double other) {
    // TODO: implement %
    throw UnimplementedError();
  }

  @override
  EdgeInsetsGeometry operator *(double other) =>
      _transformed((value) => value * other);

  @override
  EdgeInsetsGeometry operator /(double other) {
    // TODO: implement /
    throw UnimplementedError();
  }

  @override
  EdgeInsetsGeometry add(EdgeInsetsGeometry other) {
    // TODO: implement add
    throw UnimplementedError();
  }

  @override
  double along(Axis axis) {
    // TODO: implement along
    throw UnimplementedError();
  }

  @override
  EdgeInsetsGeometry clamp(EdgeInsetsGeometry min, EdgeInsetsGeometry max) {
    // TODO: implement clamp
    throw UnimplementedError();
  }

  @override
  // TODO: implement collapsedSize
  Size get collapsedSize => throw UnimplementedError();

  @override
  Size deflateSize(Size size) {
    // TODO: implement deflateSize
    throw UnimplementedError();
  }

  @override
  // TODO: implement flipped
  EdgeInsetsGeometry get flipped => throw UnimplementedError();

  @override
  // TODO: implement horizontal
  double get horizontal => throw UnimplementedError();

  @override
  Size inflateSize(Size size) {
    // TODO: implement inflateSize
    throw UnimplementedError();
  }

  @override
  // TODO: implement isNonNegative
  bool get isNonNegative => throw UnimplementedError();

  @override
  EdgeInsets resolve(TextDirection? direction) {
    // TODO: implement resolve
    throw UnimplementedError();
  }

  @override
  EdgeInsetsGeometry subtract(EdgeInsetsGeometry other) {
    // TODO: implement subtract
    throw UnimplementedError();
  }

  @override
  EdgeInsetsGeometry operator -() {
    // TODO: implement -
    throw UnimplementedError();
  }

  @override
  // TODO: implement vertical
  double get vertical => throw UnimplementedError();

  @override
  EdgeInsetsGeometry operator ~/(double other) {
    // TODO: implement ~/
    throw UnimplementedError();
  }

  static EdgeInsets defaultTransform(EdgeInsets value) => value;
}
// class _ClampedEdgeInsets implements EdgeInsetsGeometry {
//   const _ClampedEdgeInsets(
//     this._parent, {
//     required double minHorizontal,
//     required double maxHorizotal,
//     required double minVertical,
//     required double maxVertical,
//   }) : _minHorizontal = minHorizontal,
//        _maxHorizontal = maxHorizotal,
//        _minVertical = minVertical,
//        _maxVertical = maxVertical;

//   final EdgeInsetsGeometry _parent;
//   final double _minHorizontal;
//   final double _maxHorizontal;
//   final double _minVertical;
//   final double _maxVertical;

//   @override
//   EdgeInsets resolve(TextDirection? direction) {
//     assert(direction != null);
//     final resolved = _parent.resolve(direction);
//     return EdgeInsets.fromLTRB(
//       clampDouble(resolved.left, _minHorizontal, _maxHorizontal),
//       clampDouble(resolved.top, _minVertical, _maxVertical),
//       clampDouble(resolved.right, _minHorizontal, _maxHorizontal),
//       clampDouble(resolved.bottom, _minVertical, _maxVertical),
//     );
//   }

//   @override
//   EdgeInsetsGeometry operator %(double other) {}

//   @override
//   EdgeInsetsGeometry operator *(double other) {
//     // TODO: implement *
//     throw UnimplementedError();
//   }

//   @override
//   EdgeInsetsGeometry operator /(double other) {}

//   @override
//   EdgeInsetsGeometry add(EdgeInsetsGeometry other) {}

//   @override
//   double along(Axis axis) {
//     return switch (axis) {
//       Axis.horizontal => horizontal,
//       Axis.vertical => vertical,
//     };
//   }

//   @override
//   EdgeInsetsGeometry clamp(EdgeInsetsGeometry min, EdgeInsetsGeometry max) {}

//   @override
//   Size get collapsedSize => Size(horizontal, vertical);

//   @override
//   Size deflateSize(Size size) {
//     return Size(size.width - horizontal, size.height - vertical);
//   }

//   @override
//   EdgeInsetsGeometry get flipped => _ClampedEdgeInsets(
//     _parent.flipped,
//     minHorizontal: _minHorizontal,
//     maxHorizotal: _maxHorizontal,
//     minVertical: _minVertical,
//     maxVertical: _maxVertical,
//   );

//   @override
//   double get horizontal => clampDouble(
//     _parent.horizontal,
//     _minHorizontal * 2.0,
//     _maxHorizontal * 2.0,
//   );

//   @override
//   Size inflateSize(Size size) {
//     return Size(size.width + horizontal, size.height + vertical);
//   }

//   @override
//   bool get isNonNegative =>
//       _parent.isNonNegative && _maxHorizontal >= 0.0 && _maxVertical >= 0.0;

//   @override
//   EdgeInsetsGeometry subtract(EdgeInsetsGeometry other) {}

//   @override
//   EdgeInsetsGeometry operator -() => _ClampedEdgeInsets(
//     -_parent,
//     minHorizontal: -_maxHorizontal,
//     maxHorizotal: -_minHorizontal,
//     minVertical: -_maxVertical,
//     maxVertical: -_minVertical,
//   );

//   @override
//   double get vertical =>
//       clampDouble(_parent.vertical, _minVertical * 2.0, _maxVertical * 2.0);

//   @override
//   EdgeInsetsGeometry operator ~/(double other) {}

//   @override
//   bool operator ==(Object other) {
//     return identical(this, other) ||
//         runtimeType == other.runtimeType &&
//         other is _ClampedEdgeInsets &&
//         _parent == other._parent &&
//         _minHorizontal == other._minHorizontal &&
//         _maxHorizontal == other._maxHorizontal &&
//         _minVertical == other._minVertical &&
//         _maxVertical == other._maxVertical;
//   }

//   @override
//   int get hashCode => Object.hash(
//     runtimeType,
//     _parent,
//     _minHorizontal,
//     _maxHorizontal,
//     _minVertical,
//     _maxVertical,
//   );
// }

abstract base class _WrappedBase<T extends Object?> {
  const _WrappedBase();

  T get _;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _WrappedBase<T> &&
          _ == other._;

  @override
  int get hashCode => Object.hash(runtimeType, _);
}

final class Outer<T extends Object?> extends _WrappedBase<(T,)> {
  const Outer._(this._);
  const Outer(T value) : this._((value,));

  @override
  final (T,) _;

  T get inner => _.$1;

  Option<T> asOption() => Some(inner);

  Result<T, E> asResult<E extends Object>() => Ok(inner);

  static Outer<T>? fromOption<T extends Object?>(Option<T> value) =>
      switch (value) {
        Some(:final value) => Outer(value),
        None() => null,
      };

  static Outer<T>? fromResult<T extends Object?>(Result<T, Object?> value) =>
      switch (value) {
        Ok(:final value) => Outer(value),
        Error() => null,
      };
}

sealed class Option<T extends Object?> extends _WrappedBase<(T,)?> {
  const Option._();

  const factory Option.some(T value) = Some<T>;

  const factory Option.none() = None;

  Option<U> and<U extends Object?>(Option<U> other);

  Option<U> andThen<U extends Object?>(Option<U> Function(T value) fn);

  Option<T> filter(bool Function(T value) predicate);

  Option<T> or(Option<T> other);

  Option<T> orElse(Option<T> Function() fn);

  Option<T> xor(Option<T> other) => switch ((this, other)) {
    (final Some<T> a, None()) => a,
    (None(), final Some<T> b) => b,
    _ => const None(),
  };

  Option<T> inspect(void Function(T value) inspector) {
    if (this case Some(:final value)) {
      inspector(value);
    }
    return this;
  }

  bool get isSome;

  bool isSomeAnd(bool Function(T value) predicate);

  bool get isNone;

  bool isNoneOr(bool Function(T value) predicate);

  Option<U> map<U extends Object?>(U Function(T value) transformer);

  // T unwrap() => switch (this) {
  //   Some(:final value) => value,
  //   None() => throw StateError("Called `Option.unwrap()` on a `None` value"),
  // };

  T unwrapOr(T defaultValue) => switch (this) {
    Some(:final value) => value,
    None() => defaultValue,
  };

  T unwrapOrElse(T Function() fn) => switch (this) {
    Some(:final value) => value,
    None() => fn(),
  };

  Option<(T, U)> zip<U extends Object?>(Option<U> other) => (this, other).zip();

  Option<R> zipWith<U extends Object?, R extends Object?>(
    Option<U> other,
    R Function(T a, U b) combine,
  ) => (this, other).zipWith(combine);

  static Option<T> maybe<T extends Object>(T? value) =>
      value != null ? Some(value) : const None();
}

final class Some<T extends Object?> extends Option<T> {
  const Some._(this._) : super._();

  const Some(T value) : this._((value,));

  @override
  final (T,) _;

  T get value => _.$1;

  @override
  bool get isSome => true;

  @override
  bool isSomeAnd(bool Function(T value) predicate) => predicate(value);

  @override
  bool get isNone => false;

  @override
  bool isNoneOr(bool Function(T value) predicate) => predicate(value);

  @override
  Option<U> and<U extends Object?>(Option<U> other) => other;

  @override
  Option<U> andThen<U extends Object?>(Option<U> Function(T value) fn) =>
      fn(value);

  @override
  Some<T> or(Option<T> other) => this;

  @override
  Some<T> orElse(Option<T> Function() fn) => this;

  @override
  Option<T> filter(bool Function(T value) predicate) =>
      predicate(value) ? this : const None();

  @override
  Some<U> map<U extends Object?>(U Function(T value) transformer) =>
      Some(transformer(value));
}

final class None<T extends Object?> extends Option<T> {
  const None._(this._) : super._();

  const None() : this._(null);

  @override
  final Null _;

  @override
  bool get isSome => false;

  @override
  bool isSomeAnd(bool Function(T value) predicate) => false;

  @override
  bool get isNone => true;

  @override
  bool isNoneOr(bool Function(T value) predicate) => true;

  @override
  None<U> and<U extends Object?>(Option<U> other) => const None();

  @override
  None<U> andThen<U extends Object?>(Option<U> Function(T value) fn) =>
      const None();

  @override
  Option<T> or(Option<T> other) => other;

  @override
  Option<T> orElse(Option<T> Function() fn) => fn();

  @override
  None<T> filter(bool Function(T value) predicate) => this;

  @override
  None<U> map<U extends Object?>(U Function(T value) transformer) =>
      const None();
}

sealed class Result<T extends Object?, E extends Object?>
    extends _WrappedBase<({(T,)? ok, (E,)? error})> {
  const Result._();

  const factory Result.ok(T value) = Ok;

  const factory Result.error(E value) = Error;

  Option<T> get ok;

  Option<E> get error;

  Result<U, E> and<U extends Object?>(Result<U, E> other);

  Result<U, E> andThen<U extends Object?>(
    Result<U, E> Function(T value) transform,
  );

  Result<U, E> map<U extends Object?>(U Function(T value) transform);
}

final class Ok<T extends Object?, E extends Object?> extends Result<T, E> {
  const Ok._(this._) : super._();

  const Ok(T value) : this._((ok: (value,), error: null));

  @override
  final ({(T,) ok, Null error}) _;

  T get value => _.ok.$1;

  @override
  Some<T> get ok => Some(value);

  @override
  None<E> get error => const None();

  @override
  Result<U, E> and<U extends Object?>(Result<U, E> other) => other;

  @override
  Result<U, E> andThen<U extends Object?>(
    Result<U, E> Function(T value) transform,
  ) => transform(value);

  @override
  Ok<U, E> map<U extends Object?>(U Function(T value) transform) =>
      Ok(transform(value));
}

final class Error<T extends Object?, E extends Object?> extends Result<T, E> {
  const Error._(this._) : super._();

  const Error(E value) : this._((ok: null, error: (value,)));

  @override
  final ({Null ok, (E,) error}) _;

  E get value => _.error.$1;

  @override
  None<T> get ok => const None();

  @override
  Some<E> get error => Some(value);

  @override
  Error<U, E> and<U extends Object?>(Result<U, E> other) => Error(value);

  @override
  Result<U, E> andThen<U extends Object?>(
    Result<U, E> Function(T value) transform,
  ) => Error(value);

  @override
  Error<U, E> map<U extends Object?>(U Function(T value) transform) =>
      Error(value);
}

extension OptionOptionExtension<T extends Object?> on Option<Option<T>> {
  Option<T> flatten() => switch (this) {
    Some(:final value) => value,
    None() => const None(),
  };
}

extension Options2Extension<T1 extends Object?, T2 extends Object?>
    on (Option<T1>, Option<T2>) {
  Option<(T1, T2)> zip() => switch (this) {
    (Some(value: final x1), Some(value: final x2)) => Some((x1, x2)),
    _ => const None(),
  };

  Option<U> zipWith<U extends Object?>(U Function(T1, T2) combine) =>
      switch (this) {
        (Some(value: final x1), Some(value: final x2)) => Some(combine(x1, x2)),
        _ => const None(),
      };
}

extension Options3Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?
>
    on (Option<T1>, Option<T2>, Option<T3>) {
  Option<(T1, T2, T3)> zip() => switch (this) {
    (Some(value: final x1), Some(value: final x2), Some(value: final x3)) =>
      Some((x1, x2, x3)),
    _ => const None(),
  };

  Option<U> zipWith<U extends Object?>(U Function(T1, T2, T3) combine) =>
      switch (this) {
        (Some(value: final x1), Some(value: final x2), Some(value: final x3)) =>
          Some(combine(x1, x2, x3)),
        _ => const None(),
      };
}

extension Options4Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?,
  T4 extends Object?
>
    on (Option<T1>, Option<T2>, Option<T3>, Option<T4>) {
  Option<(T1, T2, T3, T4)> zip() => switch (this) {
    (
      Some(value: final x1),
      Some(value: final x2),
      Some(value: final x3),
      Some(value: final x4),
    ) =>
      Some((x1, x2, x3, x4)),
    _ => const None(),
  };

  Option<U> zipWith<U extends Object?>(U Function(T1, T2, T3, T4) combine) =>
      switch (this) {
        (
          Some(value: final x1),
          Some(value: final x2),
          Some(value: final x3),
          Some(value: final x4),
        ) =>
          Some(combine(x1, x2, x3, x4)),
        _ => const None(),
      };
}

extension Option2Extension<T1 extends Object?, T2 extends Object?>
    on Option<(T1, T2)> {
  (Option<T1>, Option<T2>) unzip() => switch (this) {
    Some(value: (final x1, final x2)) => (Some(x1), Some(x2)),
    _ => const (None(), None()),
  };
}

extension Option3Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?
>
    on Option<(T1, T2, T3)> {
  (Option<T1>, Option<T2>, Option<T3>) unzip() => switch (this) {
    Some(value: (final x1, final x2, final x3)) => (
      Some(x1),
      Some(x2),
      Some(x3),
    ),
    _ => const (None(), None(), None()),
  };
}

extension Option4Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?,
  T4 extends Object?
>
    on Option<(T1, T2, T3, T4)> {
  (Option<T1>, Option<T2>, Option<T3>, Option<T4>) unzip() => switch (this) {
    Some(value: (final x1, final x2, final x3, final x4)) => (
      Some(x1),
      Some(x2),
      Some(x3),
      Some(x4),
    ),
    _ => const (None(), None(), None(), None()),
  };
}

extension OptionResultExtension<T extends Object?, E extends Object?>
    on Option<Result<T, E>> {
  Result<Option<T>, E> transpose() => switch (this) {
    Some(value: Ok(:final value)) => Ok(Some(value)),
    Some(value: Error(:final value)) => Error(value),
    _ => const Ok(None()),
  };
}

extension ResultOptionExtension<T extends Object?, E extends Object?>
    on Result<Option<T>, E> {
  Option<Result<T, E>> transpose() => switch (this) {
    Ok(value: Some(:final value)) => Some(Ok(value)),
    Ok(value: None()) => const None(),
    Error(:final value) => Some(Error(value)),
  };
}

extension ResultResultExtension<T extends Object?, E extends Object?>
    on Result<Result<T, E>, E> {
  Result<T, E> flatten() => switch (this) {
    Ok(:final value) => value,
    Error(:final value) => Error(value),
  };
}

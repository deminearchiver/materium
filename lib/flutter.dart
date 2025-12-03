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

// Self-import

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

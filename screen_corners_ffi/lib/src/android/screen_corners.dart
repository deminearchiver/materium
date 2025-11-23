import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart'
    show
        BorderRadius,
        BuildContext,
        MediaQuery,
        RRect,
        RSuperellipse,
        Radius,
        Rect,
        WidgetsBinding;
import 'package:jni/jni.dart';

import 'jni_bindings.dart' as jb;

class _ScreenCornersDataPartial {
  const _ScreenCornersDataPartial._({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  factory _ScreenCornersDataPartial._fromNative(jb.ScreenCorners object) => ._(
    topLeft: object.getTopLeft()?.doubleValue(releaseOriginal: true),
    topRight: object.getTopRight()?.doubleValue(releaseOriginal: true),
    bottomLeft: object.getBottomLeft()?.doubleValue(releaseOriginal: true),
    bottomRight: object.getBottomRight()?.doubleValue(releaseOriginal: true),
  );

  factory _ScreenCornersDataPartial._fromActivity(jb.Activity activity) {
    final object = jb.ScreenCorners.fromActivity(activity);
    final result = _ScreenCornersDataPartial._fromNative(object);
    object.release();
    return result;
  }

  factory _ScreenCornersDataPartial.fromPlatform() {
    if (!Platform.isAndroid) return const ._();
    final activity = _getActivity();
    if (activity == null) return const ._();
    final result = _ScreenCornersDataPartial._fromActivity(activity);
    activity.release();
    return result;
  }

  final double? topLeft;
  final double? topRight;
  final double? bottomLeft;
  final double? bottomRight;

  ScreenCorners? resolve({double devicePixelRatio = 1.0}) => switch (this) {
    _ScreenCornersDataPartial(
      :final topLeft?,
      :final topRight?,
      :final bottomLeft?,
      :final bottomRight?,
    )
        when devicePixelRatio > 0.0 =>
      ScreenCorners(
        topLeft: math.max(topLeft, 0.0) / devicePixelRatio,
        topRight: math.max(topRight, 0.0) / devicePixelRatio,
        bottomLeft: math.max(bottomLeft, 0.0) / devicePixelRatio,
        bottomRight: math.max(bottomRight, 0.0) / devicePixelRatio,
      ),
    _ => null,
  };

  @override
  String toString() =>
      "${objectRuntimeType(this, "ScreenCornersDataPartial")}("
      "topLeft: $topLeft, "
      "topRight: $topRight, "
      "bottomLeft: $bottomLeft, "
      "bottomRight: $bottomRight"
      ")";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is _ScreenCornersDataPartial &&
          topLeft == other.topLeft &&
          topRight == other.topRight &&
          bottomLeft == other.bottomLeft &&
          bottomRight == other.bottomRight;

  @override
  int get hashCode =>
      Object.hash(runtimeType, topLeft, topRight, bottomLeft, bottomRight);

  static jb.Activity? _getActivity() {
    if (!Platform.isAndroid) return null;
    final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
    final engineId = platformDispatcher.engineId;
    assert(engineId != null);
    return Jni.androidActivity(engineId!)?.as(jb.Activity.type);
  }
}

class ScreenCorners {
  const ScreenCorners({
    this.topLeft = 0.0,
    this.topRight = 0.0,
    this.bottomLeft = 0.0,
    this.bottomRight = 0.0,
  }) : assert(
         topLeft >= 0.0 &&
             topRight >= 0.0 &&
             bottomLeft >= 0.0 &&
             bottomRight >= 0.0,
       );

  final double topLeft;
  final double topRight;
  final double bottomLeft;
  final double bottomRight;

  BorderRadius toBorderRadius() => BorderRadius.only(
    topLeft: Radius.circular(topLeft),
    topRight: Radius.circular(topRight),
    bottomLeft: Radius.circular(bottomLeft),
    bottomRight: Radius.circular(bottomRight),
  );

  RRect toRRect(Rect rect) => toBorderRadius().toRRect(rect);

  RSuperellipse toRSuperellipse(Rect rect) =>
      toBorderRadius().toRSuperellipse(rect);

  @override
  String toString() =>
      "${objectRuntimeType(this, "ScreenCorners")}("
      "topLeft: $topLeft, "
      "topRight: $topRight, "
      "bottomLeft: $bottomLeft, "
      "bottomRight: $bottomRight"
      ")";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ScreenCorners &&
          topLeft == other.topLeft &&
          topRight == other.topRight &&
          bottomLeft == other.bottomLeft &&
          bottomRight == other.bottomRight;

  @override
  int get hashCode =>
      Object.hash(runtimeType, topLeft, topRight, bottomLeft, bottomRight);

  static const ScreenCorners zero = ScreenCorners(
    topLeft: 0.0,
    topRight: 0.0,
    bottomLeft: 0.0,
    bottomRight: 0.0,
  );

  static ScreenCorners? maybeOf(BuildContext context) {
    // Returning early will not create a dependency on devicePixelRatio,
    // preventing uncessary rebuilds
    if (!Platform.isAndroid) return null;

    // Important: listen to devicePixelRatio updates
    final devicePixelRatio = MediaQuery.maybeDevicePixelRatioOf(context);

    return devicePixelRatio != null
        ? _ScreenCornersDataPartial.fromPlatform().resolve(
            devicePixelRatio: devicePixelRatio,
          )
        : null;
  }

  static ScreenCorners of(BuildContext context) => maybeOf(context) ?? .zero;

  static BorderRadius? maybeBorderRadiusOf(BuildContext context) =>
      maybeOf(context)?.toBorderRadius();

  static BorderRadius borderRadiusOf(BuildContext context) =>
      of(context).toBorderRadius();
}

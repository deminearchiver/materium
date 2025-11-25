import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

abstract class ScreenCornersDataPartial with Diagnosticable {
  const ScreenCornersDataPartial();

  const factory ScreenCornersDataPartial.from({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) = _ScreenCornersDataPartial;

  double? get topLeft;
  double? get topRight;
  double? get bottomLeft;
  double? get bottomRight;

  ScreenCornersDataPartial copyWith({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) =>
      topLeft != null ||
          topRight != null ||
          bottomLeft != null ||
          bottomRight != null
      ? ScreenCornersDataPartial.from(
          topLeft: topLeft ?? this.topLeft,
          topRight: topRight ?? this.topRight,
          bottomLeft: bottomLeft ?? this.bottomLeft,
          bottomRight: bottomRight ?? this.bottomRight,
        )
      : this;

  ScreenCornersDataPartial merge(ScreenCornersDataPartial? other) =>
      other != null
      ? copyWith(
          topLeft: other.topLeft,
          topRight: other.topRight,
          bottomLeft: other.bottomLeft,
          bottomRight: other.bottomRight,
        )
      : this;

  @internal
  ScreenCornersData? applyDevicePixelRatio({double devicePixelRatio = 1.0}) =>
      switch (this) {
        ScreenCornersDataPartial(
          :final topLeft?,
          :final topRight?,
          :final bottomLeft?,
          :final bottomRight?,
        )
            when devicePixelRatio > 0.0 =>
          ScreenCornersData.from(
            topLeft: math.max(topLeft, 0.0) / devicePixelRatio,
            topRight: math.max(topRight, 0.0) / devicePixelRatio,
            bottomLeft: math.max(bottomLeft, 0.0) / devicePixelRatio,
            bottomRight: math.max(bottomRight, 0.0) / devicePixelRatio,
          ),
        _ => null,
      };

  @override
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DoubleProperty("topLeft", topLeft, defaultValue: null))
      ..add(DoubleProperty("topRight", topRight, defaultValue: null))
      ..add(DoubleProperty("bottomLeft", bottomLeft, defaultValue: null))
      ..add(DoubleProperty("bottomRight", bottomRight, defaultValue: null));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ScreenCornersDataPartial &&
          topLeft == other.topLeft &&
          topRight == other.topRight &&
          bottomLeft == other.bottomLeft &&
          bottomRight == other.bottomRight;

  @override
  int get hashCode =>
      Object.hash(runtimeType, topLeft, topRight, bottomLeft, bottomRight);
}

class _ScreenCornersDataPartial extends ScreenCornersDataPartial {
  const _ScreenCornersDataPartial({
    this.topLeft,
    this.topRight,
    this.bottomLeft,
    this.bottomRight,
  });

  @override
  final double? topLeft;

  @override
  final double? topRight;

  @override
  final double? bottomLeft;

  @override
  final double? bottomRight;
}

abstract class ScreenCornersData extends ScreenCornersDataPartial {
  const ScreenCornersData();

  const factory ScreenCornersData.from({
    double topLeft,
    double topRight,
    double bottomLeft,
    double bottomRight,
  }) = _ScreenCornersData;

  @override
  double get topLeft;

  @override
  double get topRight;

  @override
  double get bottomLeft;

  @override
  double get bottomRight;

  @override
  ScreenCornersData copyWith({
    double? topLeft,
    double? topRight,
    double? bottomLeft,
    double? bottomRight,
  }) =>
      topLeft != null ||
          topRight != null ||
          bottomLeft != null ||
          bottomRight != null
      ? ScreenCornersData.from(
          topLeft: topLeft ?? this.topLeft,
          topRight: topRight ?? this.topRight,
          bottomLeft: bottomLeft ?? this.bottomLeft,
          bottomRight: bottomRight ?? this.bottomRight,
        )
      : this;

  @override
  ScreenCornersData merge(ScreenCornersDataPartial? other) => other != null
      ? copyWith(
          topLeft: other.topLeft,
          topRight: other.topRight,
          bottomLeft: other.bottomLeft,
          bottomRight: other.bottomRight,
        )
      : this;

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
  // ignore: must_call_super
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DoubleProperty("topLeft", topLeft))
      ..add(DoubleProperty("topRight", topRight))
      ..add(DoubleProperty("bottomLeft", bottomLeft))
      ..add(DoubleProperty("bottomRight", bottomRight));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is ScreenCornersData &&
          topLeft == other.topLeft &&
          topRight == other.topRight &&
          bottomLeft == other.bottomLeft &&
          bottomRight == other.bottomRight;

  @override
  int get hashCode =>
      Object.hash(runtimeType, topLeft, topRight, bottomLeft, bottomRight);
}

class _ScreenCornersData extends ScreenCornersData {
  const _ScreenCornersData({
    this.topLeft = 0.0,
    this.topRight = 0.0,
    this.bottomLeft = 0.0,
    this.bottomRight = 0.0,
  });

  @override
  final double topLeft;

  @override
  final double topRight;

  @override
  final double bottomLeft;

  @override
  final double bottomRight;
}

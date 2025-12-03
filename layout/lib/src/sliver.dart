import 'package:flutter/rendering.dart';

extension SliverHitTestResultExtension on SliverHitTestResult {
  Offset _resolvePosition({
    required AxisDirection axisDirection,
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) => switch (axisDirection) {
    .up || .down => Offset(crossAxisPosition, mainAxisPosition),
    .right || .left => Offset(mainAxisPosition, crossAxisPosition),
  };

  double _resolveMainAxisPosition({
    required AxisDirection axisDirection,
    required Offset position,
  }) => switch (axisDirection) {
    .up || .down => position.dy,
    .right || .left => position.dx,
  };

  double _resolveCrossAxisPosition({
    required AxisDirection axisDirection,
    required Offset position,
  }) => switch (axisDirection) {
    .up || .down => position.dx,
    .right || .left => position.dy,
  };

  bool addWithPaintTransform({
    required Matrix4? transform,
    required AxisDirection axisDirection,
    required double mainAxisPosition,
    required double crossAxisPosition,
    required SliverHitTest hitTest,
  }) {
    if (transform != null) {
      transform = Matrix4.tryInvert(
        PointerEvent.removePerspectiveTransform(transform),
      );
      if (transform == null) {
        // Objects are not visible on screen and cannot be hit-tested.
        return false;
      }
    }
    return addWithRawTransform(
      transform: transform,
      axisDirection: axisDirection,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
      hitTest: hitTest,
    );
  }

  bool addWithPaintOffset({
    required Offset? offset,
    required AxisDirection axisDirection,
    required double mainAxisPosition,
    required double crossAxisPosition,
    required SliverHitTest hitTest,
  }) {
    final position = _resolvePosition(
      axisDirection: axisDirection,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
    );
    final transformedPosition = offset == null ? position : position - offset;
    final transformedMainAxisPosition = _resolveMainAxisPosition(
      axisDirection: axisDirection,
      position: transformedPosition,
    );
    final transformedCrossAxisPosition = _resolveCrossAxisPosition(
      axisDirection: axisDirection,
      position: transformedPosition,
    );
    if (offset != null) {
      // ignore: invalid_use_of_protected_member
      pushOffset(-offset);
    }
    final isHit = hitTest(
      this,
      mainAxisPosition: transformedMainAxisPosition,
      crossAxisPosition: transformedCrossAxisPosition,
    );
    if (offset != null) {
      // ignore: invalid_use_of_protected_member
      popTransform();
    }
    return isHit;
  }

  bool addWithRawTransform({
    required Matrix4? transform,
    required AxisDirection axisDirection,
    required double mainAxisPosition,
    required double crossAxisPosition,
    required SliverHitTest hitTest,
  }) {
    final position = _resolvePosition(
      axisDirection: axisDirection,
      mainAxisPosition: mainAxisPosition,
      crossAxisPosition: crossAxisPosition,
    );
    final transformedPosition = transform == null
        ? position
        : MatrixUtils.transformPoint(transform, position);
    final transformedMainAxisPosition = _resolveMainAxisPosition(
      axisDirection: axisDirection,
      position: transformedPosition,
    );
    final transformedCrossAxisPosition = _resolveCrossAxisPosition(
      axisDirection: axisDirection,
      position: transformedPosition,
    );
    if (transform != null) {
      // ignore: invalid_use_of_protected_member
      pushTransform(transform);
    }
    final isHit = hitTest(
      this,
      mainAxisPosition: transformedMainAxisPosition,
      crossAxisPosition: transformedCrossAxisPosition,
    );
    if (transform != null) {
      // ignore: invalid_use_of_protected_member
      popTransform();
    }
    return isHit;
  }
}

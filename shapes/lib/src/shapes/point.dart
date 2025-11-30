import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'cubic.dart';
import 'utils.dart';

@internal
@immutable
final class Point {
  const Point(this.x, this.y);

  final double x;
  final double y;

  Point copyWith({double? x, double? y}) =>
      x != null || y != null ? Point(x ?? this.x, y ?? this.y) : this;

  /// The magnitude of the Point, which is the distance of this point
  /// from (0, 0).
  ///
  /// If you need this value to compare it to another [Point]'s distance,
  /// consider using [getDistanceSquared] instead,
  /// since it is cheaper to compute.
  double getDistance() => math.sqrt(x * x + y * y);

  /// The square of the magnitude (which is the distance of this point
  /// from (0, 0)) of the Point.
  ///
  /// This is cheaper than computing the [getDistance] itself.
  double getDistanceSquared() => x * x + y * y;

  double dotProduct(Point other) => x * other.x + y * other.y;

  double dotProductWith(double otherX, double otherY) =>
      x * otherX + y * otherY;

  /// Compute the Z coordinate of the cross product of two vectors,
  /// to check if the second vector is going clockwise ( > 0 )
  /// or counterclockwise (< 0) compared with the first one. It could also be 0,
  /// if the vectors are co-linear.
  bool clockwise(Point other) => x * other.y - y * other.x >= 0.0;

  Point getDirection() {
    final d = getDistance();
    assert(d > 0.0, "Can't get the direction of a 0-length vector");
    return this / d;
  }

  Point transformed(PointTransformer f) {
    final result = f(x, y);
    return Point(result.$1, result.$2);
  }

  Point operator -() => Point(-x, -y);

  Point operator -(Point other) => Point(x - other.x, y - other.y);

  Point operator +(Point other) => Point(x + other.x, y + other.y);

  Point operator *(double operand) => Point(x * operand, y * operand);

  Point operator /(double operand) => Point(x / operand, y / operand);

  Point operator %(double operand) => Point(x % operand, y % operand);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is Point &&
            x == other.x &&
            y == other.y;
  }

  @override
  int get hashCode => Object.hash(runtimeType, x, y);

  static const Point zero = Point(0.0, 0.0);

  static Point interpolate(Point start, Point stop, double fraction) => Point(
    interpolateDouble(start.x, stop.x, fraction),
    interpolateDouble(start.y, stop.y, fraction),
  );
}

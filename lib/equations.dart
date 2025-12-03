// MIT License
//
// Copyright (c) 2020 Alberto Miola
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:math' as math;

import 'package:materium/flutter.dart';

/// A point in the cartesian coordinate system used by [Interpolation] types to
/// represent interpolation nodes. This class simply represents the `x` and `y`
/// coordinates of a point on a cartesian plane.
class InterpolationNode {
  /// Creates an [InterpolationNode] object.
  const InterpolationNode({required this.x, required this.y});

  /// The x coordinate.
  final double x;

  /// The y coordinate.
  final double y;

  @override
  String toString() =>
      "${objectRuntimeType(this, "InterpolationNode")}(x: $x, y: $y)";

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is InterpolationNode &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => Object.hash(runtimeType, x, y);
}

/// An abstract class that represents an interpolation strategy, used to find
/// new data points based on a given discrete set of data points (called nodes).
/// The algorithms implemented by this package are:
///
///  - [LinearInterpolation];
///  - [PolynomialInterpolation];
///  - [NewtonInterpolation];
///  - [SplineInterpolation].
abstract class Interpolation {
  /// Creates an [Interpolation] object with the given nodes.
  const Interpolation({required this.nodes});

  /// The interpolation nodes.
  final List<InterpolationNode> nodes;

  /// Returns the `y` value of the `y = f(x)` equation.
  ///
  /// The function `f` is built by interpolating the given [nodes] nodes. The
  /// [x] value is the point at which the function has to be evaluated.
  double compute(double x);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is Interpolation &&
          listEquals(nodes, other.nodes);

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(nodes));
}

/// Performs spline interpolation given a set of control points. The algorithm
/// can compute a "monotone cubic spline" or a "linear spline" based on the
/// properties of the control points.
class SplineInterpolation extends Interpolation {
  /// Creates a [SplineInterpolation] instance from the given interpolation
  /// nodes.
  const SplineInterpolation({required super.nodes});

  @override
  double compute(double x) =>
      SplineFunction.generate(nodes: nodes).interpolate(x);

  @override
  String toString() =>
      "${objectRuntimeType(this, "SplineInterpolation")}(nodes: $nodes)";
}

/// A **spline** is a special function defined piecewise by polynomials.
///
/// In interpolating problems, spline interpolation is often preferred to
/// polynomial interpolation because it yields similar results, even when using
/// low-degree polynomials, while avoiding Runge's phenomenon for higher
/// degrees.
sealed class SplineFunction {
  /// Creates a [SplineFunction] object with the given nodes.
  const SplineFunction({required this.nodes});

  /// The interpolation nodes.
  final List<InterpolationNode> nodes;

  /// Creates an appropriate spline based on the properties of the given nodes.
  ///
  /// If the control points are monotonic then the resulting spline will
  /// preserve that. This method can either return:
  ///
  ///  - [MonotoneCubicSplineFunction] if nodes are monotonic
  ///  - [LinearSplineFunction] otherwise.
  ///
  /// The control points must all have increasing `x` values.
  ///
  /// If the [nodes] doesn't contain values sorted in increasing order, then an
  /// [InterpolationException] object is thrown.
  factory SplineFunction.generate({required List<InterpolationNode> nodes}) {
    if (!_isStrictlyIncreasing(nodes)) {
      throw ArgumentError(
        "The control points must all have increasing `x` values.",
      );
    }
    return _isMonotonic(nodes)
        ? MonotoneCubicSplineFunction(nodes: nodes)
        : LinearSplineFunction(nodes: nodes);
  }

  /// Estimates the `y` value of the `y = f(x)` equation using a spline.
  ///
  /// Clamps [x] to the domain of the spline.
  double interpolate(double x);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType &&
          other is SplineFunction &&
          listEquals(nodes, other.nodes);

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(nodes));

  /// Determines whether the `x` coordinates of the control points are
  /// increasing or not.
  static bool _isStrictlyIncreasing(List<InterpolationNode> nodes) {
    if (nodes.length < 2) {
      throw ArgumentError("There must be at least 2 control points.");
    }

    // The "comparison" node.
    var prev = nodes.first.x;

    // Making sure that all of the 'X' coordinates of the nodes are increasing.
    for (var i = 1; i < nodes.length; ++i) {
      final curr = nodes[i].x;
      if (curr <= prev) return false;
      prev = curr;
    }
    return true;
  }

  /// Determines whether the function is monotonic or not.
  static bool _isMonotonic(List<InterpolationNode> nodes) {
    // The "comparison" node.
    var prev = nodes.first.y;

    // Making sure that all of the 'y' coordinates of the nodes are increasing
    for (var i = 1; i < nodes.length; ++i) {
      final curr = nodes[i].y;
      if (curr < prev) return false;
      prev = curr;
    }

    return true;
  }
}

/// Represents a linear spline from a given set of control points. The
/// interpolated curve will be monotonic if the control points.
class LinearSplineFunction extends SplineFunction {
  /// Creates a [LinearSplineFunction] object from the given nodes.
  const LinearSplineFunction({required super.nodes});

  @override
  double interpolate(double x) {
    // Linear spline creation
    final nodesM = List<double>.generate(
      nodes.length - 1,
      (i) => (nodes[i + 1].y - nodes[i].y) / (nodes[i + 1].x - nodes[i].x),
      growable: false,
    );

    // Interpolating
    if (x.isNaN) return x;
    if (x < nodes.first.x) return nodes.first.y;
    if (x >= nodes.last.x) return nodes.last.y;

    // Finding the i-th element of the last point with smaller 'x'.
    // We are sure that this will be within the spline due to the previous
    // boundary tests.
    var i = 0;
    while (x >= nodes[i + 1].x) {
      ++i;
      if (x == nodes[i].x) return nodes[i].y;
    }
    return nodes[i].y + nodesM[i] * (x - nodes[i].x);
  }

  @override
  String toString() =>
      "${objectRuntimeType(this, "LinearSplineFunction")}(nodes: $nodes)";
}

/// Represents a monotone cubic spline from a given set of control points.
///
/// The spline is guaranteed to pass through each control point exactly. In
/// addition, assuming the control points are monotonic, then the interpolated
/// values will also be monotonic.
class MonotoneCubicSplineFunction extends SplineFunction {
  /// Creates a [MonotoneCubicSplineFunction] object from the given nodes.
  const MonotoneCubicSplineFunction({required super.nodes});

  @override
  double interpolate(double x) {
    // Monotonic cubic spline creation
    final nodesM = List<double>.generate(nodes.length, (_) => 0);
    final pointsD = List<double>.generate(nodes.length - 1, (_) => 0);

    // Slopes of secant lines between successive points
    for (var i = 0; i < nodes.length - 1; ++i) {
      final h = nodes[i + 1].x - nodes[i].x;

      if (h <= 0) {
        throw ArgumentError(
          "The control points must all have strictly increasing `x` values.",
        );
      }

      pointsD[i] = (nodes[i + 1].y - nodes[i].y) / h;
    }

    // Initializing tangents as the average of the secants.
    nodesM.first = pointsD.first;

    for (var i = 1; i < nodes.length - 1; i++) {
      nodesM[i] = (pointsD[i - 1] + pointsD[i]) * 0.5;
    }

    nodesM[nodes.length - 1] = pointsD[nodes.length - 2];

    // Updating tangents to preserve monotonicity.
    for (var i = 0; i < nodes.length - 1; i++) {
      if (pointsD[i] == 0) {
        // When successive 'Y' values are equals, manually set to 0
        nodesM[i] = 0;
        nodesM[i + 1] = 0;
      } else {
        final a = nodesM[i] / pointsD[i];
        final b = nodesM[i + 1] / pointsD[i];

        if (a < 0 || b < 0) {
          throw ArgumentError(
            "The control points must have monotonic `y` values.",
          );
        }

        final h = math.sqrt(a * a + b * b);

        if (h > 3) {
          final t = 3 / h;
          nodesM[i] *= t;
          nodesM[i + 1] *= t;
        }
      }
    }

    // Interpolating
    if (x.isNaN) {
      return x;
    }

    if (x < nodes.first.x) {
      return nodes.first.y;
    }

    if (x >= nodes.last.x) {
      return nodes.last.y;
    }

    // Finding the i-th element of the last point with smaller 'x'.
    // We are sure that this will be within the spline due to the previous
    // boundary tests.
    var i = 0;
    while (x >= nodes[i + 1].x) {
      ++i;

      if (x == nodes[i].x) {
        return nodes[i].y;
      }
    }

    // Cubic Hermite spline interpolation.
    final h = nodes[i + 1].x - nodes[i].x;
    final t = (x - nodes[i].x) / h;

    return (nodes[i].y * (1 + t * 2) + h * nodesM[i] * t) * (1 - t) * (1 - t) +
        (nodes[i + 1].y * (3 - t * 2) + h * nodesM[i + 1] * (t - 1)) * t * t;
  }

  @override
  String toString() =>
      "${objectRuntimeType(this, "MonotoneCubicSplineFunction")}(nodes: $nodes)";
}

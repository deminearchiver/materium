import 'package:flutter/foundation.dart';

import 'cubic.dart';
import 'utils.dart';

/// While a polygon's shape can be drawn solely using a list of [Cubic] objects
/// representing its raw curves and lines, features add an extra layer
/// of context to groups of cubics. Features group cubics into (straight) edges,
/// convex corners, or concave corners. For example, rounding a rectangle adds
/// many cubics around its edges, but the rectangle's overall number of corners
/// remains the same. [Morph] therefore uses this grouping for several reasons:
/// - Noise Reduction: Grouping cubics reduces the amount of noise introduced by individual cubics
///   (as seen in the rounded rectangle example).
/// - Mapping Base: The grouping serves as the base set for [Morph]'s mapping process.
/// - Curve Type Mapping: [Morph] maps similar curve types (convex, concave) together. Note that
///   edges or features created with [buildIgnorableFeature] are ignored in the default mapping.
///
/// By using features, you can manipulate polygon shapes
/// with more context and control.
abstract class Feature {
  const Feature(this.cubics);

  /// Group a list of [Cubic] objects to a feature that
  /// should be ignored in the default [Morph] mapping.
  /// The feature can have any indentation.
  ///
  /// Sometimes, it's helpful to ignore certain features when morphing shapes.
  /// This is because only the features you mark as important will be smoothly
  /// transitioned between the start and end shapes.
  /// Additionally, the default morph algorithm will try to match convex
  /// corners to convex corners and concave to concave.
  /// Marking features as ignorable will influence this matching.
  /// For example, given a 12-pointed star, marking all concave corners
  /// as ignorable will create a [Morph] that only considers
  /// the outer corners of the star.
  /// As a result, depending on the morphed to shape,
  /// the animation may have fewer intersections and rotations.
  /// Another example for the other way around is a [Morph]
  /// between a pointed up triangle to a square.
  /// Marking the square's top edge as a convex corner matches it
  /// to the triangle's upper corner. Instead of moving triangle's upper corner
  /// to one of rectangle's corners, the animation now splits the triangle
  /// to match squares' outer corners.
  ///
  /// [cubics] - The list of raw cubics describing the feature's shape.
  ///
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics.
  factory Feature.ignorable(List<Cubic> cubics) => validated(Edge(cubics));

  /// Group a [Cubic] object to an edge
  /// (neither inward or outward identification in a shape).
  ///
  /// [cubic] - The raw cubic describing the edge's shape.
  ///
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics.
  factory Feature.edge(Cubic cubic) => Edge([cubic]);

  /// Group a list of [Cubic] objects to a convex corner
  /// (outward indentation in a shape).
  ///
  /// [cubics] - The list of raw cubics describing the corner's shape
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics.
  factory Feature.convexCorner(List<Cubic> cubics) =>
      validated(Corner(cubics, true));

  /// Group a list of [Cubic] objects to a concave corner
  /// (inward indentation in a shape).
  ///
  /// [cubics] - The list of raw cubics describing the corner's shape.
  /// Throws [ArgumentError] for lists of empty cubics or non-continuous cubics.
  factory Feature.concaveCorner(List<Cubic> cubics) =>
      validated(Corner(cubics, false));

  final List<Cubic> cubics;

  /// Transforms the points in this [Feature] with the given [PointTransformer]
  /// and returns a new [Feature].
  Feature transformed(PointTransformer f);

  /// Returns a new [Feature] with the points that define the shape of this
  /// [Feature] in reversed order.
  Feature reversed();

  /// Whether this Feature gets ignored in the Morph mapping.
  /// See [Feature.ignorable] for more details.
  bool get isIgnorableFeature;

  /// Whether this Feature is an Edge with no inward or outward indentation.
  bool get isEdge;

  /// Whether this Feature is a convex corner (outward indentation in a shape).
  bool get isConvexCorner;

  /// Whether this Feature is a concave corner (inward indentation in a shape).
  bool get isConcaveCorner;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is Feature &&
            listEquals(cubics, other.cubics) &&
            isIgnorableFeature == other.isIgnorableFeature &&
            isEdge == other.isEdge &&
            isConvexCorner == other.isConvexCorner &&
            isConcaveCorner == other.isConcaveCorner;
  }

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(cubics));

  static Feature validated(Feature feature) {
    if (feature.cubics.isEmpty) {
      throw ArgumentError("Features need at least one cubic.");
    }
    if (!_isContinuous(feature)) {
      throw ArgumentError(
        "Feature must be continuous, with the anchor points of all cubics "
        "matching the anchor points of the preceding and succeeding cubics",
      );
    }
    return feature;
  }

  static bool _isContinuous(Feature feature) {
    var prevCubic = feature.cubics.first;
    for (var index = 1; index < feature.cubics.length; index++) {
      final cubic = feature.cubics[index];
      if ((cubic.anchor0X - prevCubic.anchor1X).abs() > distanceEpsilon ||
          (cubic.anchor0Y - prevCubic.anchor1Y).abs() > distanceEpsilon) {
        return false;
      }
      prevCubic = cubic;
    }
    return true;
  }
}

/// Edges have only a list of the cubic curves which make up the edge.
/// Edges lie between corners and have no vertex or concavity;
/// the curves are simply straight lines (represented by Cubic curves).
@internal
final class Edge extends Feature {
  const Edge(super.cubics);

  @override
  Edge transformed(PointTransformer f) => Edge([
    // Performance: Builds the list by avoiding creating an unnecessary Iterator to
    // iterate through the cubics List.
    for (int i = 0; i < cubics.length; i++) cubics[i].transformed(f),
  ]);

  @override
  Edge reversed() =>
      Edge([for (int i = cubics.length - 1; i >= 0; i--) cubics[i].reverse()]);

  @override
  bool get isIgnorableFeature => true;

  @override
  bool get isEdge => true;

  @override
  bool get isConvexCorner => false;

  @override
  bool get isConcaveCorner => false;

  @override
  String toString() => "Edge(cubics: $cubics)";
}

@internal
final class Corner extends Feature {
  const Corner(super.cubics, [this.convex = true]);

  final bool convex;

  @override
  Corner transformed(PointTransformer f) => Corner([
    // Performance: Builds the list by avoiding creating an unnecessary Iterator to
    // iterate through the cubics List.
    for (int i = 0; i < cubics.length; i++) cubics[i].transformed(f),
  ], convex);

  @override
  Corner reversed() => Corner(
    [for (int i = cubics.length - 1; i >= 0; i--) cubics[i].reverse()],
    // TODO: b/369320447 - Revert flag negation when [RoundedPolygon] ignores orientation for setting the flag
    !convex,
  );

  @override
  bool get isIgnorableFeature => false;

  @override
  bool get isEdge => false;

  @override
  bool get isConvexCorner => convex;

  @override
  bool get isConcaveCorner => !convex;

  @override
  String toString() => "Corner(cubics: $cubics, convex: $convex)";
}

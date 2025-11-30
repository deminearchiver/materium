import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:meta/meta.dart';

import 'cubic.dart';
import 'feature_mapping.dart';
import 'polygon_measure.dart';
import 'rounded_polygon.dart';
import 'utils.dart';

final class Morph {
  Morph(this._start, this._end) : _morphMatch = match(_start, _end);

  final RoundedPolygon _start;
  final RoundedPolygon _end;

  final List<(Cubic, Cubic)> _morphMatch;

  @internal
  List<(Cubic, Cubic)> get morphMatch => _morphMatch;

  ui.Rect calculateBounds({bool approximate = true}) {
    final startBounds = _start.calculateBounds(approximate: approximate);
    final minX = startBounds.left;
    final minY = startBounds.top;
    final maxX = startBounds.right;
    final maxY = startBounds.bottom;
    final endBounds = _end.calculateBounds(approximate: approximate);
    return ui.Rect.fromLTRB(
      math.min(minX, endBounds.left),
      math.min(minY, endBounds.top),
      math.max(maxX, endBounds.right),
      math.max(maxY, endBounds.bottom),
    );
  }

  ui.Rect calculateMaxBounds() {
    final startBounds = _start.calculateMaxBounds();
    final minX = startBounds.left;
    final minY = startBounds.top;
    final maxX = startBounds.right;
    final maxY = startBounds.bottom;
    final endBounds = _end.calculateMaxBounds();
    return ui.Rect.fromLTRB(
      math.min(minX, endBounds.left),
      math.min(minY, endBounds.top),
      math.max(maxX, endBounds.right),
      math.max(maxY, endBounds.bottom),
    );
  }

  List<Cubic> asCubics(double progress) {
    final result = <Cubic>[];

    // The first/last mechanism here ensures that the final anchor point in the shape
    // exactly matches the first anchor point. There can be rendering artifacts introduced
    // by those points being slightly off, even by much less than a pixel
    Cubic? firstCubic;
    Cubic? lastCubic;
    for (var i = 0; i < morphMatch.length; i++) {
      final cubic = Cubic.interpolate(
        morphMatch[i].$1,
        morphMatch[i].$2,
        progress,
      );
      firstCubic ??= cubic;
      if (lastCubic != null) result.add(lastCubic);
      lastCubic = cubic;
    }
    if (lastCubic != null && firstCubic != null) {
      result.add(
        Cubic.from(
          lastCubic.anchor0X,
          lastCubic.anchor0Y,
          lastCubic.control0X,
          lastCubic.control0Y,
          lastCubic.control1X,
          lastCubic.control1Y,
          firstCubic.anchor0X,
          firstCubic.anchor0Y,
        ),
      );
    }

    return result;
  }

  void forEachCubic(
    double progress,
    void Function(MutableCubic) callback, [
    MutableCubic? mutableCubic,
  ]) {
    mutableCubic ??= MutableCubic.empty(0.0, 0.0);
    for (var i = 0; i < morphMatch.length; i++) {
      mutableCubic.interpolate(morphMatch[i].$1, morphMatch[i].$2, progress);
      callback(mutableCubic);
    }
  }

  @override
  String toString() => "Morph($_start, $_end)";

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is Morph &&
            _start == other._start &&
            _end == other._end;
  }

  @override
  int get hashCode => Object.hash(runtimeType, _start, _end);

  @internal
  static List<(Cubic, Cubic)> match(RoundedPolygon p1, RoundedPolygon p2) {
    // TODO Commented out due to the use of javaClass ("Error: Platform reference in a
    //  common module")
    /*
            if (DEBUG) {
               repeat(2) { polyIndex ->
                   debugLog(LOG_TAG) {
                       listOf("Initial start:\n", "Initial end:\n")[polyIndex] +
                           listOf(p1, p2)[polyIndex].features.joinToString("\n") { feature ->
                               "${feature.javaClass.name.split("$").last()} - " +
                                   ((feature as? Feature.Corner)?.convex?.let {
                                       if (it) "Convex - " else "Concave - " } ?: "") +
                                   feature.cubics.joinToString("|")
                           }
                   }
               }
            }
            */

    // Measure polygons, returns lists of measured cubics for each polygon, which
    // we then use to match start/end curves
    final measuredPolygon1 = MeasuredPolygon.measurePolygon(
      const LengthMeasurer(),
      p1,
    );
    final measuredPolygon2 = MeasuredPolygon.measurePolygon(
      const LengthMeasurer(),
      p2,
    );

    // features1 and 2 will contain the list of corners (just the inner circular curve)
    // along with the progress at the middle of those corners. These measurement values
    // are then used to compare and match between the two polygons
    final features1 = measuredPolygon1.features;
    final features2 = measuredPolygon2.features;

    // Map features: doubleMapper is the result of mapping the features in each shape to the
    // closest feature in the other shape.
    // Given a progress in one of the shapes it can be used to find the corresponding
    // progress in the other shape (in both directions)
    final doubleMapper = featureMapper(features1, features2);

    // cut point on poly2 is the mapping of the 0 point on poly1
    final polygon2CutPoint = doubleMapper.map(0.0);
    // debugLog(LOG_TAG) { "polygon2CutPoint = $polygon2CutPoint" }

    // Cut and rotate.
    // Polygons start at progress 0, and the featureMapper has decided that we want to match
    // progress 0 in the first polygon to `polygon2CutPoint` on the second polygon.
    // So we need to cut the second polygon there and "rotate it", so as we walk through
    // both polygons we can find the matching.
    // The resulting bs1/2 are MeasuredPolygons, whose MeasuredCubics start from
    // outlineProgress=0 and increasing until outlineProgress=1
    final bs1 = measuredPolygon1;
    final bs2 = measuredPolygon2.cutAndShift(polygon2CutPoint);

    // if (DEBUG) {
    //     (0 until bs1.size).forEach { index ->
    //         debugLog(LOG_TAG) { "start $index: ${bs1.getOrNull(index)}" }
    //     }
    //     (0 until bs2.size).forEach { index ->
    //         debugLog(LOG_TAG) { "End $index: ${bs2.getOrNull(index)}" }
    //     }
    // }

    // Match
    // Now we can compare the two lists of measured cubics and create a list of pairs
    // of cubics [ret], which are the start/end curves that represent the Morph object
    // and the start and end shapes, and which can be interpolated to animate the
    // between those shapes.
    final ret = <(Cubic, Cubic)>[];
    // i1/i2 are the indices of the current cubic on the start (1) and end (2) shapes
    var i1 = 0;
    var i2 = 0;
    // b1, b2 are the current measured cubic for each polygon
    var b1 = bs1.elementAtOrNull(i1++);
    var b2 = bs2.elementAtOrNull(i2++);
    // Iterate until all curves are accounted for and matched
    while (b1 != null && b2 != null) {
      // Progresses are in shape1's perspective
      // b1a, b2a are ending progress values of current measured cubics in [0,1] range
      final b1a = i1 == bs1.length ? 1.0 : b1.endOutlineProgress;
      final b2a = i2 == bs2.length
          ? 1.0
          : doubleMapper.mapBack(
              positiveModulo(b2.endOutlineProgress + polygon2CutPoint, 1.0),
            );

      final minb = math.min(b1a, b2a);

      // debugLog(LOG_TAG) { "$b1a $b2a | $minb" }

      // min b is the progress at which the curve that ends first ends.
      // If both curves ends roughly there, no cutting is needed, we have a match.
      // If one curve extends beyond, we need to cut it.

      final (seg1, newb1) = b1a > minb + angleEpsilon
          // debugLog(LOG_TAG) { "Cut 1" }
          ? b1.cutAtProgress(minb)
          : (b1, bs1.elementAtOrNull(i1++));

      final (seg2, newb2) = b2a > minb + angleEpsilon
          // debugLog(LOG_TAG) { "Cut 2" }
          ? b2.cutAtProgress(
              positiveModulo(doubleMapper.map(minb) - polygon2CutPoint, 1.0),
            )
          : (b2, bs2.elementAtOrNull(i2++));

      // debugLog(LOG_TAG) { "Match: $seg1 -> $seg2" }

      ret.add((seg1.cubic, seg2.cubic));
      b1 = newb1;
      b2 = newb2;
    }
    if (b1 != null || b2 != null) {
      throw ArgumentError("Expected both Polygon's Cubic to be fully matched");
    }

    // if (DEBUG) {
    //     // Export as SVG path.
    //     val showPoint: (Point) -> String = {
    //         "${(it.x * 100).toStringWithLessPrecision()} ${(it.y * 100).toStringWithLessPrecision()}"
    //     }
    //     repeat(2) { listIx ->
    //         val points = ret.map { if (listIx == 0) it.first else it.second }
    //         debugLog(LOG_TAG) {
    //             "M " +
    //                 showPoint(Point(points.first().anchor0X, points.first().anchor0Y)) +
    //                 " " +
    //                 points.joinToString(" ") {
    //                     "C " +
    //                         showPoint(Point(it.control0X, it.control0Y)) +
    //                         ", " +
    //                         showPoint(Point(it.control1X, it.control1Y)) +
    //                         ", " +
    //                         showPoint(Point(it.anchor1X, it.anchor1Y))
    //                 } +
    //                 " Z"
    //         }
    //     }
    // }
    return ret;
  }
}

import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'cubic.dart';
import 'feature_mapping.dart';
import 'features.dart';
import 'point.dart';
import 'rounded_polygon.dart';
import 'utils.dart';

@internal
final class MeasuredPolygon extends DelegatingList<MeasuredCubic> {
  MeasuredPolygon._(
    this._measurer,
    this.features,
    List<Cubic> cubics,
    List<double> outlineProgress,
  ) : super(<MeasuredCubic>[]) {
    if (outlineProgress.length != cubics.length + 1) {
      throw ArgumentError(
        "Outline progress size is expected to be the cubics size + 1",
      );
    }
    if (outlineProgress.first != 0.0) {
      throw ArgumentError(
        "First outline progress value is expected to be zero",
      );
    }
    if (outlineProgress.last != 1.0) {
      throw ArgumentError("Last outline progress value is expected to be one");
    }

    // if (DEBUG) {
    //     debugLog(LOG_TAG) {
    //         "CTOR: cubics = " +
    //             cubics.joinToString() +
    //             "\nCTOR: op = " +
    //             outlineProgress.joinToString()
    //     }
    // }
    var startOutlineProgress = 0.0;
    for (var index = 0; index < cubics.length; index++) {
      // Filter out "empty" cubics
      if ((outlineProgress[index + 1] - outlineProgress[index]) >
          distanceEpsilon) {
        add(
          MeasuredCubic(
            this,
            cubics[index],
            startOutlineProgress,
            outlineProgress[index + 1],
          ),
        );
        // The next measured cubic will start exactly where this one ends.
        startOutlineProgress = outlineProgress[index + 1];
      }
    }
    // We could have removed empty cubics at the end. Ensure the last measured cubic ends at 1f
    this[length - 1].updateProgressRange(endOutlineProgress: 1.0);
  }

  final Measurer _measurer;
  final List<ProgressableFeature> features;

  MeasuredPolygon cutAndShift(double cuttingPoint) {
    // require(cuttingPoint in 0f..1f) { "Cutting point is expected to be between 0 and 1" }
    if (cuttingPoint < 0.0 || cuttingPoint > 1.0) {
      throw ArgumentError.value(
        cuttingPoint,
        "cuttingPoint",
        "Cutting point is expected to be between 0 and 1",
      );
    }
    if (cuttingPoint < distanceEpsilon) return this;

    // Find the index of cubic we want to cut
    final targetIndex = indexWhere(
      (it) =>
          cuttingPoint >= it.startOutlineProgress &&
          cuttingPoint <= it.endOutlineProgress,
    );
    final target = this[targetIndex];

    // if (DEBUG) {
    //     cubics.forEachIndexed { index, cubic ->
    //         debugLog(LOG_TAG) { "cut&Shift | cubic #$index : $cubic " }
    //     }
    //     debugLog(LOG_TAG) {
    //         "cut&Shift, cuttingPoint = $cuttingPoint, target = ($targetIndex) $target"
    //     }
    // }

    // Cut the target cubic.
    // b1, b2 are two resulting cubics after cut
    final (b1, b2) = target.cutAtProgress(cuttingPoint);
    // debugLog(LOG_TAG) { "Split | $target -> $b1 & $b2" }

    // Construct the list of the cubics we need:
    // * The second part of the target cubic (after the cut)
    // * All cubics after the target, until the end + All cubics from the start, before the
    //   target cubic
    // * The first part of the target cubic (before the cut)
    final retCubics = <Cubic>[b2.cubic];
    for (var i = 1; i < length; i++) {
      retCubics.add(this[(i + targetIndex) % length].cubic);
    }
    retCubics.add(b1.cubic);

    // Construct the array of outline progress.
    // For example, if we have 3 cubics with outline progress [0 .. 0.3], [0.3 .. 0.8] &
    // [0.8 .. 1.0], and we cut + shift at 0.6:
    // 0.  0123456789
    //     |--|--/-|-|
    // The outline progresses will start at 0 (the cutting point, that shifs to 0.0),
    // then 0.8 - 0.6 = 0.2, then 1 - 0.6 = 0.4, then 0.3 - 0.6 + 1 = 0.7,
    // then 1 (the cutting point again),
    // all together: (0.0, 0.2, 0.4, 0.7, 1.0)
    final List<double> retOutlineProgress = List.generate(length + 2, (index) {
      if (index == 0) return 0.0;
      if (index == length + 1) return 1.0;
      final cubicIndex = (targetIndex + index - 1) % length;
      return positiveModulo(
        this[cubicIndex].endOutlineProgress - cuttingPoint,
        1.0,
      );
    });

    // Shift the feature's outline progress too.
    final newFeatures = <ProgressableFeature>[
      for (int i = 0; i < features.length; i++)
        ProgressableFeature(
          positiveModulo(features[i].progress - cuttingPoint, 1.0),
          features[i].feature,
        ),
    ];

    // Filter out all empty cubics (i.e. start and end anchor are (almost) the same point.)
    return MeasuredPolygon._(
      _measurer,
      newFeatures,
      retCubics,
      retOutlineProgress,
    );
  }

  @internal
  static MeasuredPolygon measurePolygon(
    Measurer measurer,
    RoundedPolygon polygon,
  ) {
    final cubics = <Cubic>[];
    final featureToCubic = <(Feature, int)>[];

    // Get the cubics from the polygon, at the same time, extract the features and keep a
    // reference to the representative cubic we will use.
    for (
      var featureIndex = 0;
      featureIndex < polygon.features.length;
      featureIndex++
    ) {
      final feature = polygon.features[featureIndex];
      for (
        var cubicIndex = 0;
        cubicIndex < feature.cubics.length;
        cubicIndex++
      ) {
        if (feature is Corner && cubicIndex == feature.cubics.length ~/ 2) {
          featureToCubic.add((feature, cubics.length));
        }
        cubics.add(feature.cubics[cubicIndex]);
      }
    }
    // TODO(performance): Make changes to satisfy the lint warnings for unnecessary
    //  iterators creation.
    final List<double> measures = cubics
        .scan(0.0, (measure, cubic) {
          final result = measure + measurer.measureCubic(cubic);
          if (result < 0.0) {
            throw ArgumentError(
              "Measured cubic is expected to be greater or equal to zero",
            );
          }
          return result;
        })
        .toList(growable: false);
    final totalMeasure = measures.last;

    // Equivalent to `measures.map { it / totalMeasure }` but without Iterator allocation.
    final outlineProgress = <double>[
      for (int i = 0; i < measures.length; i++) measures[i] / totalMeasure,
    ];

    // debugLog(LOG_TAG) { "Total size: $totalMeasure" }

    final features = <ProgressableFeature>[
      for (int i = 0; i < featureToCubic.length; i++)
        ProgressableFeature(
          positiveModulo(
            (outlineProgress[featureToCubic[i].$2] +
                    outlineProgress[featureToCubic[i].$2 + 1]) /
                2.0,
            1.0,
          ),
          featureToCubic[i].$1,
        ),
    ];

    return MeasuredPolygon._(measurer, features, cubics, outlineProgress);
  }
}

/// Interface for measuring a cubic. Implementations can use whatever algorithm
/// desired to produce these measurement values.
@internal
abstract interface class Measurer {
  /// Returns size of given cubic, according to however the implementation wants
  /// to measure the size (angle, length, etc). It has to be greater or equal to 0.
  double measureCubic(Cubic c);

  /// Given a cubic and a measure that should be between 0 and the value
  /// returned by measureCubic (if not, it will be capped),
  /// finds the parameter t of the cubic at which that measure is reached.
  double findCubicCutPoint(Cubic c, double m);
}

/// A MeasuredCubic holds information about the cubic itself, the feature
/// (if any) associated with it, and the outline progress values (start and end)
/// for the cubic. This information is used to match cubics between shapes that
/// lie at similar outline progress positions along their respective shapes
/// (after matching features and shifting).
///
/// Outline progress is a value in [0..1) that represents the distance traveled
/// along the overall outline path of the shape.
@internal
final class MeasuredCubic {
  MeasuredCubic(
    this._owner,
    this.cubic,
    this._startOutlineProgress,
    this._endOutlineProgress,
  ) : measuredSize = _owner._measurer.measureCubic(cubic) {
    if (startOutlineProgress < 0.0 || startOutlineProgress > 1.0) {
      throw ArgumentError.value(
        startOutlineProgress,
        "startOutlineProgress",
        "startOutlineProgress must be between 0 and 1.",
      );
    }
    if (endOutlineProgress < 0.0 || endOutlineProgress > 1.0) {
      throw ArgumentError.value(
        endOutlineProgress,
        "endOutlineProgress",
        "endOutlineProgress must be between 0 and 1.",
      );
    }
    if (endOutlineProgress < startOutlineProgress) {
      throw ArgumentError(
        "endOutlineProgress is expected to be equal or greater than startOutlineProgress.",
      );
    }
  }

  final MeasuredPolygon _owner;
  final Cubic cubic;

  double _startOutlineProgress;
  double get startOutlineProgress => _startOutlineProgress;

  double _endOutlineProgress;
  double get endOutlineProgress => _endOutlineProgress;

  final double measuredSize;

  @internal
  void updateProgressRange({
    double? startOutlineProgress,
    double? endOutlineProgress,
  }) {
    startOutlineProgress ??= this.startOutlineProgress;
    endOutlineProgress ??= this.endOutlineProgress;
    if (endOutlineProgress < startOutlineProgress) {
      throw ArgumentError(
        "endOutlineProgress is expected to be equal or greater than startOutlineProgress.",
      );
    }
    _startOutlineProgress = startOutlineProgress;
    _endOutlineProgress = endOutlineProgress;
  }

  /// Cut this MeasuredCubic into two MeasuredCubics at the given outline progress value.
  (MeasuredCubic, MeasuredCubic) cutAtProgress(double cutOutlineProgress) {
    // Floating point errors further up can cause cutOutlineProgress to land just
    // slightly outside of the start/end progress for this cubic, so we limit it
    // to those bounds to avoid further errors later
    final boundedCutOutlineProgress = ui.clampDouble(
      cutOutlineProgress,
      startOutlineProgress,
      endOutlineProgress,
    );
    final outlineProgressSize = endOutlineProgress - startOutlineProgress;
    final progressFromStart = boundedCutOutlineProgress - startOutlineProgress;

    // Note that in earlier parts of the computation, we have empty MeasuredCubics (cubics
    // with progressSize == 0f), but those cubics are filtered out before this method is
    // called.
    final relativeProgress = progressFromStart / outlineProgressSize;
    final t = _owner._measurer.findCubicCutPoint(
      cubic,
      relativeProgress * measuredSize,
    );

    if (t < 0.0 || t > 1.0) {
      throw ArgumentError("Cubic cut point is expected to be between 0 and 1.");
    }

    // debugLog(LOG_TAG) {
    //     "cutAtProgress: progress = $boundedCutOutlineProgress / " +
    //         "this = [$startOutlineProgress .. $endOutlineProgress] / " +
    //         "ps = $progressFromStart / rp = $relativeProgress / t = $t"
    // }

    // c1/c2 are the two new cubics, then we return MeasuredCubics created from them
    final (c1, c2) = cubic.split(t);
    return (
      MeasuredCubic(
        _owner,
        c1,
        startOutlineProgress,
        boundedCutOutlineProgress,
      ),
      MeasuredCubic(_owner, c2, boundedCutOutlineProgress, endOutlineProgress),
    );
  }

  @override
  String toString() =>
      "MeasuredCubic("
      "outlineProgress: [$startOutlineProgress .. $endOutlineProgress], "
      "size: $measuredSize, "
      "cubic: $cubic"
      ")";
}

/// Approximates the arc lengths of cubics by splitting the arc into segments
/// and calculating their sizes. The more segments, the more accurate the result
/// will be to the true arc length. The default implementation has at least
/// 98.5% accuracy on the case of a circular arc, which is the worst case for
/// our standard shapes.
@internal
final class LengthMeasurer implements Measurer {
  const LengthMeasurer();

  @override
  double measureCubic(Cubic c) {
    return _closestProgressTo(c, double.infinity).$2;
  }

  @override
  double findCubicCutPoint(Cubic c, double m) {
    return _closestProgressTo(c, m).$1;
  }

  // The minimum number needed to achieve up to 98.5% accuracy from the true arc length
  // See PolygonMeasureTest.measureCircle
  static const int _segments = 3;

  (double, double) _closestProgressTo(Cubic cubic, double threshold) {
    var total = 0.0;
    var remainder = threshold;
    var prev = Point(cubic.anchor0X, cubic.anchor0Y);

    for (var i = 1; i <= _segments; i++) {
      final progress = i / _segments;
      final point = cubic.pointOnCurve(progress);
      final segment = (point - prev).getDistance();

      if (segment >= remainder) {
        return (progress - (1.0 - remainder / segment) / _segments, threshold);
      }

      remainder -= segment;
      total += segment;
      prev = point;
    }

    return (1.0, total);
  }
}

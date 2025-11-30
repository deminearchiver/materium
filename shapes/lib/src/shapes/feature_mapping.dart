import 'package:meta/meta.dart';

import 'features.dart';
import 'float_mapping.dart';
import 'point.dart';
import 'utils.dart';

@internal
typedef MeasuredFeatures = List<ProgressableFeature>;

@internal
@immutable
final class ProgressableFeature {
  const ProgressableFeature(this.progress, this.feature);

  final double progress;
  final Feature feature;

  @override
  String toString() =>
      "ProgressableFeature("
      "progress: $progress, "
      "feature: $feature"
      ")";

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is ProgressableFeature &&
            progress == other.progress &&
            feature == other.feature;
  }

  @override
  int get hashCode => Object.hash(runtimeType, progress, feature);
}

@internal
DoubleMapper featureMapper(
  MeasuredFeatures features1,
  MeasuredFeatures features2,
) {
  final filteredFeatures1 = [
    // Performance: Builds the list by avoiding creating an unnecessary Iterator
    // to iterate through the features1 List.
    for (int i = 0; i < features1.length; i++)
      if (features1[i].feature is Corner) features1[i],
  ];

  final filteredFeatures2 = [
    // Performance: Builds the list by avoiding creating an unnecessary Iterator
    // to iterate through the features2 List.
    for (int i = 0; i < features2.length; i++)
      if (features2[i].feature is Corner) features2[i],
  ];

  final featureProgressMapping = doMapping(
    filteredFeatures1,
    filteredFeatures2,
  );

  // debugLog(LOG_TAG) { featureProgressMapping.joinToString { "${it.first} -> ${it.second}" } }
  final dm = DoubleMapper(featureProgressMapping);
  // debugLog(LOG_TAG) {
  //     val N = 10
  //     "Map: " +
  //         (0..N).joinToString { i -> (dm.map(i.toFloat() / N)).toStringWithLessPrecision() } +
  //         "\nMb : " +
  //         (0..N).joinToString { i ->
  //             (dm.mapBack(i.toFloat() / N)).toStringWithLessPrecision()
  //         }
  // }
  return dm;
}

@internal
@immutable
final class DistanceVertex {
  const DistanceVertex(this.distance, this.f1, this.f2);

  final double distance;
  final ProgressableFeature f1;
  final ProgressableFeature f2;

  @override
  String toString() => "DistanceVertex(distance: $distance, f1: $f1, f2: $f2)";

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        runtimeType == other.runtimeType &&
            other is DistanceVertex &&
            distance == other.distance &&
            f1 == other.f1 &&
            f2 == other.f2;
  }

  @override
  int get hashCode => Object.hash(runtimeType, distance, f1, f2);
}

@internal
List<(double, double)> doMapping(
  List<ProgressableFeature> features1,
  List<ProgressableFeature> features2,
) {
  // debugLog(LOG_TAG) { "Shape1 progresses: " + features1.map { it.progress }.joinToString() }
  // debugLog(LOG_TAG) { "Shape2 progresses: " + features2.map { it.progress }.joinToString() }

  // TODO: consider a more
  final List<DistanceVertex> distanceVertexList =
      features1
          .expand(
            (f1) => features2.map((f2) {
              final d = featureDistSquared(f1.feature, f2.feature);
              return d != double.maxFinite ? DistanceVertex(d, f1, f2) : null;
            }),
          )
          .nonNulls
          .toList(growable: false)
        ..sort((a, b) => a.distance.compareTo(b.distance));

  // Special cases.
  if (distanceVertexList.isEmpty) return List.of(_identityMapping);
  if (distanceVertexList.length == 1) {
    final it = distanceVertexList.first;
    final f1 = it.f1.progress;
    final f2 = it.f2.progress;
    return [(f1, f2), ((f1 + 0.5) % 1, (f2 + 0.5) % 1)];
  }

  final mh = _MappingHelper();
  for (var i = 0; i < distanceVertexList.length; i++) {
    mh.addMapping(distanceVertexList[i].f1, distanceVertexList[i].f2);
  }
  return mh.mapping;
}

const List<(double, double)> _identityMapping = [(0.0, 0.0), (0.5, 0.5)];

final class _MappingHelper {
  _MappingHelper();

  // List of mappings from progress in the start shape to progress in the end shape.
  // We keep this list sorted by the first element.
  final List<(double, double)> mapping = <(double, double)>[];

  // Which features in the start shape have we used and which in the end shape.
  final Set<ProgressableFeature> _usedF1 = <ProgressableFeature>{};
  final Set<ProgressableFeature> _usedF2 = <ProgressableFeature>{};

  void addMapping(ProgressableFeature f1, ProgressableFeature f2) {
    // We don't want to map the same feature twice.
    if (_usedF1.contains(f1) || _usedF2.contains(f2)) return;

    // Ret is sorted, find where we need to insert this new mapping.
    // final index = mapping.binarySearchBy(f1.progress) { it.first }
    final index = binarySearchBy<(double, double), double>(
      mapping,
      (it) => it.$1,
      (a, b) => a.compareTo(b),
      f1.progress,
    );

    if (index >= 0) {
      throw ArgumentError(
        "There can't be two features with the same progress.",
      );
    }

    final insertionIndex = -index - 1;
    final n = mapping.length;

    // We can always add the first 1 element
    if (n >= 1) {
      final (before1, before2) = mapping[(insertionIndex + n - 1) % n];
      final (after1, after2) = mapping[insertionIndex % n];

      // We don't want features that are way too close to each other, that will make the
      // DoubleMapper unstable
      if (progressDistance(f1.progress, before1) < distanceEpsilon ||
          progressDistance(f1.progress, after1) < distanceEpsilon ||
          progressDistance(f2.progress, before2) < distanceEpsilon ||
          progressDistance(f2.progress, after2) < distanceEpsilon) {
        return;
      }

      // When we have 2 or more elements, we need to ensure we are not adding extra crossings.
      if (n > 1 && !progressInRange(f2.progress, before2, after2)) return;
    }

    // All good, we can add the mapping.
    mapping.insert(insertionIndex, (f1.progress, f2.progress));
    _usedF1.add(f1);
    _usedF2.add(f2);
  }
}

@internal
double featureDistSquared(Feature f1, Feature f2) {
  // TODO: We might want to enable concave-convex matching in some situations. If so, the
  //  approach below will not work
  if (f1 is Corner && f2 is Corner && f1.convex != f2.convex) {
    // Simple hack to force all features to map only to features of the same concavity, by
    // returning an infinitely large distance in that case
    // debugLog(LOG_TAG) { "*** Feature distance ∞ for convex-vs-concave corners" }
    return double.maxFinite;
  }
  return (featureRepresentativePoint(f1) - featureRepresentativePoint(f2))
      .getDistanceSquared();
}

// TODO: b/378441547 - Move to explicit parameter / expose?
@internal
Point featureRepresentativePoint(Feature feature) {
  final cubics = feature.cubics;
  final x = (cubics.first.anchor0X + cubics.last.anchor1X) / 2.0;
  final y = (cubics.first.anchor0Y + cubics.last.anchor1Y) / 2.0;
  return Point(x, y);
}

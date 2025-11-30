import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'utils.dart';

@internal
bool progressInRange(double progress, double progressFrom, double progressTo) =>
    progressTo >= progressFrom
    ? progress >= progressFrom && progress <= progressTo
    : progress >= progressFrom || progress <= progressTo;

@internal
double linearMap(List<double> xValues, List<double> yValues, double x) {
  // require(x in 0f..1f) { "Invalid progress: $x" }
  if (x < 0.0 || x > 1.0) {
    throw ArgumentError.value(x, "x", "Invalid progress.");
  }

  final segmentStartIndex = xValues.indices.firstWhere(
    (i) => progressInRange(x, xValues[i], xValues[(i + 1) % xValues.length]),
  );
  final segmentEndIndex = (segmentStartIndex + 1) % xValues.length;
  final segmentSizeX = positiveModulo(
    xValues[segmentEndIndex] - xValues[segmentStartIndex],
    1.0,
  );
  final segmentSizeY = positiveModulo(
    yValues[segmentEndIndex] - yValues[segmentStartIndex],
    1.0,
  );
  final positionInSegment = segmentSizeX < 0.001
      ? 0.5
      : positiveModulo(x - xValues[segmentStartIndex], 1.0) / segmentSizeX;
  return positiveModulo(
    yValues[segmentStartIndex] + segmentSizeY * positionInSegment,
    1.0,
  );
}

@internal
final class DoubleMapper {
  DoubleMapper(List<(double, double)> mappings)
    : _sourceValues = List.filled(mappings.length, 0.0),
      _targetValues = List.filled(mappings.length, 0.0) {
    for (var i = 0; i < mappings.length; i++) {
      _sourceValues[i] = mappings[i].$1;
      _targetValues[i] = mappings[i].$2;
    }
    validateProgress(_sourceValues);
    validateProgress(_targetValues);
  }

  final List<double> _sourceValues;
  final List<double> _targetValues;

  double map(double x) => linearMap(_sourceValues, _targetValues, x);

  double mapBack(double x) => linearMap(_targetValues, _sourceValues, x);

  static final DoubleMapper identity = DoubleMapper(const [
    (0.0, 0.0),
    (0.5, 0.5),
  ]);
}

@internal
void validateProgress(List<double> p) {
  var prev = p.last;
  var wraps = 0;
  for (var i = 0; i < p.length; i++) {
    final curr = p[i];
    if (curr < 0.0 || curr >= 1.0) {
      throw ArgumentError("FloatMapping - Progress outside of range: $p.");
    }
    if (progressDistance(curr, prev) <= distanceEpsilon) {
      throw ArgumentError("FloatMapping - Progress repeats a value: $p.");
    }
    if (curr < prev) {
      wraps++;
      if (wraps > 1) {
        throw ArgumentError("FloatMapping - Progress wraps more than once: $p");
      }
    }
    prev = curr;
  }
}

@internal
double progressDistance(double p1, double p2) {
  final it = (p1 - p2).abs();
  return math.min(it, 1.0 - it);
}

extension IterableExtensions<T> on Iterable<T> {
  Iterable<int> get indices sync* {
    var index = 0;
    for (final _ in this) {
      yield index++;
    }
  }
}

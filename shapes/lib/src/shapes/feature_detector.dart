import 'package:meta/meta.dart';

import 'cubic.dart';
import 'features.dart';

@internal
List<Feature> detectFeatures(List<Cubic> cubics) {
  final List<Feature> result = [];

  if (cubics.isEmpty) return result;

  // TODO: b/372651969 Try different heuristics for corner grouping

  var current = cubics.first;

  // Do one roundabout in which (current == last, next == first) is the last
  // iteration. Just like a snowball, subsequent cubics that align to one
  // feature merge until the streak breaks, the result is added, and a new
  // streak starts.
  for (var i = 0; i < cubics.length; i++) {
    final next = cubics[(i + 1) % (cubics.length)];

    if (i < cubics.length - 1 && current.alignsIshWith(next)) {
      current = Cubic.extend(current, next);
      continue;
    }

    result.add(current.asFeature(next));

    if (!current.smoothesIntoIsh(next)) {
      result.add(
        Cubic.empty(current.anchor1X, current.anchor1Y).asFeature(next),
      );
    }

    current = next;
  }

  return result;
}

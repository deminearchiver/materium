import 'package:materium/flutter.dart';

export 'package:motor/motor.dart';

extension SpringDescriptionExtension on SpringDescription {
  SpringDescription copyWith({
    double? mass,
    double? stiffness,
    double? damping,
  }) => mass != null || stiffness != null || damping != null
      ? .new(
          mass: mass ?? this.mass,
          stiffness: stiffness ?? this.stiffness,
          damping: damping ?? this.damping,
        )
      : this;

  SpringDescription copyWithDampingRatio({
    double? mass,
    double? stiffness,
    double? ratio,
  }) => mass != null || stiffness != null || ratio != null
      ? ratio != null
            ? .withDampingRatio(
                mass: mass ?? this.mass,
                stiffness: stiffness ?? this.stiffness,
                ratio: ratio,
              )
            : .new(
                mass: mass ?? this.mass,
                stiffness: stiffness ?? this.stiffness,
                damping: damping,
              )
      : this;

  SpringDescription copyWithDurationAndBounce({
    Duration? duration,
    double? bounce,
  }) => duration != null || bounce != null
      ? .withDurationAndBounce(
          duration: duration ?? this.duration,
          bounce: bounce ?? this.bounce,
        )
      : this;
}

extension SpringExtension on Spring {
  SpringMotion toMotion({bool snapToEnd = false}) =>
      SpringMotion(toSpringDescription(), snapToEnd: snapToEnd);
}

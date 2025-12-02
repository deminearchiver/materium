import 'package:material/src/material/flutter.dart';

extension AnimatableExtensions<T> on Animatable<T> {
  Animatable<T> get reversed => _ReversedAnimatable(this);

  Animatable<T> mapPoint(AnimatableMapPointCallback callback) =>
      _MapPointAnimatable(this, callback);

  Animatable<U> mapValue<U>(AnimatableMapValueCallback<T, U> callback) =>
      _MapValueAnimatable(this, callback);

  Animatable<T> clampPoint(double min, double max) =>
      mapPoint((t) => clampDouble(t, min, max));

  Animatable<T> mapPointToInterval(
    double begin,
    double end, [
    Curve curve = Curves.linear,
  ]) {
    assert(begin >= 0.0);
    assert(begin <= 1.0);
    assert(end >= 0.0);
    assert(end <= 1.0);
    assert(end >= begin);
    return mapPoint((t) {
      t = clampDouble((t - begin) / (end - begin), 0.0, 1.0);
      return t == 0.0 || t == 1.0 ? t : curve.transform(t);
    });
  }
}

extension NullableAnimatableExtensions<T> on Animatable<T?> {
  Animatable<T> get nonNull => _NonNullAnimatable(this);
}

class _ReversedAnimatable<T> extends Animatable<T> {
  const _ReversedAnimatable(this._parent);

  final Animatable<T> _parent;

  @override
  T transform(double t) => _parent.transform(1.0 - t);

  @override
  String toString() => "$_parent.reversed";
}

typedef AnimatableMapValueCallback<From, To> = To Function(From value);
typedef AnimatableMapPointCallback = double Function(double t);

class _MapPointAnimatable<T> extends Animatable<T> {
  const _MapPointAnimatable(this._parent, this._callback);

  final Animatable<T> _parent;
  final AnimatableMapPointCallback _callback;

  @override
  T transform(double t) => _parent.transform(_callback(t));
}

class _MapValueAnimatable<From, To> extends Animatable<To> {
  const _MapValueAnimatable(this._parent, this._callback);

  final Animatable<From> _parent;
  final AnimatableMapValueCallback<From, To> _callback;

  @override
  To transform(double t) => _callback(_parent.transform(t));

  @override
  String toString() {
    return "$_parent";
  }
}

class _NonNullAnimatable<T> extends Animatable<T> {
  const _NonNullAnimatable(this._parent);

  final Animatable<T?> _parent;

  @override
  T transform(double t) {
    final value = _parent.transform(t);
    assert(value != null);
    return value!;
  }
}

extension AnimationExtensions<T> on Animation<T> {
  Animation<U> mapValue<U>(AnimatableMapValueCallback<T, U> callback) =>
      _AnimationMapValue(this, callback);

  Animation<T> mapStatus(AnimationMapStatusCallback callback) =>
      _AnimationMapStatus(this, callback);
}

extension NullableAnimationExtensions<T extends Object> on Animation<T?> {
  Animation<T> get nonNull => mapValue((value) {
    assert(value != null);
    return value!;
  });

  Animation<T> nonNullOr(T defaultValue) =>
      mapValue((value) => value ?? defaultValue);

  Animation<T> nonNullOrElse(ValueGetter<T> defaultValueGetter) =>
      mapValue((value) => value ?? defaultValueGetter());
}

class _AnimationMapValue<T, U> extends Animation<U>
    with
        AnimationLazyListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  _AnimationMapValue(this._parent, this._callback);

  final Animation<T> _parent;
  final AnimatableMapValueCallback<T, U> _callback;

  @override
  void didStartListening() {
    _parent
      ..addListener(notifyListeners)
      ..addStatusListener(notifyStatusListeners);
  }

  @override
  void didStopListening() {
    _parent
      ..removeStatusListener(notifyStatusListeners)
      ..removeListener(notifyListeners);
  }

  @override
  AnimationStatus get status => _parent.status;

  @override
  U get value => _callback(_parent.value);
}

typedef AnimationMapStatusCallback =
    AnimationStatus Function(AnimationStatus status);

class _AnimationMapStatus<T> extends Animation<T>
    with
        AnimationLazyListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  _AnimationMapStatus(this._parent, this._callback);

  final Animation<T> _parent;
  final AnimationMapStatusCallback _callback;

  @override
  void didStartListening() {
    _parent
      ..addListener(notifyListeners)
      ..addStatusListener(notifyStatusListeners);
  }

  @override
  void didStopListening() {
    _parent
      ..removeStatusListener(notifyStatusListeners)
      ..removeListener(notifyListeners);
  }

  @override
  AnimationStatus get status => _callback(_parent.status);

  @override
  T get value => _parent.value;
}

// class _NonNullAnimatable<T> extends Animatable<T> {
//   const _NonNullAnimatable(this._parent);

//   final Animatable<T?> _parent;

//   @override
//   T transform(double t) {
//     final value = _parent.transform(t);
//     assert(value != null);
//     return value!;
//   }
// }

class _NonNullAnimation<T extends Object> extends Animation<T>
    with
        AnimationLazyListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  _NonNullAnimation(this._parent);

  final Animation<T?> _parent;

  @override
  void didStartListening() {
    _parent
      ..addListener(notifyListeners)
      ..addStatusListener(notifyStatusListeners);
  }

  @override
  void didStopListening() {
    _parent
      ..removeStatusListener(notifyStatusListeners)
      ..removeListener(notifyListeners);
  }

  @override
  AnimationStatus get status => _parent.status;

  @override
  T get value {
    final value = _parent.value;
    assert(value != null);
    return value!;
  }
}

extension IntervalExtension on Interval {
  Interval copyWith({double? begin, double? end, Curve? curve}) =>
      begin != null || end != null || curve != null
      ? Interval(
          begin ?? this.begin,
          end ?? this.end,
          curve: curve ?? this.curve,
        )
      : this;
}

import 'package:collection/collection.dart';
import 'package:material/src/material/flutter.dart';

typedef TweenBuilder<T extends Object?> = Tween<T> Function(T value);

abstract class ImplicitAnimation<T extends Object?> extends Animation<T>
    with
        AnimationEagerListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  ImplicitAnimation() {
    controller
      ..addListener(notifyListeners)
      ..addStatusListener(notifyStatusListeners);
    buildTween();
  }

  @protected
  AnimationController get controller;

  @protected
  Animation<double> get animation;

  Tween<T>? _tween;

  @protected
  Tween<T>? get tween => _tween;

  @protected
  set tween(Tween<T>? value) {
    if (_tween == value) {
      return;
    }
    _tween = value;
  }

  TweenBuilder<T> get builder;
  T get targetValue;
  set value(T value);

  @protected
  TickerFuture animate();

  @protected
  TickerFuture? startAnimation({T? from, T? to}) {
    if (!buildTween()) return null;
    final tween = _tween;
    _tween = tween
      ?..begin = from ?? tween.evaluate(animation)
      ..end = to ?? targetValue;
    return animate();
  }

  @protected
  bool buildTween() {
    var shouldStartAnimation = false;
    var tween = _tween;
    if (targetValue != null) {
      tween ??= builder(targetValue);
      if (targetValue != (tween.end ?? tween.begin)) {
        shouldStartAnimation = true;
      } else {
        tween.end ??= tween.begin;
      }
    } else {
      tween = null;
    }
    _tween = tween;
    return shouldStartAnimation;
  }

  @override
  AnimationStatus get status => animation.status;

  @override
  T get value => _tween?.evaluate(animation) ?? targetValue;

  @override
  String toStringDetails() => controller.toStringDetails();
}

class CurveImplicitAnimation<T extends Object?> extends ImplicitAnimation<T> {
  CurveImplicitAnimation({
    String? debugLabel,
    required TickerProvider vsync,
    required Duration duration,
    Curve curve = Curves.linear,
    required T initialValue,
    required TweenBuilder<T> builder,
  }) : _curve = curve,
       _targetValue = initialValue,
       _builder = builder,
       controller = AnimationController(
         debugLabel: debugLabel,
         vsync: vsync,
         duration: duration,
       ),
       super();

  @override
  final AnimationController controller;

  late CurvedAnimation _animation = _createAnimation();

  @override
  Animation<double> get animation => _animation;

  @override
  AnimationStatus get status => _animation.status;

  T get _value => _tween?.evaluate(_animation) ?? _targetValue;

  @override
  T get value => _value;

  @override
  set value(T newValue) {
    if (_value == newValue &&
        _targetValue == newValue &&
        !controller.isAnimating) {
      return;
    }
    _targetValue = newValue;
    _tween
      ?..begin = _targetValue
      ..end = _targetValue;
    controller.value = 0.0;
  }

  @override
  void dispose() {
    _animation.dispose();
    controller.dispose();
    super.dispose();
  }

  Duration get duration {
    assert(controller.duration != null);
    return controller.duration!;
  }

  set duration(Duration value) {
    if (controller.duration == value) {
      return;
    }
    controller.duration = value;
    startAnimation();
  }

  Curve _curve;

  Curve get curve => _curve;

  set curve(Curve value) {
    if (_curve == value) return;
    _curve = value;
    _animation.dispose();
    _animation = _createAnimation();
    startAnimation();
  }

  TweenBuilder<T> _builder;

  @override
  TweenBuilder<T> get builder => _builder;

  set builder(TweenBuilder<T> value) {
    if (_builder == value) return;
    _builder = value;
    final current = _tween?.evaluate(_animation);
    startAnimation(from: current);
  }

  T _targetValue;

  @override
  T get targetValue => _targetValue;

  set targetValue(T value) {
    if (_targetValue == value) return;
    _targetValue = value;
    startAnimation();
  }

  @override
  TickerFuture animate() => controller.forward(from: 0.0);

  CurvedAnimation _createAnimation() =>
      CurvedAnimation(parent: controller, curve: _curve);
}

class SpringImplicitAnimation<T extends Object?> extends ImplicitAnimation<T> {
  SpringImplicitAnimation({
    String? debugLabel,
    required TickerProvider vsync,
    required SpringDescription spring,
    required T initialValue,
    required TweenBuilder<T> builder,
  }) : _spring = spring,
       _targetValue = initialValue,
       _builder = builder,
       controller = .unbounded(vsync: vsync, debugLabel: debugLabel),
       super();

  @override
  final AnimationController controller;

  @override
  Animation<double> get animation => controller;

  SpringDescription _spring;

  SpringDescription get spring => _spring;

  set spring(SpringDescription value) {
    if (_spring == value) return;
    _spring = value;
    startAnimation();
  }

  TweenBuilder<T> _builder;

  @override
  TweenBuilder<T> get builder => _builder;

  set builder(TweenBuilder<T> value) {
    if (_builder == value) return;
    _builder = value;
    final current = tween?.evaluate(controller);
    tween = null;
    startAnimation(from: current);
  }

  T _targetValue;

  @override
  T get targetValue => _targetValue;

  set targetValue(T value) {
    if (_targetValue == value) return;
    _targetValue = value;
    startAnimation();
  }

  @override
  set value(T newValue) {
    if (value == newValue &&
        _targetValue == newValue &&
        !controller.isAnimating) {
      return;
    }
    _targetValue = newValue;
    _tween
      ?..begin = _targetValue
      ..end = _targetValue;
    controller.value = 0.0;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  TickerFuture animate() => controller.animateWith(_createSimulation());

  Simulation _createSimulation() =>
      SpringSimulation(_spring, 0.0, 1.0, 1.0, snapToEnd: true);
}

// class DualWeightedAnimation<T> extends Animation<T>
//     with
//         AnimationLazyListenerMixin,
//         AnimationLocalListenersMixin,
//         AnimationLocalStatusListenersMixin {
//   DualWeightedAnimation({
//     required Animation<T> begin,
//     required Animation<T> end,
//     required Animation<double> weight,
//     required Tween<T> Function(T begin, T end) buildTween,
//   }) : _begin = begin,
//        _end = end,
//        _weight = weight,
//        _buildTween = buildTween {
//     _beginValue = begin.value;
//     _endValue = end.value;
//   }

//   Animation<T> _begin;
//   Animation<T> get begin => _begin;
//   set begin(Animation<T> value) {
//     if (_begin == value) {
//       return;
//     }
//     if (isListening) {
//       _begin.removeListener(_beginListener);
//       _begin.removeStatusListener(_beginStatusListener);
//       value.addListener(_beginListener);
//       value.addStatusListener(_beginStatusListener);
//     }
//     _beginValue = value.value;
//     _begin = value;
//   }

//   Animation<T> _end;
//   Animation<T> get end => _end;
//   set end(Animation<T> value) {
//     if (_end == value) {
//       return;
//     }
//     if (isListening) {
//       _end.removeListener(_endListener);
//       _end.removeStatusListener(_endStatusListener);
//       value.addListener(_endListener);
//       value.addStatusListener(_endStatusListener);
//     }
//     _endValue = value.value;
//     _end = value;
//   }

//   Animation<double> _weight;
//   Animation<double> get weight => _weight;
//   set weight(Animation<double> value) {
//     if (_weight == value) {
//       return;
//     }
//     _weight.removeListener(notifyListeners);
//     _weight = value;
//     _weight.addListener(notifyListeners);
//   }

//   final Tween<T> Function(T begin, T end) _buildTween;

//   T? _beginValue;
//   T? _endValue;

//   void _beginListener() {
//     _beginValue = begin.value;
//     if (weight.isDismissed || weight.isAnimating) {
//       notifyListeners();
//     }
//   }

//   void _beginStatusListener(AnimationStatus _) {
//     if (weight.isDismissed || weight.isAnimating) {
//       notifyStatusListeners(_status);
//     }
//   }

//   void _endListener() {
//     _endValue = end.value;
//     if (weight.isCompleted || weight.isAnimating) {
//       notifyListeners();
//     }
//   }

//   void _endStatusListener(_) {
//     if (weight.isCompleted || weight.isAnimating) {
//       notifyStatusListeners(_status);
//     }
//   }

//   @override
//   void didStartListening() {
//     begin.addListener(_beginListener);
//     begin.addStatusListener(_beginStatusListener);
//     end.addListener(_endListener);
//     end.addStatusListener(_endStatusListener);
//     weight.addListener(notifyListeners);
//   }

//   @override
//   void didStopListening() {
//     begin.removeListener(_beginListener);
//     begin.removeStatusListener(_beginStatusListener);
//     end.removeListener(_endListener);
//     end.removeStatusListener(_endStatusListener);
//     weight.removeListener(notifyListeners);
//   }

//   AnimationStatus get _status => switch (weight.status) {
//     .reverse => begin.status,
//     .dismissed => begin.status,
//     .forward => end.status,
//     .completed => end.status,
//   };

//   @override
//   AnimationStatus get status => _status;

//   @override
//   T get value => _buildTween(_beginValue as T, _endValue as T).evaluate(weight);

//   @override
//   String toString() {
//     return "${objectRuntimeType(this, "WeightedAnimation")}($begin, $end, $weight)";
//   }
// }

typedef WeightsFunction<T extends Object?> =
    T Function(List<T> values, List<double> weights);

abstract class WeightAnimation<T extends Object?> extends Animation<T>
    with
        AnimationLazyListenerMixin,
        AnimationLocalListenersMixin,
        AnimationLocalStatusListenersMixin {
  WeightAnimation();

  factory WeightAnimation.fromWeights(
    Map<Animation<T>, Animation<double>> map,
    WeightsFunction<T> combine,
  ) = _WeightAnimationFromMap;

  factory WeightAnimation.fromTween({
    required Animation<T> begin,
    required Animation<T> end,
    required Animation<double> weight,
    required Tween<T> Function(T begin, T end) builder,
  }) = _WeightAnimationFromTween;
  // }) => WeightAnimation.fromWeights(
  //   {
  //     begin: weight, // Required for status calculation
  //     end: weight.mapValue((value) => 1.0 - value),
  //   },
  //   (values, weights) {
  //     assert(values.length == 2);
  //     assert(weights.length == 2);
  //     final tween = buildTween(values[0], values[1]);
  //     return tween.transform(weights[0]);
  //   },
  // );

  // Modification functionality was deprecated

  // Iterable<Animation<T>> get values => _items.values.map((item) => item.value);

  // Iterable<Animation<double>> get weights =>
  //     _items.values.map((item) => item.weight);

  // Animation<double>? operator [](Animation<T> value) => _items[value]?.weight;

  // void operator []=(Animation<T> value, Animation<double> weight) {
  //   final item = _items[value];
  //   if (item == null) return;
  //   // TODO: investigate if this is needed and if this scenario can even occur
  //   // Currently it is just a safeguard
  //   if (!isListening) {
  //     item.removeValueListener();
  //     item.removeValueStatusListener();
  //     item.removeWeightListener();
  //     item.removeWeightStatusListener();
  //   }
  //   item.weight = weight;
  // }

  @override
  void didStartListening();

  @override
  void didStopListening();

  @override
  AnimationStatus get status;

  @override
  T get value;

  @override
  String toString() => "${objectRuntimeType(this, "WeightAnimation")}<$T>()";

  static double calculateTotalWeight(List<double> weights) {
    var totalWeight = 0.0;
    for (var i = 0; i < weights.length; i++) {
      final weight = weights[i];
      assert(weight >= 0.0);
      totalWeight += weight;
    }
    assert(totalWeight > 0.0);
    return totalWeight;
  }

  static double combineDouble(List<double> values, List<double> weights) {
    assert(values.length == weights.length);
    final totalWeight = calculateTotalWeight(weights);
    var result = 0.0;
    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      final weight = weights[i];
      final fraction = weight / totalWeight;
      final adjustedValue = value * fraction;
      result += adjustedValue;
    }
    return result;
  }
}

class _WeightAnimationFromMap<T extends Object?> extends WeightAnimation<T> {
  _WeightAnimationFromMap(
    Map<Animation<T>, Animation<double>> map,
    WeightsFunction<T> combine,
  ) : assert(map.length >= 2, "Need at least 2 animations"),
      _items = map.map(
        (key, value) => MapEntry(key, _AnimationWeight(key, value)),
      ),
      _combine = combine;

  final Map<Animation<T>, _AnimationWeight<T>> _items;
  final WeightsFunction<T> _combine;

  @override
  void didStartListening() {
    for (final item in _items.values) {
      item
        ..addValueListener((_, _) {
          notifyListeners();
        })
        ..addValueStatusListener((_, _, _) {
          notifyStatusListeners(status);
        })
        ..addWeightListener((_, _) {
          notifyListeners();
        });
    }
  }

  @override
  void didStopListening() {
    for (final item in _items.values) {
      item
        ..removeValueListener()
        ..removeValueStatusListener()
        ..removeWeightListener()
        ..removeWeightStatusListener();
    }
  }

  @override
  AnimationStatus get status {
    final List<AnimationStatus> statuses = _items.values
        .map((item) => item.value.status)
        .toList(growable: false);
    final List<double> weights = _items.values
        .map((item) => item.weight.value)
        .toList(growable: false);
    return _calculateAnimationStatus(statuses, weights);
  }

  @override
  T get value {
    final List<T> values = _items.values
        .map((item) => item.value.value)
        .toList(growable: false);
    final List<double> weights = _items.values
        .map((item) => item.weight.value)
        .toList(growable: false);
    return _combine(values, weights);
  }

  static AnimationStatus _calculateAnimationStatus(
    List<AnimationStatus> statuses,
    List<double> weights,
  ) {
    assert(statuses.length == weights.length);
    final totalWeight = WeightAnimation.calculateTotalWeight(weights);
    final statusToWeight = <AnimationStatus, double>{};
    for (var i = 0; i < statuses.length; i++) {
      final status = statuses[i];
      final weight = weights[i];
      statusToWeight.update(
        status,
        (value) => value + weight,
        ifAbsent: () => weight,
      );
    }
    assert(totalWeight == statusToWeight.values.reduce((a, b) => a + b));
    final result = maxBy(
      statusToWeight.entries,
      (entry) => entry.value,
      compare: (a, b) => a.compareTo(b),
    );
    assert(result != null);
    return result!.key;
  }
}

class _WeightAnimationFromTween<T extends Object?> extends WeightAnimation<T> {
  _WeightAnimationFromTween({
    required Animation<T> begin,
    required Animation<T> end,
    required Animation<double> weight,
    required Tween<T> Function(T begin, T end) builder,
  }) : _begin = begin,
       _end = end,
       _weight = weight,
       _builder = builder;
  //  _tween = builder(begin.value, end.value);

  final Animation<T> _begin;
  final Animation<T> _end;
  final Animation<double> _weight;
  final Tween<T> Function(T begin, T end) _builder;
  // final Tween<T> _tween;

  void _beginListener() {
    notifyListeners();
  }

  void _beginStatusListener(AnimationStatus status) {
    notifyStatusListeners(status);
  }

  void _endListener() {
    notifyListeners();
  }

  void _endStatusListener(AnimationStatus status) {
    notifyStatusListeners(status);
  }

  void _weightListener() {
    notifyListeners();
  }

  @override
  void didStartListening() {
    _begin.addListener(_beginListener);
    _begin.addStatusListener(_beginStatusListener);
    _end.addListener(_endListener);
    _end.addStatusListener(_endStatusListener);
    _weight.addListener(_weightListener);
  }

  @override
  void didStopListening() {
    _weight.removeListener(_weightListener);
    _end.removeStatusListener(_endStatusListener);
    _end.removeListener(_endListener);
    _begin.removeStatusListener(_beginStatusListener);
    _begin.removeListener(_beginListener);
  }

  @override
  AnimationStatus get status =>
      _weight.value <= 0.5 ? _begin.status : _end.status;

  @override
  T get value => _builder(_begin.value, _end.value).evaluate(_weight);
}

typedef _Listener<T extends Object?> =
    void Function(_AnimationWeight item, Animation<T> animation);
typedef _StatusListener<T extends Object?> =
    void Function(
      _AnimationWeight item,
      Animation<T> animation,
      AnimationStatus status,
    );

class _AnimationWeight<T extends Object?> {
  _AnimationWeight(this._value, this._weight);

  Animation<T> _value;
  Animation<T> get value => _value;
  set value(Animation<T> value) {
    if (_value == value) return;
    if (_valueListener case final listener?) {
      _value.removeListener(listener);
      value.addListener(listener);
    }
    if (_valueStatusListener case final listener?) {
      _value.removeStatusListener(listener);
      value.addStatusListener(listener);
    }
    _value = value;
  }

  Animation<double> _weight;
  Animation<double> get weight => _weight;
  set weight(Animation<double> value) {
    if (_weight == value) return;
    if (_weightListener case final listener?) {
      _weight.removeListener(listener);
      value.addListener(listener);
    }
    if (_weightStatusListener case final listener?) {
      _weight.removeStatusListener(listener);
      value.addStatusListener(listener);
    }
    _weight = value;
  }

  VoidCallback? _valueListener;
  AnimationStatusListener? _valueStatusListener;
  VoidCallback? _weightListener;
  AnimationStatusListener? _weightStatusListener;

  void addValueListener(_Listener<T> listener) {
    void callback() => listener(this, value);

    value.addListener(callback);
    _valueListener = callback;
  }

  void addValueStatusListener(_StatusListener<T> listener) {
    void callback(AnimationStatus status) => listener(this, value, status);
    value.addStatusListener(callback);
    _valueStatusListener = callback;
  }

  void addWeightListener(_Listener<double> listener) {
    void callback() => listener(this, weight);
    weight.addListener(callback);
    _weightListener = callback;
  }

  void addWeightStatusListener(_StatusListener<double> listener) {
    void callback(AnimationStatus status) => listener(this, weight, status);
    weight.addStatusListener(callback);
    _weightStatusListener = callback;
  }

  void removeValueListener() {
    if (_valueListener case final listener?) {
      value.removeListener(listener);
      _valueListener = null;
    }
  }

  void removeValueStatusListener() {
    if (_valueStatusListener case final listener?) {
      value.removeStatusListener(listener);
      _valueStatusListener = null;
    }
  }

  void removeWeightListener() {
    if (_weightListener case final listener?) {
      weight.removeListener(listener);
      _weightListener = null;
    }
  }

  void removeWeightStatusListener() {
    if (_weightStatusListener case final listener?) {
      weight.removeStatusListener(listener);
      _weightStatusListener = null;
    }
  }
}

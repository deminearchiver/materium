abstract base class _Wrapped<T extends Object?> {
  const _Wrapped();

  T get _;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      runtimeType == other.runtimeType && other is _Wrapped<T> && _ == other._;

  @override
  int get hashCode => Object.hash(runtimeType, _);
}

final class Outer<T extends Object?> extends _Wrapped<(T,)> {
  const Outer._(this._);
  const Outer(T value) : this._((value,));

  @override
  final (T,) _;

  T get inner => _.$1;

  Option<T> toOption() => Some(inner);

  Result<T, E> toResult<E extends Object>() => Success<T, E>(inner);

  static Outer<T>? fromOption<T extends Object?>(Option<T> value) =>
      switch (value) {
        Some(:final value) => Outer(value),
        None() => null,
      };

  static Outer<T>? fromResult<T extends Object?>(Result<T, Object?> value) =>
      switch (value) {
        Success(:final value) => Outer(value),
        Failure() => null,
      };
}

sealed class Option<T extends Object?> extends _Wrapped<(T,)?> {
  const Option._();

  const factory Option.some(T value) = Some<T>;

  const factory Option.none() = None;

  Option<U> and<U extends Object?>(Option<U> other);

  Option<U> andThen<U extends Object?>(Option<U> Function(T value) fn);

  Option<T> filter(bool Function(T value) predicate);

  Option<T> or(Option<T> other);

  Option<T> orElse(Option<T> Function() fn);

  Option<T> xor(Option<T> other) => switch ((this, other)) {
    (final Some<T> a, None()) => a,
    (None(), final Some<T> b) => b,
    _ => const None(),
  };

  Option<T> inspect(void Function(T value) inspector) {
    if (this case Some(:final value)) {
      inspector(value);
    }
    return this;
  }

  bool get isSome;

  bool isSomeAnd(bool Function(T value) predicate);

  bool get isNone;

  bool isNoneOr(bool Function(T value) predicate);

  Option<U> map<U extends Object?>(U Function(T value) transformer);

  // T unwrap() => switch (this) {
  //   Some(:final value) => value,
  //   None() => throw StateError("Called `Option.unwrap()` on a `None` value"),
  // };

  T unwrapOr(T defaultValue) => switch (this) {
    Some(:final value) => value,
    None() => defaultValue,
  };

  T unwrapOrElse(T Function() fn) => switch (this) {
    Some(:final value) => value,
    None() => fn(),
  };

  Option<(T, U)> zip<U extends Object?>(Option<U> other) => (this, other).zip();

  Option<R> zipWith<U extends Object?, R extends Object?>(
    Option<U> other,
    R Function(T a, U b) combine,
  ) => (this, other).zipWith(combine);

  static Option<T> maybe<T extends Object>(T? value) =>
      value != null ? Some(value) : const None();
}

final class Some<T extends Object?> extends Option<T> {
  const Some._(this._) : super._();

  const Some(T value) : this._((value,));

  @override
  final (T,) _;

  T get value => _.$1;

  @override
  bool get isSome => true;

  @override
  bool isSomeAnd(bool Function(T value) predicate) => predicate(value);

  @override
  bool get isNone => false;

  @override
  bool isNoneOr(bool Function(T value) predicate) => predicate(value);

  @override
  Option<U> and<U extends Object?>(Option<U> other) => other;

  @override
  Option<U> andThen<U extends Object?>(Option<U> Function(T value) fn) =>
      fn(value);

  @override
  Some<T> or(Option<T> other) => this;

  @override
  Some<T> orElse(Option<T> Function() fn) => this;

  @override
  Option<T> filter(bool Function(T value) predicate) =>
      predicate(value) ? this : const None();

  @override
  Some<U> map<U extends Object?>(U Function(T value) transformer) =>
      Some(transformer(value));
}

final class None<T extends Object?> extends Option<T> {
  const None._(this._) : super._();

  const None() : this._(null);

  @override
  final Null _;

  @override
  bool get isSome => false;

  @override
  bool isSomeAnd(bool Function(T value) predicate) => false;

  @override
  bool get isNone => true;

  @override
  bool isNoneOr(bool Function(T value) predicate) => true;

  @override
  None<U> and<U extends Object?>(Option<U> other) => const None();

  @override
  None<U> andThen<U extends Object?>(Option<U> Function(T value) fn) =>
      const None();

  @override
  Option<T> or(Option<T> other) => other;

  @override
  Option<T> orElse(Option<T> Function() fn) => fn();

  @override
  None<T> filter(bool Function(T value) predicate) => this;

  @override
  None<U> map<U extends Object?>(U Function(T value) transformer) =>
      const None();
}

sealed class Result<T extends Object?, E extends Object?>
    extends _Wrapped<({(T,)? succsess, (E,)? failure})> {
  const Result._();

  const factory Result.success(T value) = Success;

  const factory Result.failure(E value) = Failure;

  Option<T> get success;

  Option<E> get failure;

  Result<U, E> and<U extends Object?>(Result<U, E> other);

  Result<U, E> andThen<U extends Object?>(
    Result<U, E> Function(T value) transform,
  );

  Result<U, E> map<U extends Object?>(U Function(T value) transform);
}

final class Success<T extends Object?, E extends Object?> extends Result<T, E> {
  const Success._(this._) : super._();

  const Success(T value) : this._((succsess: (value,), failure: null));

  @override
  final ({(T,) succsess, Null failure}) _;

  T get value => _.succsess.$1;

  @override
  Some<T> get success => Some(value);

  @override
  None<E> get failure => const None();

  @override
  Result<U, E> and<U extends Object?>(Result<U, E> other) => other;

  @override
  Result<U, E> andThen<U extends Object?>(
    Result<U, E> Function(T value) transform,
  ) => transform(value);

  @override
  Success<U, E> map<U extends Object?>(U Function(T value) transform) =>
      Success(transform(value));
}

final class Failure<T extends Object?, E extends Object?> extends Result<T, E> {
  const Failure._(this._) : super._();

  const Failure(E value) : this._((succsess: null, failure: (value,)));

  @override
  final ({Null succsess, (E,) failure}) _;

  E get value => _.failure.$1;

  @override
  None<T> get success => const None();

  @override
  Some<E> get failure => Some(value);

  @override
  Failure<U, E> and<U extends Object?>(Result<U, E> other) => Failure(value);

  @override
  Result<U, E> andThen<U extends Object?>(
    Result<U, E> Function(T value) transform,
  ) => Failure(value);

  @override
  Failure<U, E> map<U extends Object?>(U Function(T value) transform) =>
      Failure(value);
}

extension OptionOptionExtension<T extends Object?> on Option<Option<T>> {
  Option<T> flatten() => switch (this) {
    Some(:final value) => value,
    None() => const None(),
  };
}

extension Options2Extension<T1 extends Object?, T2 extends Object?>
    on (Option<T1>, Option<T2>) {
  Option<(T1, T2)> zip() => switch (this) {
    (Some(value: final x1), Some(value: final x2)) => Some((x1, x2)),
    _ => const None(),
  };

  Option<U> zipWith<U extends Object?>(U Function(T1, T2) combine) =>
      switch (this) {
        (Some(value: final x1), Some(value: final x2)) => Some(combine(x1, x2)),
        _ => const None(),
      };
}

extension Options3Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?
>
    on (Option<T1>, Option<T2>, Option<T3>) {
  Option<(T1, T2, T3)> zip() => switch (this) {
    (Some(value: final x1), Some(value: final x2), Some(value: final x3)) =>
      Some((x1, x2, x3)),
    _ => const None(),
  };

  Option<U> zipWith<U extends Object?>(U Function(T1, T2, T3) combine) =>
      switch (this) {
        (Some(value: final x1), Some(value: final x2), Some(value: final x3)) =>
          Some(combine(x1, x2, x3)),
        _ => const None(),
      };
}

extension Options4Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?,
  T4 extends Object?
>
    on (Option<T1>, Option<T2>, Option<T3>, Option<T4>) {
  Option<(T1, T2, T3, T4)> zip() => switch (this) {
    (
      Some(value: final x1),
      Some(value: final x2),
      Some(value: final x3),
      Some(value: final x4),
    ) =>
      Some((x1, x2, x3, x4)),
    _ => const None(),
  };

  Option<U> zipWith<U extends Object?>(U Function(T1, T2, T3, T4) combine) =>
      switch (this) {
        (
          Some(value: final x1),
          Some(value: final x2),
          Some(value: final x3),
          Some(value: final x4),
        ) =>
          Some(combine(x1, x2, x3, x4)),
        _ => const None(),
      };
}

extension Option2Extension<T1 extends Object?, T2 extends Object?>
    on Option<(T1, T2)> {
  (Option<T1>, Option<T2>) unzip() => switch (this) {
    Some(value: (final x1, final x2)) => (Some(x1), Some(x2)),
    _ => const (None(), None()),
  };
}

extension Option3Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?
>
    on Option<(T1, T2, T3)> {
  (Option<T1>, Option<T2>, Option<T3>) unzip() => switch (this) {
    Some(value: (final x1, final x2, final x3)) => (
      Some(x1),
      Some(x2),
      Some(x3),
    ),
    _ => const (None(), None(), None()),
  };
}

extension Option4Extension<
  T1 extends Object?,
  T2 extends Object?,
  T3 extends Object?,
  T4 extends Object?
>
    on Option<(T1, T2, T3, T4)> {
  (Option<T1>, Option<T2>, Option<T3>, Option<T4>) unzip() => switch (this) {
    Some(value: (final x1, final x2, final x3, final x4)) => (
      Some(x1),
      Some(x2),
      Some(x3),
      Some(x4),
    ),
    _ => const (None(), None(), None(), None()),
  };
}

extension OptionResultExtension<T extends Object?, E extends Object?>
    on Option<Result<T, E>> {
  Result<Option<T>, E> transpose() => switch (this) {
    Some(value: Success(:final value)) => Success(Some(value)),
    Some(value: Failure(:final value)) => Failure(value),
    _ => const Success(None()),
  };
}

extension ResultOptionExtension<T extends Object?, E extends Object?>
    on Result<Option<T>, E> {
  Option<Result<T, E>> transpose() => switch (this) {
    Success(value: Some(:final value)) => Some(Success(value)),
    Success(value: None()) => const None(),
    Failure(:final value) => Some(Failure(value)),
  };
}

extension ResultResultExtension<T extends Object?, E extends Object?>
    on Result<Result<T, E>, E> {
  Result<T, E> flatten() => switch (this) {
    Success(:final value) => value,
    Failure(:final value) => Failure(value),
  };
}

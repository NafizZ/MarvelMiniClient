import 'dart:async';

sealed class Result<S, F> {
  const Result._();

  B fold<B>(B Function(S s) ifSuccess, B Function(F f) ifFailure);

  /// This function applies a transformation to the success value of the Result,
  /// and returns a new Result that contains the transformed value. If the Result
  /// represents an error, the transformation is not applied and
  /// the error is propagated to the new Result.
  Result<S2, F> map<S2>(S2 Function(S s) f) =>
      fold((S s) => success(f(s)), failure);

  /// Similar to map, but the transformation function returns a Result
  /// rather than a raw value. This is useful when the transformation itself can fail.
  Result<S2, F> flatMap<S2>(Result<S2, F> Function(S s) f) => fold(f, failure);

  /// An asynchronous version of flatMap.
  /// The transformation function is asynchronous (returns a Future<Result>) and
  /// so is asyncFlatMap itself.
  Future<Result<S2, F>> asyncFlatMap<S2>(
    Future<Result<S2, F>> Function(S s) f,
  ) =>
      fold(f, (error) => Future.value(failure(error)));

  /// Similar to map, but doesn't return a new Result. Instead, it simply applies
  /// a function for its side effects and returns nothing. If the Result is an error,
  /// the function is not applied.
  FutureOr<void> forEach<T>(FutureOr<T> Function(S) f) => fold(f, (_) {});

  /// Returns the success value if the Result represents a success, and defaultValue's
  /// result if it represents an error.
  S getOrElse(S Function() defaultValue) =>
      fold((s) => s, (_) => defaultValue());

  /// Returns the success value if the Result represents a success, and null
  /// if it represents an error.
  S? getOrNull() => fold((s) => s, (_) => null);

  /// Constructs a Result from a Future. If the Future completes successfully,
  /// the Result is a success with the value of the Future. If the Future fails,
  /// the Result is an error with the error of the Future.
  static Future<Result<T, Exception>> fromAsync<T>(
    Future<T> Function() func,
  ) async {
    try {
      final result = await func();
      return success(result);
    } on Exception catch (e) {
      return failure(e);
      // ignore: avoid_catching_errors
    } on Error catch (e) {
      return failure(Exception('${e.runtimeType}: ${e.stackTrace}'));
    }
  }

  ///  Constructs a Result by running a function. If the function returns normally,
  /// the Result is a success with the return value of the function. If the function
  /// throws an exception, the Result is an error with the thrown exception.
  static Result<T, Exception> fromAction<T>(T Function() func) {
    try {
      final result = func();
      return success(result);
    } on Exception catch (e) {
      return failure(e);
      // ignore: avoid_catching_errors
    } on Error catch (e) {
      return failure(Exception('${e.runtimeType}: ${e.stackTrace}'));
    }
  }

  /// Constructs a Result from a value that may be null. If the value is non-null,
  /// the Result is a success with that value. If the value is null, the Result
  /// is an error.
  static Result<T, Exception> fromNullable<T>(
    T? value,
    Exception Function() onError,
  ) {
    if (value != null) {
      return success(value);
    } else {
      return failure(onError());
    }
  }

  /// Constructs a Result by testing a condition. If the condition is true,
  /// the Result is a success with a certain value. If the condition is false,
  /// the Result is an error with a certain error.
  static Result<T, Exception> fromPredicate<T>(
    bool condition,
    T Function() onSuccess,
    Exception Function() onError,
  ) =>
      condition ? success(onSuccess()) : failure(onError());
}

/// A container for Failure values
class Failure<S, F> extends Result<S, F> {
  const Failure._(this._f) : super._();

  final F _f;

  F get value => _f;

  @override
  B fold<B>(B Function(S s) ifSuccess, B Function(F f) ifFailure) =>
      ifFailure(_f);

  @override
  bool operator ==(Object other) => other is Failure && other._f == _f;

  @override
  int get hashCode => _f.hashCode;
}

/// A container for Success values
class Success<S, F> extends Result<S, F> {
  const Success._(this._s) : super._();

  final S _s;

  S get value => _s;

  @override
  B fold<B>(B Function(S s) ifSuccess, B Function(F f) ifFailure) =>
      ifSuccess(_s);

  @override
  bool operator ==(Object other) => other is Success && other._s == _s;

  @override
  int get hashCode => _s.hashCode;
}

Result<S, F> failure<S, F>(F f) => Failure._(f); // helper function
Result<S, F> success<S, F>(S s) => Success._(s); // helper function

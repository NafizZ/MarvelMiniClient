/// This class will be used by class users in their methods
sealed class Result<S, F> {
  const Result._();

  B fold<B>(B Function(S s) ifSuccess, B Function(F f) ifFailure);
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
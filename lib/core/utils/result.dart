import 'package:saliena_app/core/error/failures.dart';

/// A Result type for handling success/failure without exceptions.
/// Inspired by Rust's Result type and functional programming patterns.
sealed class Result<T> {
  const Result();

  /// Creates a successful result.
  factory Result.success(T value) = Success<T>;

  /// Creates a failed result.
  factory Result.failure(Failure failure) = Fail<T>;

  /// Returns true if this is a success.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure.
  bool get isFailure => this is Fail<T>;

  /// Gets the value if success, throws if failure.
  T get value {
    if (this is Success<T>) {
      return (this as Success<T>)._value;
    }
    throw StateError('Cannot get value from Fail result');
  }

  /// Gets the failure if failed, throws if success.
  Failure get failure {
    if (this is Fail<T>) {
      return (this as Fail<T>)._failure;
    }
    throw StateError('Cannot get failure from Success result');
  }

  /// Gets the value or null.
  T? get valueOrNull => isSuccess ? value : null;

  /// Gets the value or a default.
  T getOrElse(T defaultValue) => isSuccess ? value : defaultValue;

  /// Maps the success value to a new type.
  Result<R> map<R>(R Function(T value) mapper) {
    if (this is Success<T>) {
      return Result.success(mapper(value));
    }
    return Result.failure(failure);
  }

  /// Maps the success value to a new Result.
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) {
    if (this is Success<T>) {
      return mapper(value);
    }
    return Result.failure(failure);
  }

  /// Folds the result into a single value.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    if (this is Success<T>) {
      return onSuccess(value);
    }
    return onFailure(failure);
  }

  /// Executes a side effect on success.
  Result<T> onSuccess(void Function(T value) action) {
    if (this is Success<T>) {
      action(value);
    }
    return this;
  }

  /// Executes a side effect on failure.
  Result<T> onFailure(void Function(Failure failure) action) {
    if (this is Fail<T>) {
      action(failure);
    }
    return this;
  }
}

/// Successful result containing a value.
final class Success<T> extends Result<T> {
  final T _value;
  const Success(this._value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Success($_value)';
}

/// Failed result containing a failure.
final class Fail<T> extends Result<T> {
  final Failure _failure;
  const Fail(this._failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Fail<T> &&
          runtimeType == other.runtimeType &&
          _failure == other._failure;

  @override
  int get hashCode => _failure.hashCode;

  @override
  String toString() => 'Fail($_failure)';
}

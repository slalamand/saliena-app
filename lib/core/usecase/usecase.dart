import 'package:saliena_app/core/utils/result.dart';

/// Base class for all use cases.
/// Use cases encapsulate a single piece of business logic.
/// 
/// Type parameters:
/// - [T]: The return type of the use case
/// - [Params]: The parameters required by the use case
abstract class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Use case that doesn't require any parameters.
abstract class NoParamsUseCase<T> {
  Future<Result<T>> call();
}

/// Use case that returns a stream instead of a future.
abstract class StreamUseCase<T, Params> {
  Stream<Result<T>> call(Params params);
}

/// Marker class for use cases that don't require parameters.
class NoParams {
  const NoParams();
}

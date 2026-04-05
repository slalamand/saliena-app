import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for getting the currently authenticated user.
class GetCurrentUser implements NoParamsUseCase<User?> {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  @override
  Future<Result<User?>> call() {
    return _repository.getCurrentUser();
  }
}

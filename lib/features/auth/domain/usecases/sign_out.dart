import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing out the current user.
class SignOut implements NoParamsUseCase<void> {
  final AuthRepository _repository;

  SignOut(this._repository);

  @override
  Future<Result<void>> call() {
    return _repository.signOut();
  }
}

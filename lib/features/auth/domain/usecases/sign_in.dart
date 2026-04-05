import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing in a user.
class SignIn implements UseCase<void, SignInParams> {
  final AuthRepository _repository;

  SignIn(this._repository);

  @override
  Future<Result<void>> call(SignInParams params) {
    return _repository.signIn(
      email: params.email,
    );
  }
}

/// Parameters for the SignIn use case.
class SignInParams {
  final String email;

  const SignInParams({
    required this.email,
  });
}

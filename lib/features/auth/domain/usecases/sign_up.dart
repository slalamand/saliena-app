import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for signing up a new user.
class SignUp implements UseCase<User, SignUpParams> {
  final AuthRepository _repository;

  SignUp(this._repository);

  @override
  Future<Result<User>> call(SignUpParams params) {
    return _repository.signUp(
      email: params.email,
      phone: params.phone,
      fullName: params.fullName,
    );
  }
}

/// Parameters for the SignUp use case.
class SignUpParams {
  final String email;
  final String phone;
  final String fullName;

  const SignUpParams({
    required this.email,
    required this.phone,
    required this.fullName,
  });
}

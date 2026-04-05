import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';

/// Use case for verifying phone OTP.
class VerifyPhoneOtp implements UseCase<void, VerifyPhoneOtpParams> {
  final AuthRepository _repository;

  VerifyPhoneOtp(this._repository);

  @override
  Future<Result<void>> call(VerifyPhoneOtpParams params) {
    return _repository.verifyPhoneOtp(
      phone: params.phone,
      otp: params.otp,
    );
  }
}

/// Parameters for the VerifyPhoneOtp use case.
class VerifyPhoneOtpParams {
  final String phone;
  final String otp;

  const VerifyPhoneOtpParams({
    required this.phone,
    required this.otp,
  });
}

/// Use case for verifying email OTP.
class VerifyEmailOtp implements UseCase<void, VerifyEmailOtpParams> {
  final AuthRepository _repository;

  VerifyEmailOtp(this._repository);

  @override
  Future<Result<void>> call(VerifyEmailOtpParams params) {
    return _repository.verifyEmailOtp(
      email: params.email,
      otp: params.otp,
    );
  }
}

/// Parameters for the VerifyEmailOtp use case.
class VerifyEmailOtpParams {
  final String email;
  final String otp;

  const VerifyEmailOtpParams({
    required this.email,
    required this.otp,
  });
}

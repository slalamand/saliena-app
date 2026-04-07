import 'package:saliena_app/core/error/exceptions.dart' as exceptions;
import 'package:saliena_app/core/error/failures.dart';
import 'package:saliena_app/core/network/network_info.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';
import 'package:saliena_app/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Result<void>> signIn({required String email}) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.sendEmailOtp(email);
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Sign in failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> signUp({
    required String email,
    required String phone,
    required String fullName,
    String? address,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      final user = await _remoteDataSource.signUp(
        email: email,
        phone: phone,
        fullName: fullName,
        address: address,
      );
      return Result.success(user);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Sign up failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return Result.success(null);
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Sign out failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> sendPhoneOtp(String phone) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.sendPhoneOtp(phone);
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Failed to send phone OTP: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.verifyPhoneOtp(phone: phone, otp: otp);
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Phone verification failed: ${e.toString()}'));
    }
  }

  /// Sends an email OTP to the given address.
  ///
  /// THE CRITICAL FIX (repository layer):
  ///
  /// The datasource now converts every AuthException subclass (including
  /// AuthRetryableFetchException for 500 responses) to AppAuthException
  /// before returning.  This method therefore wraps every possible exception
  /// type — including any future ones — in a Result.failure so that the
  /// caller (the BLoC) always receives a Result, never a thrown exception.
  ///
  /// Previously, only AppAuthException was caught here.  If anything else
  /// escaped the datasource it would propagate through the BLoC event handler,
  /// leaving the state at AuthLoading and showing a raw DartError to the user.
  @override
  Future<Result<void>> sendEmailOtp(String email) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.sendEmailOtp(email);
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      // Belt-and-braces: ensure no exception ever escapes this method as a
      // throw.  The BLoC must always receive a Result so it can navigate the
      // user to the OTP screen with an appropriate error message.
      return Result.failure(
        ServerFailure(message: 'Failed to send verification code: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<void>> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.verifyEmailOtp(email: email, otp: otp);
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Verification failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<String>> setup2FA() async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      final secret = await _remoteDataSource.setup2FA();
      return Result.success(secret);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: '2FA setup failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> verify2FA(String code) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.verify2FA(code);
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: '2FA verification failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> disable2FA() async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.disable2FA();
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Failed to disable 2FA: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      return Result.success(user);
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Failed to get current user: ${e.toString()}'));
    }
  }

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  Future<Result<void>> refreshSession() async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.refreshSession();
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Session refresh failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<User>> updateProfile({
    String? fullName,
    String? phone,
    String? address,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      final user = await _remoteDataSource.updateProfile(
        fullName: fullName,
        phone: phone,
        address: address,
      );
      return Result.success(user);
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Profile update failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> updateEmail(String newEmail) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.updateEmail(newEmail);
      return Result.success(null);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Email update failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      await _remoteDataSource.deleteAccount();
      return Result.success(null);
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Account deletion failed: ${e.toString()}'));
    }
  }

  @override
  Future<Result<String>> getLoginStatus(String email) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      final status = await _remoteDataSource.getLoginStatus(email);
      return Result.success(status);
    } catch (e) {
      return Result.success('not_found');
    }
  }

  @override
  Future<Result<bool>> checkCanSkipOtp(String email) async {
    if (!await _networkInfo.isConnected) {
      return Result.success(false);
    }
    try {
      final canSkip = await _remoteDataSource.checkCanSkipOtp(email);
      return Result.success(canSkip);
    } catch (e) {
      return Result.success(false);
    }
  }

  @override
  Future<Result<User>> signInVerifiedUser(String email) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }
    try {
      final user = await _remoteDataSource.signInAsVerifiedUser(email);
      return Result.success(user);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Verified sign-in failed: ${e.toString()}'),
      );
    }
  }
}

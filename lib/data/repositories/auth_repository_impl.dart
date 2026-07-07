import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }

    try {
      final userModel = await _remoteDataSource.loginWithEmail(
        email,
        password,
      );

      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }

    try {
      final userModel = await _remoteDataSource.registerWithEmail(
        email,
        password,
        displayName,
      );

      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }

    try {
      final verificationId =
          await _remoteDataSource.loginWithPhone(phoneNumber);
      return Right(verificationId);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> verifyPhoneOtp({
    required String verificationId,
    required String otp,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }

    try {
      final userModel = await _remoteDataSource.verifyPhoneOtp(
        verificationId,
        otp,
      );

      await _localDataSource.cacheUser(userModel);

      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearCachedUser();
      await _localDataSource.clearAuthToken();

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final cachedUser = await _localDataSource.getCachedUser();

      if (cachedUser != null) {
        return Right(cachedUser.toEntity());
      }

      if (await _networkInfo.isConnected) {
        final userModel = await _remoteDataSource.getCurrentUser();

        if (userModel != null) {
          await _localDataSource.cacheUser(userModel);
          return Right(userModel.toEntity());
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final cachedUser = await _localDataSource.getCachedUser();
      return cachedUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }

    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(User user) async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }

    try {
      final userModel = UserModel.fromEntity(user);
      final updatedUserModel = await _remoteDataSource.updateUserProfile(
        userModel,
      );

      await _localDataSource.cacheUser(updatedUserModel);

      return Right(updatedUserModel.toEntity());
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (!await _networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'No internet connection'),
      );
    }

    try {
      await _remoteDataSource.deleteAccount();
      await _localDataSource.clearCachedUser();
      await _localDataSource.clearAuthToken();

      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _remoteDataSource.authStateChanges.map((userModel) {
      if (userModel != null) {
        _localDataSource.cacheUser(userModel);
        return userModel.toEntity();
      }
      return null;
    });
  }
}

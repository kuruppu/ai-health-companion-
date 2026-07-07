import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Login with email and password
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });

  /// Register with email and password
  Future<Either<Failure, User>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Login with phone number (sends OTP)
  Future<Either<Failure, String>> loginWithPhone(String phoneNumber);

  /// Verify OTP for phone login
  Future<Either<Failure, User>> verifyPhoneOtp({
    required String verificationId,
    required String otp,
  });

  /// Logout current user
  Future<Either<Failure, void>> logout();

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  /// Update user profile
  Future<Either<Failure, User>> updateUserProfile(User user);

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();

  /// Stream of auth state changes
  Stream<User?> get authStateChanges;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:injectable/injectable.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String displayName,
  );
  Future<String> loginWithPhone(String phoneNumber);
  Future<UserModel> verifyPhoneOtp(String verificationId, String otp);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserModel> updateUserProfile(UserModel user);
  Future<void> deleteAccount();
  Stream<UserModel?> get authStateChanges;
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._firestore);
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Login failed');
      }

      final user = await _getUserFromFirestore(credential.user!.uid);
      if (user == null) {
        throw const AuthException(message: 'User data not found');
      }
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthException(message: 'Registration failed');
      }

      await credential.user!.updateDisplayName(displayName);

      final now = DateTime.now();
      final userModel = UserModel(
        userId: credential.user!.uid,
        firebaseUid: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      await _saveUserToFirestore(userModel);

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<String> loginWithPhone(String phoneNumber) async {
    try {
      String? verificationId;

      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted:
            (credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          throw AuthException(
            message: _getAuthErrorMessage(e.code),
            code: e.code,
          );
        },
        codeSent: (verId, resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (verId) {
          verificationId = verId;
        },
      );

      if (verificationId == null) {
        throw const AuthException(message: 'Failed to send OTP');
      }

      return verificationId!;
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> verifyPhoneOtp(String verificationId, String otp) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException(message: 'OTP verification failed');
      }

      final userId = userCredential.user!.uid;
      final existingUser = await _getUserFromFirestore(userId);

      if (existingUser != null) {
        return existingUser;
      }

      final now = DateTime.now();
      final userModel = UserModel(
        userId: userId,
        firebaseUid: userId,
        email: userCredential.user!.email ?? '',
        displayName: userCredential.user!.displayName ?? 'User',
        photoUrl: userCredential.user!.photoURL,
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );

      await _saveUserToFirestore(userModel);

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;

      if (firebaseUser == null) {
        return null;
      }

      return await _getUserFromFirestore(firebaseUser.uid);
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final updatedUser = UserModel(
        userId: user.userId,
        firebaseUid: user.firebaseUid,
        email: user.email,
        displayName: user.displayName,
        photoUrl: user.photoUrl,
        age: user.age,
        heightCm: user.heightCm,
        currentWeightKg: user.currentWeightKg,
        goalWeightKg: user.goalWeightKg,
        gender: user.gender,
        emotionalGoal: user.emotionalGoal,
        activityLevel: user.activityLevel,
        dietaryPreferences: user.dietaryPreferences,
        dailyCaloricTarget: user.dailyCaloricTarget,
        proteinGrams: user.proteinGrams,
        carbsGrams: user.carbsGrams,
        fatsGrams: user.fatsGrams,
        waterIntakeMl: user.waterIntakeMl,
        createdAt: user.createdAt,
        updatedAt: DateTime.now(),
        isActive: user.isActive,
      );

      await _saveUserToFirestore(updatedUser);

      return updatedUser;
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;

      if (user == null) {
        throw const AuthException(message: 'No user logged in');
      }

      await _firestore
          .collection(ApiEndpoints.usersCollection)
          .doc(user.uid)
          .delete();

      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(message: e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }

      try {
        return await _getUserFromFirestore(firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });

  Future<UserModel?> _getUserFromFirestore(String userId) async {
    try {
      final doc = await _firestore
          .collection(ApiEndpoints.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await _firestore
          .collection(ApiEndpoints.usersCollection)
          .doc(user.userId)
          .set(user.toJson());
    } catch (e) {
      throw DatabaseException(message: e.toString());
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'invalid-verification-code':
        return 'Invalid OTP code';
      case 'session-expired':
        return 'OTP has expired. Please request a new one';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

@module
abstract class FirebaseModule {
  @lazySingleton
  firebase_auth.FirebaseAuth get firebaseAuth =>
      firebase_auth.FirebaseAuth.instance;

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}

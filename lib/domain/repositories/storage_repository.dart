import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';

/// Repository interface for file storage operations
abstract class StorageRepository {
  /// Upload an image to Firebase Storage
  ///
  /// [file] - Image file to upload
  /// [userId] - User who owns the image
  /// [path] - Storage path (e.g., 'meals', 'profile')
  ///
  /// Returns the download URL of the uploaded image
  Future<Either<Failure, String>> uploadImage({
    required File file,
    required String userId,
    required String path,
  });

  /// Delete an image from Firebase Storage
  ///
  /// [imageUrl] - URL of the image to delete
  ///
  /// Returns unit on success
  Future<Either<Failure, Unit>> deleteImage({
    required String imageUrl,
  });

  /// Get download URL for a storage path
  ///
  /// [path] - Storage path
  ///
  /// Returns the download URL
  Future<Either<Failure, String>> getDownloadUrl({
    required String path,
  });
}

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../repositories/storage_repository.dart';

/// Use case for uploading images to storage
@injectable
class UploadImageUseCase {

  const UploadImageUseCase(this._repository);
  final StorageRepository _repository;

  /// Execute the use case
  ///
  /// [file] - Image file to upload
  /// [userId] - User who owns the image
  /// [path] - Storage path
  Future<Either<Failure, String>> call({
    required File file,
    required String userId,
    required String path,
  }) async => _repository.uploadImage(
      file: file,
      userId: userId,
      path: path,
    );
}

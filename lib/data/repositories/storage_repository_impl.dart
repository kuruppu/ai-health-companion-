import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/errors/failures.dart';
import '../../domain/repositories/storage_repository.dart';
import '../datasources/storage_remote_datasource.dart';

@Injectable(as: StorageRepository)
class StorageRepositoryImpl implements StorageRepository {

  const StorageRepositoryImpl(this._remoteDataSource);
  final StorageRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, String>> uploadImage({
    required File file,
    required String userId,
    required String path,
  }) async {
    try {
      final downloadUrl = await _remoteDataSource.uploadImage(
        file: file,
        userId: userId,
        path: path,
      );

      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteImage({
    required String imageUrl,
  }) async {
    try {
      await _remoteDataSource.deleteImage(imageUrl: imageUrl);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getDownloadUrl({
    required String path,
  }) async {
    try {
      final downloadUrl = await _remoteDataSource.getDownloadUrl(path: path);
      return Right(downloadUrl);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

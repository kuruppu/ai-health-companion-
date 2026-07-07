import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

/// Remote data source for Firebase Storage operations
@injectable
class StorageRemoteDataSource {
  final FirebaseStorage _storage;
  final Uuid _uuid;

  const StorageRemoteDataSource(this._storage, this._uuid);

  /// Upload image to Firebase Storage
  ///
  /// Returns the download URL
  Future<String> uploadImage({
    required File file,
    required String userId,
    required String path,
  }) async {
    try {
      final fileExtension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$fileExtension';
      final storagePath = '$path/$userId/$fileName';

      final ref = _storage.ref().child(storagePath);

      // Upload with metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(fileExtension),
        customMetadata: {
          'uploaded_by': userId,
          'uploaded_at': DateTime.now().toIso8601String(),
        },
      );

      final uploadTask = ref.putFile(file, metadata);

      // Wait for completion
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Delete image from Firebase Storage
  Future<void> deleteImage({required String imageUrl}) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Get download URL for a storage path
  Future<String> getDownloadUrl({required String path}) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to get download URL: $e');
    }
  }

  /// Determine content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}

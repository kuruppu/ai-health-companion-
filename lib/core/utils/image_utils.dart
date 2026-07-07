import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

class ImageUtils {
  ImageUtils._();

  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  static Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: (AppConstants.imageQuality * 100).toInt(),
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } catch (e) {
      return null;
    }
  }

  /// Pick image from gallery
  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: (AppConstants.imageQuality * 100).toInt(),
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } catch (e) {
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
        imageQuality: (AppConstants.imageQuality * 100).toInt(),
      );

      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if file size is within limit
  static Future<bool> isFileSizeValid(File file) async {
    final bytes = await file.length();
    return bytes <= AppConstants.maxImageSizeBytes;
  }

  /// Get file size in bytes
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }

  /// Get file size in readable format (e.g., "2.5 MB")
  static Future<String> getReadableFileSize(File file) async {
    final bytes = await file.length();
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// Save image to app directory
  static Future<File> saveToAppDirectory(
    File imageFile,
    String fileName,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    return await imageFile.copy(path);
  }

  /// Save bytes to app directory
  static Future<File> saveBytesToAppDirectory(
    Uint8List bytes,
    String fileName,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return file;
  }

  /// Delete file
  static Future<void> deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  /// Generate unique file name
  static String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${timestamp}_${DateTime.now().microsecond}.$extension';
  }

  /// Get file extension
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Check if file is image
  static bool isImageFile(String path) {
    final extension = getFileExtension(path);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extension);
  }

  /// Convert file to base64
  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return bytes.toString();
  }

  /// Get temporary directory
  static Future<Directory> getTempDirectory() async {
    return await getTemporaryDirectory();
  }

  /// Clear temporary images
  static Future<void> clearTempImages() async {
    final tempDir = await getTemporaryDirectory();
    final files = tempDir.listSync();

    for (final file in files) {
      if (file is File && isImageFile(file.path)) {
        await file.delete();
      }
    }
  }
}

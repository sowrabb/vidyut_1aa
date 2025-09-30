import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// Lightweight image service with minimal dependencies
class LightweightImageService {
  static const String _cacheKeyPrefix = 'cached_image_';
  static const String _webStoragePrefix = 'web_storage://';
  static const int _maxFileSizeBytes = 2 * 1024 * 1024; // 2MB limit

  /// Get image bytes from stored path
  static Future<Uint8List?> getImageBytes(String imagePath) async {
    try {
      if (imagePath.startsWith(_webStoragePrefix)) {
        final fileName = imagePath.replaceFirst(_webStoragePrefix, '');
        final prefs = await SharedPreferences.getInstance();
        final base64String = prefs.getString('$_cacheKeyPrefix$fileName');
        if (base64String != null) {
          return base64Decode(base64String);
        }
        return null;
      } else {
        final File file = File(imagePath);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
        return null;
      }
    } catch (e) {
      debugPrint('Error getting image bytes: $e');
      return null;
    }
  }

  /// Store image bytes (simplified)
  static Future<String?> storeImageBytes(
      Uint8List bytes, String fileName) async {
    try {
      if (bytes.length > _maxFileSizeBytes) {
        throw Exception('Image file is too large (max 2MB)');
      }

      if (kIsWeb) {
        final base64String = base64Encode(bytes);
        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String newFileName = 'img_$timestamp.jpg';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_cacheKeyPrefix$newFileName', base64String);

        return '$_webStoragePrefix$newFileName';
      } else {
        // For mobile/desktop, save bytes to file
        final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory uploadsDir = Directory('${appDir.path}/uploads');

        if (!await uploadsDir.exists()) {
          await uploadsDir.create(recursive: true);
        }

        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();
        final String newFileName = 'img_$timestamp.jpg';
        final String filePath = '${uploadsDir.path}/$newFileName';

        final File uploadedFile = File(filePath);
        await uploadedFile.writeAsBytes(bytes);

        return uploadedFile.path;
      }
    } catch (e) {
      debugPrint('Error storing image bytes: $e');
      return null;
    }
  }

  /// Delete image file
  static Future<bool> deleteImageFile(String filePath) async {
    try {
      if (filePath.startsWith(_webStoragePrefix)) {
        final fileName = filePath.replaceFirst(_webStoragePrefix, '');
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('$_cacheKeyPrefix$fileName');
        return true;
      } else {
        final File file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting image file: $e');
      return false;
    }
  }

  /// Format file size for display
  static String formatFileSize(double sizeKB) {
    if (sizeKB < 1024) {
      return '${sizeKB.toStringAsFixed(1)} KB';
    } else {
      return '${(sizeKB / 1024).toStringAsFixed(1)} MB';
    }
  }

  /// Clear all cached images
  static Future<void> clearCache() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith(_cacheKeyPrefix)) {
            await prefs.remove(key);
          }
        }
      } else {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory uploadsDir = Directory('${appDir.path}/uploads');
        if (await uploadsDir.exists()) {
          await uploadsDir.delete(recursive: true);
        }
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}

class ImageUploadResult {
  final String path;
  final String fileName;

  ImageUploadResult({
    required this.path,
    required this.fileName,
  });
}

/// Alias for backward compatibility
class ImageService extends LightweightImageService {
  static Future<ImageUploadResult?> uploadFromCamera() async {
    try {
      if (kIsWeb) {
        return null; // Camera capture via web input is handled in Files path
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      if (image == null) return null;

      final Uint8List bytes = await image.readAsBytes();
      final String? storedPath = await LightweightImageService.storeImageBytes(
        bytes,
        image.name,
      );
      if (storedPath == null) return null;
      return ImageUploadResult(path: storedPath, fileName: image.name);
    } catch (e) {
      debugPrint('uploadFromCamera error: $e');
      return null;
    }
  }

  static Future<ImageUploadResult?> uploadFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 4096,
        maxHeight: 4096,
        imageQuality: 85,
      );
      if (image == null) return null;

      final Uint8List bytes = await image.readAsBytes();
      final String? storedPath = await LightweightImageService.storeImageBytes(
        bytes,
        image.name,
      );
      if (storedPath == null) return null;
      return ImageUploadResult(path: storedPath, fileName: image.name);
    } catch (e) {
      debugPrint('uploadFromGallery error: $e');
      return null;
    }
  }

  static Future<ImageUploadResult?> uploadFromFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return null;
      final file = result.files.first;

      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && !kIsWeb) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) return null;

      // Enforce 10MB limit
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception('Image must be < 10MB');
      }

      final String fileName = file.name.isNotEmpty ? file.name : 'upload.jpg';
      final String? storedPath = await LightweightImageService.storeImageBytes(
        bytes,
        fileName,
      );
      if (storedPath == null) return null;
      return ImageUploadResult(path: storedPath, fileName: fileName);
    } catch (e) {
      debugPrint('uploadFromFiles error: $e');
      return null;
    }
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ImageService {
  static const String _cacheKeyPrefix = 'cached_image_';
  static const String _webStoragePrefix = 'web_storage://';
  static const int _maxFileSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int _maxImageWidth = 1920;
  static const int _maxImageHeight = 1080;
  static const int _quality = 85;

  /// Upload and optimize image from camera
  static Future<ImageUploadResult?> uploadFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _quality,
      );

      if (image == null) return null;

      return await _processImageFile(image.path);
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Upload and optimize image from gallery
  static Future<ImageUploadResult?> uploadFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _maxImageWidth.toDouble(),
        maxHeight: _maxImageHeight.toDouble(),
        imageQuality: _quality,
      );

      if (image == null) return null;
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        return await _processImageBytes(bytes, image.name);
      }
      return await _processImageFile(image.path);
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Upload and optimize image from file picker
  static Future<ImageUploadResult?> uploadFromFiles() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final PlatformFile file = result.files.first;
      
      if (kIsWeb && file.bytes != null) {
        return await _processImageBytes(file.bytes!, file.name);
      } else if (file.path != null) {
        return await _processImageFile(file.path!);
      }
      
      return null;
    } catch (e) {
      print('Error picking image from files: $e');
      return null;
    }
  }

  /// Process image file with compression and optimization
  static Future<ImageUploadResult?> _processImageFile(String imagePath) async {
    try {
      final File originalFile = File(imagePath);
      
      // Validate original file
      if (!await originalFile.exists()) {
        throw Exception('Image file does not exist');
      }

      final int originalSize = await originalFile.length();
      if (originalSize > _maxFileSizeBytes) {
        throw Exception('Image file is too large (max 5MB)');
      }

      // Compress image
      final String compressedPath = await _compressImage(imagePath);
      final File compressedFile = File(compressedPath);
      
      if (!await compressedFile.exists()) {
        throw Exception('Failed to compress image');
      }

      final int compressedSize = await compressedFile.length();
      
      // Store compressed image
      final String? storedPath = await _storeImage(compressedFile);
      if (storedPath == null) {
        throw Exception('Failed to store image');
      }

      // Clean up temporary compressed file
      await compressedFile.delete().catchError((_) => compressedFile);

      return ImageUploadResult(
        path: storedPath,
        originalSize: originalSize,
        compressedSize: compressedSize,
        compressionRatio: (originalSize - compressedSize) / originalSize,
        fileName: originalFile.path.split('/').last,
      );
    } catch (e) {
      print('Error processing image file: $e');
      return null;
    }
  }

  /// Process image bytes (for web)
  static Future<ImageUploadResult?> _processImageBytes(Uint8List bytes, String fileName) async {
    try {
      if (bytes.length > _maxFileSizeBytes) {
        throw Exception('Image file is too large (max 5MB)');
      }

      // Compress bytes (skip on web as flutter_image_compress is not supported)
      Uint8List compressed = bytes;
      if (!kIsWeb) {
        final Uint8List? out = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 300,
          minHeight: 300,
          quality: _quality,
          format: CompressFormat.jpeg,
        );
        if (out == null) {
          throw Exception('Failed to compress image');
        }
        compressed = out;
      }

      // Store compressed bytes
      final String? storedPath = await _storeImageBytes(compressed, fileName);
      if (storedPath == null) {
        throw Exception('Failed to store image');
      }

      return ImageUploadResult(
        path: storedPath,
        originalSize: bytes.length,
        compressedSize: compressed.length,
        compressionRatio: (bytes.length - compressed.length) / bytes.length,
        fileName: fileName,
      );
    } catch (e) {
      print('Error processing image bytes: $e');
      return null;
    }
  }

  /// Compress image file
  static Future<String> _compressImage(String imagePath) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final String compressedPath = '${tempDir.path}/compressed_$timestamp.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      compressedPath,
      quality: _quality,
      minWidth: 300,
      minHeight: 300,
      format: CompressFormat.jpeg,
    );

    if (compressedFile == null) {
      throw Exception('Failed to compress image');
    }

    return compressedFile.path;
  }

  /// Store image file
  static Future<String?> _storeImage(File imageFile) async {
    try {
      if (kIsWeb) {
        // For web, convert to base64 and store in SharedPreferences
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String fileName = 'img_${timestamp}.jpg';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('$_cacheKeyPrefix$fileName', base64String);
        
        return '$_webStoragePrefix$fileName';
      } else {
        // For mobile/desktop, use file system
        final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory uploadsDir = Directory('${appDir.path}/uploads');
        
        if (!await uploadsDir.exists()) {
          await uploadsDir.create(recursive: true);
        }
        
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String fileName = 'img_${timestamp}.jpg';
        final String filePath = '${uploadsDir.path}/$fileName';
        
        final File uploadedFile = await imageFile.copy(filePath);
        return uploadedFile.path;
      }
    } catch (e) {
      print('Error storing image: $e');
      return null;
    }
  }

  /// Store image bytes (for web)
  static Future<String?> _storeImageBytes(Uint8List bytes, String fileName) async {
    try {
      if (kIsWeb) {
        final base64String = base64Encode(bytes);
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String newFileName = 'img_${timestamp}.jpg';
        
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
        
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String newFileName = 'img_${timestamp}.jpg';
        final String filePath = '${uploadsDir.path}/$newFileName';
        
        final File uploadedFile = File(filePath);
        await uploadedFile.writeAsBytes(bytes);
        
        return uploadedFile.path;
      }
    } catch (e) {
      print('Error storing image bytes: $e');
      return null;
    }
  }

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
      print('Error getting image bytes: $e');
      return null;
    }
  }

  /// Get image file from stored path
  static Future<File?> getImageFile(String imagePath) async {
    try {
      if (imagePath.startsWith(_webStoragePrefix)) {
        // For web storage, we can't return a File object
        return null;
      } else {
        final File file = File(imagePath);
        if (await file.exists()) {
          return file;
        }
        return null;
      }
    } catch (e) {
      print('Error getting image file: $e');
      return null;
    }
  }

  /// Get file size in KB
  static Future<double> getFileSizeKB(String filePath) async {
    try {
      if (filePath.startsWith(_webStoragePrefix)) {
        final bytes = await getImageBytes(filePath);
        if (bytes != null) {
          return bytes.length / 1024;
        }
        return 0;
      } else {
        final File file = File(filePath);
        if (await file.exists()) {
          final int bytes = await file.length();
          return bytes / 1024;
        }
        return 0;
      }
    } catch (e) {
      return 0;
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

  /// Validate image file
  static Future<bool> validateImageFile(File imageFile) async {
    try {
      if (!await imageFile.exists()) return false;
      
      final int fileSize = await imageFile.length();
      if (fileSize > _maxFileSizeBytes) return false;
      if (fileSize < 1024) return false;
      
      final String extension = imageFile.path.split('.').last.toLowerCase();
      const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(extension)) return false;
      
      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }

  /// Validate image bytes
  static bool validateImageBytes(Uint8List imageBytes) {
    try {
      if (imageBytes.length > _maxFileSizeBytes) return false;
      if (imageBytes.length < 1024) return false;
      return true;
    } catch (e) {
      print('Error validating image bytes: $e');
      return false;
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
      print('Error deleting image file: $e');
      return false;
    }
  }

  /// Get image info
  static Future<ImageInfo?> getImageInfo(String filePath) async {
    try {
      if (filePath.startsWith(_webStoragePrefix)) {
        final fileName = filePath.replaceFirst(_webStoragePrefix, '');
        final prefs = await SharedPreferences.getInstance();
        final base64String = prefs.getString('$_cacheKeyPrefix$fileName');
        if (base64String == null) return null;
        
        final bytes = base64Decode(base64String);
        final String extension = fileName.split('.').last.toLowerCase();
        
        return ImageInfo(
          fileName: fileName,
          filePath: filePath,
          fileSize: bytes.length,
          fileSizeKB: bytes.length / 1024,
          extension: extension,
          formattedSize: formatFileSize(bytes.length / 1024),
        );
      } else {
        final File file = File(filePath);
        if (!await file.exists()) return null;
        
        final int fileSize = await file.length();
        final String fileName = filePath.split('/').last;
        final String extension = fileName.split('.').last.toLowerCase();
        
        return ImageInfo(
          fileName: fileName,
          filePath: filePath,
          fileSize: fileSize,
          fileSizeKB: fileSize / 1024,
          extension: extension,
          formattedSize: formatFileSize(fileSize / 1024),
        );
      }
    } catch (e) {
      print('Error getting image info: $e');
      return null;
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
      print('Error clearing cache: $e');
    }
  }
}

class ImageUploadResult {
  final String path;
  final int originalSize;
  final int compressedSize;
  final double compressionRatio;
  final String fileName;

  ImageUploadResult({
    required this.path,
    required this.originalSize,
    required this.compressedSize,
    required this.compressionRatio,
    required this.fileName,
  });

  String get formattedOriginalSize => ImageService.formatFileSize(originalSize / 1024);
  String get formattedCompressedSize => ImageService.formatFileSize(compressedSize / 1024);
  String get compressionPercentage => '${(compressionRatio * 100).toStringAsFixed(1)}%';
}

class ImageInfo {
  final String fileName;
  final String filePath;
  final int fileSize;
  final double fileSizeKB;
  final String extension;
  final String formattedSize;

  ImageInfo({
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.fileSizeKB,
    required this.extension,
    required this.formattedSize,
  });
}

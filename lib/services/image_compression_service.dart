import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageCompressionService {
  static const int maxWidth = 1600;
  static const int maxHeight = 1200;
  static const int quality = 85; // JPEG quality (1-100)
  static const int maxFileSizeKB = 800; // Target compressed size in KB

  /// Compress and convert image to optimized JPEG format
  /// Supports JPG, PNG, HEIC, and other common formats
  static Future<File?> compressImage(File imageFile) async {
    try {
      // Read the image file
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Decode the image
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Could not decode image');
      }

      // Calculate new dimensions while maintaining aspect ratio
      final int originalWidth = originalImage.width;
      final int originalHeight = originalImage.height;
      
      int newWidth = originalWidth;
      int newHeight = originalHeight;
      
      // Scale down if image is too large
      if (originalWidth > maxWidth || originalHeight > maxHeight) {
        final double aspectRatio = originalWidth / originalHeight;
        
        if (originalWidth > originalHeight) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      // Resize the image
      img.Image resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );

      // Convert to JPEG format with compression
      final List<int> compressedBytes = img.encodeJpg(
        resizedImage,
        quality: quality,
      );

      // Check if compressed size is acceptable
      if (compressedBytes.length > maxFileSizeKB * 1024) {
        // If still too large, reduce quality further
        int adjustedQuality = quality;
        while (compressedBytes.length > maxFileSizeKB * 1024 && adjustedQuality > 10) {
          adjustedQuality -= 10;
          compressedBytes.clear();
          compressedBytes.addAll(img.encodeJpg(resizedImage, quality: adjustedQuality));
        }
      }

      // Save compressed image to temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File('${tempDir.path}/$fileName');
      
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Web-safe: compress and convert raw bytes to optimized JPEG bytes
  static Future<Uint8List?> compressBytes(Uint8List imageBytes) async {
    try {
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        // If we can't decode (e.g., HEIC), just return original bytes
        return imageBytes;
      }

      int newWidth = originalImage.width;
      int newHeight = originalImage.height;

      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        final double aspectRatio = originalImage.width / originalImage.height;
        if (originalImage.width > originalImage.height) {
          newWidth = maxWidth;
          newHeight = (maxWidth / aspectRatio).round();
        } else {
          newHeight = maxHeight;
          newWidth = (maxHeight * aspectRatio).round();
        }
      }

      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: newWidth,
        height: newHeight,
        interpolation: img.Interpolation.cubic,
      );

      int q = quality;
      Uint8List out = Uint8List.fromList(img.encodeJpg(resizedImage, quality: q));
      while (out.length > maxFileSizeKB * 1024 && q > 10) {
        q -= 10;
        out = Uint8List.fromList(img.encodeJpg(resizedImage, quality: q));
      }
      return out;
    } catch (_) {
      // On any error, return original bytes to avoid blocking uploads
      return imageBytes;
    }
  }

  /// Get image dimensions without loading full image
  static Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      
      if (image != null) {
        return {
          'width': image.width,
          'height': image.height,
        };
      }
      return null;
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }

  /// Web-safe: get image dimensions from bytes
  static Map<String, int>? getImageDimensionsFromBytes(Uint8List imageBytes) {
    try {
      final img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return null;
      return {'width': image.width, 'height': image.height};
    } catch (e) {
      return null;
    }
  }

  /// Validate image file before compression
  static Future<bool> validateImage(File imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        if (image.width < 50 || image.height < 50) return false;
        if (image.width > 8000 || image.height > 8000) return false;
        return true;
      }
      // If decode fails (e.g., HEIC on some platforms), accept based on size
      final sizeKB = imageBytes.length / 1024.0;
      return sizeKB > 10 && sizeKB < (maxFileSizeKB * 20);
    } catch (e) {
      print('Error validating image: $e');
      return false;
    }
  }

  /// Web-safe: validate using bytes
  static bool validateBytes(Uint8List imageBytes) {
    try {
      // If decodable, validate dimensions
      final img.Image? image = img.decodeImage(imageBytes);
      if (image != null) {
        if (image.width < 50 || image.height < 50) return false;
        if (image.width > 8000 || image.height > 8000) return false;
        return true;
      }
      // If not decodable (HEIC on web, etc.), accept based on size caps only
      final sizeKB = imageBytes.length / 1024.0;
      return sizeKB > 10 && sizeKB < (maxFileSizeKB * 20); // allow up to ~16MB before compression
    } catch (e) {
      return false;
    }
  }

  /// Get file size in KB
  static Future<double> getFileSizeKB(File file) async {
    final int bytes = await file.length();
    return bytes / 1024;
  }

  /// Format file size for display
  static String formatFileSize(double sizeKB) {
    if (sizeKB < 1024) {
      return '${sizeKB.toStringAsFixed(1)} KB';
    } else {
      return '${(sizeKB / 1024).toStringAsFixed(1)} MB';
    }
  }

  /// Clean up temporary files
  static Future<void> cleanupTempFiles() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = await tempDir.list().toList();
      
      for (final file in files) {
        if (file is File && file.path.contains('compressed_')) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error cleaning up temp files: $e');
    }
  }
}

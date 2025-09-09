import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleImageService {
  /// Upload image file and return the file path
  static Future<String?> uploadImageFile(File imageFile) async {
    try {
      if (kIsWeb) {
        // For web, convert to base64 and store in SharedPreferences
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String extension = imageFile.path.split('.').last.toLowerCase();
        final String fileName = 'hero_${timestamp}.$extension';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('hero_image_$fileName', base64String);
        
        return 'web_storage://$fileName';
      } else {
        // For mobile/desktop, use file system
        final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory uploadsDir = Directory('${appDir.path}/uploads');
        
        if (!await uploadsDir.exists()) {
          await uploadsDir.create(recursive: true);
        }
        
        // Generate unique filename
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String extension = imageFile.path.split('.').last.toLowerCase();
        final String fileName = 'hero_${timestamp}.$extension';
        final String filePath = '${uploadsDir.path}/$fileName';
        
        // Copy file to uploads directory
        final File uploadedFile = await imageFile.copy(filePath);
        
        return uploadedFile.path;
      }
    } catch (e) {
      print('Error uploading image file: $e');
      return null;
    }
  }
  
  /// Upload image bytes (for web) and return the file path
  static Future<String?> uploadImageBytes(Uint8List imageBytes, String extension) async {
    try {
      if (kIsWeb) {
        // For web, convert to base64 and store in SharedPreferences
        final base64String = base64Encode(imageBytes);
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String fileName = 'hero_${timestamp}.$extension';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('hero_image_$fileName', base64String);
        
        return 'web_storage://$fileName';
      } else {
        // For mobile/desktop, use file system
        final Directory appDir = await getApplicationDocumentsDirectory();
        final Directory uploadsDir = Directory('${appDir.path}/uploads');
        
        if (!await uploadsDir.exists()) {
          await uploadsDir.create(recursive: true);
        }
        
        // Generate unique filename
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String fileName = 'hero_${timestamp}.$extension';
        final String filePath = '${uploadsDir.path}/$fileName';
        
        // Write bytes to file
        final File uploadedFile = File(filePath);
        await uploadedFile.writeAsBytes(imageBytes);
        
        return uploadedFile.path;
      }
    } catch (e) {
      print('Error uploading image bytes: $e');
      return null;
    }
  }
  
  /// Get file size in KB
  static Future<double> getFileSizeKB(String filePath) async {
    try {
      if (filePath.startsWith('web_storage://')) {
        // For web storage, get from SharedPreferences
        final fileName = filePath.replaceFirst('web_storage://', '');
        final prefs = await SharedPreferences.getInstance();
        final base64String = prefs.getString('hero_image_$fileName');
        if (base64String != null) {
          final bytes = base64Decode(base64String);
          return bytes.length / 1024;
        }
        return 0;
      } else {
        // For file system
        final File file = File(filePath);
        final int bytes = await file.length();
        return bytes / 1024;
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
      // Check if file exists and is readable
      if (!await imageFile.exists()) return false;
      
      // Check file size (max 10MB)
      final int fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) return false; // 10MB limit
      if (fileSize < 1024) return false; // At least 1KB
      
      // Check file extension
      final String extension = imageFile.path.split('.').last.toLowerCase();
      const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      if (!allowedExtensions.contains(extension)) return false;
      
      return true;
    } catch (e) {
      print('Error validating image file: $e');
      return false;
    }
  }
  
  /// Validate image bytes (for web)
  static bool validateImageBytes(Uint8List imageBytes) {
    try {
      // Check size limits
      if (imageBytes.length > 10 * 1024 * 1024) return false; // 10MB limit
      if (imageBytes.length < 1024) return false; // At least 1KB
      
      return true;
    } catch (e) {
      print('Error validating image bytes: $e');
      return false;
    }
  }
  
  /// Delete image file
  static Future<bool> deleteImageFile(String filePath) async {
    try {
      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image file: $e');
      return false;
    }
  }
  
  /// Get image file info
  static Future<Map<String, dynamic>?> getImageInfo(String filePath) async {
    try {
      if (filePath.startsWith('web_storage://')) {
        // For web storage, get from SharedPreferences
        final fileName = filePath.replaceFirst('web_storage://', '');
        final prefs = await SharedPreferences.getInstance();
        final base64String = prefs.getString('hero_image_$fileName');
        if (base64String == null) return null;
        
        final bytes = base64Decode(base64String);
        final String extension = fileName.split('.').last.toLowerCase();
        
        return {
          'fileName': fileName,
          'filePath': filePath,
          'fileSize': bytes.length,
          'fileSizeKB': bytes.length / 1024,
          'extension': extension,
          'formattedSize': formatFileSize(bytes.length / 1024),
        };
      } else {
        // For file system
        final File file = File(filePath);
        if (!await file.exists()) return null;
        
        final int fileSize = await file.length();
        final String fileName = filePath.split('/').last;
        final String extension = fileName.split('.').last.toLowerCase();
        
        return {
          'fileName': fileName,
          'filePath': filePath,
          'fileSize': fileSize,
          'fileSizeKB': fileSize / 1024,
          'extension': extension,
          'formattedSize': formatFileSize(fileSize / 1024),
        };
      }
    } catch (e) {
      print('Error getting image info: $e');
      return null;
    }
  }
}

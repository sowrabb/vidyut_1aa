import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'firebase_service.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  final FirebaseService _firebase = FirebaseService.instance;

  // Upload product image
  Future<String> uploadProductImage(File imageFile, String productId, int index) async {
    try {
      // Compress image
      final compressedFile = await _compressImage(imageFile);
      
      final fileName = '${productId}_$index.jpg';
      final ref = _firebase.productImagesRef.child(fileName);
      
      final uploadTask = ref.putFile(compressedFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Log analytics event
      await _firebase.analytics.logEvent(
        name: 'image_uploaded',
        parameters: {'type': 'product_image', 'product_id': productId},
      );
      
      return downloadUrl;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Upload user profile image
  Future<String> uploadUserImage(File imageFile, String userId) async {
    try {
      // Compress image
      final compressedFile = await _compressImage(imageFile);
      
      final fileName = '${userId}_profile.jpg';
      final ref = _firebase.userImagesRef.child(fileName);
      
      final uploadTask = ref.putFile(compressedFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Upload document
  Future<String> uploadDocument(File file, String fileName) async {
    try {
      final ref = _firebase.documentsRef.child(fileName);
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Delete file
  Future<void> deleteFile(String url) async {
    try {
      final ref = _firebase.storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Compress image
  Future<File> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Could not decode image');
      }

      // Resize image if it's too large
      img.Image resizedImage = image;
      if (image.width > 1200 || image.height > 1200) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 1200 : null,
          height: image.height > image.width ? 1200 : null,
          maintainAspect: true,
        );
      }

      // Compress image
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Save compressed image to temporary file
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(compressedBytes);
      
      return tempFile;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      // Return original file if compression fails
      return imageFile;
    }
  }

  // Get file metadata
  Future<FullMetadata> getFileMetadata(String url) async {
    try {
      final ref = _firebase.storage.refFromURL(url);
      return await ref.getMetadata();
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // List files in a folder
  Future<List<Reference>> listFiles(String folderPath) async {
    try {
      final ref = _firebase.storage.ref(folderPath);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }

  // Get download URL
  Future<String> getDownloadURL(String path) async {
    try {
      final ref = _firebase.storage.ref(path);
      return await ref.getDownloadURL();
    } catch (e) {
      await _firebase.crashlytics.recordError(e, null, fatal: false);
      rethrow;
    }
  }
}

// Firebase Storage service for media uploads and management
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../features/stateinfo/models/media_models.dart';

/// Service for handling media uploads to Firebase Storage
class MediaStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Uuid _uuid = Uuid();

  /// Upload media bytes to Firebase Storage (for web compatibility)
  static Future<MediaItem> uploadMedia({
    required Uint8List fileBytes,
    required String fileName,
    required String mimeType,
    required MediaType mediaType,
    required String entityType,
    required String entityId,
    String? userId,
    Function(double)? onProgress,
  }) async {
    try {
      print('UploadMedia called: $fileName, ${fileBytes.length} bytes, type: $mediaType');
      
      // For now, let's create a mock upload that simulates the process
      // This will help us identify if the issue is with Firebase Storage or the UI
      
      final fileExtension = path.extension(fileName).toLowerCase();
      final fileId = _uuid.v4();
      
      // Validate file type
      if (mediaType == MediaType.image && !MediaConstraints.isValidImageType(fileName)) {
        throw Exception('Invalid image format. Allowed: ${MediaConstraints.allowedImageTypes.join(', ')}');
      }
      if (mediaType == MediaType.pdf && !MediaConstraints.isValidPdfType(fileName)) {
        throw Exception('Invalid PDF format');
      }

      // Simulate progress for debugging
      if (onProgress != null) {
        for (int i = 0; i <= 100; i += 10) {
          await Future.delayed(Duration(milliseconds: 100));
          onProgress(i / 100.0);
          print('Simulated progress: $i%');
        }
      }

      // Create a mock MediaItem for now
      final mockDownloadUrl = 'https://via.placeholder.com/400x300?text=${Uri.encodeComponent(fileName)}';
      
      return MediaItem(
        id: fileId,
        type: mediaType,
        storagePath: _generateStateInfoStoragePath(
          entityType: entityType,
          entityId: entityId,
          mediaType: mediaType,
          fileId: fileId,
          fileExtension: fileExtension,
        ),
        downloadUrl: mockDownloadUrl,
        thumbnailUrl: mediaType == MediaType.image ? mockDownloadUrl : null,
        isCover: false,
        name: fileName,
        sizeBytes: fileBytes.length,
        uploadedAt: DateTime.now(),
        uploadedBy: userId ?? 'mock_user',
      );
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload media: $e');
    }
  }

  /// Compress image to reduce upload time
  static Future<Uint8List> _compressImage(Uint8List imageBytes) async {
    try {
      // For web, we'll use a simple approach since flutter_image_compress may not work
      // In a production app, you might want to use a web-compatible image compression library
      
      // For now, just return the original bytes but you could implement:
      // 1. Canvas-based compression for web
      // 2. Server-side compression
      // 3. Client-side resizing before upload
      
      return imageBytes;
    } catch (e) {
      // If compression fails, return original bytes
      return imageBytes;
    }
  }

  /// Upload a single file to Firebase Storage
  static Future<MediaItem> uploadFile({
    required File file,
    required String postId,
    required MediaType mediaType,
    bool isCover = false,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User must be authenticated to upload files');
      }

      final fileName = path.basename(file.path);
      final fileExtension = path.extension(fileName).toLowerCase();
      final fileId = _uuid.v4();
      
      // Validate file type
      if (mediaType == MediaType.image && !MediaConstraints.isValidImageType(fileName)) {
        throw Exception('Invalid image format. Allowed: ${MediaConstraints.allowedImageTypes.join(', ')}');
      }
      if (mediaType == MediaType.pdf && !MediaConstraints.isValidPdfType(fileName)) {
        throw Exception('Invalid PDF format');
      }

      // Validate file size
      final fileSize = await file.length();
      if (mediaType == MediaType.image && !MediaConstraints.isValidImageSize(fileSize)) {
        throw Exception('Image too large. Max size: ${MediaConstraints.maxImageSizeBytes ~/ (1024 * 1024)}MB');
      }
      if (mediaType == MediaType.pdf && !MediaConstraints.isValidPdfSize(fileSize)) {
        throw Exception('PDF too large. Max size: ${MediaConstraints.maxPdfSizeBytes ~/ (1024 * 1024)}MB');
      }

      // Generate storage path
      final storagePath = _generateStoragePath(
        postId: postId,
        fileId: fileId,
        mediaType: mediaType,
        fileExtension: fileExtension,
      );

      // Upload file
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);
      
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Generate thumbnail URL for images (for now, use same URL)
      // In production, you might want to generate actual thumbnails
      String? thumbnailUrl;
      if (mediaType == MediaType.image) {
        thumbnailUrl = downloadUrl;
      }

      return MediaItem(
        id: fileId,
        type: mediaType,
        storagePath: storagePath,
        downloadUrl: downloadUrl,
        thumbnailUrl: thumbnailUrl,
        isCover: isCover,
        name: fileName,
        sizeBytes: fileSize,
        uploadedAt: DateTime.now(),
        uploadedBy: user.uid,
      );
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload multiple files with progress tracking
  static Future<List<MediaItem>> uploadFiles({
    required List<File> files,
    required String postId,
    required List<MediaType> mediaTypes,
    required Function(MediaUploadProgress) onProgress,
    bool cancelUploads = false,
  }) async {
    if (files.length != mediaTypes.length) {
      throw Exception('Files and media types lists must have the same length');
    }

    final List<MediaItem> uploadedItems = [];
    
    for (int i = 0; i < files.length; i++) {
      if (cancelUploads) break;

      final file = files[i];
      final mediaType = mediaTypes[i];
      final fileId = _uuid.v4();

      try {
        onProgress(MediaUploadProgress(
          fileId: fileId,
          fileName: path.basename(file.path),
          progress: 0.0,
        ));

        final mediaItem = await uploadFile(
          file: file,
          postId: postId,
          mediaType: mediaType,
          isCover: uploadedItems.where((m) => m.type == MediaType.image).isEmpty && mediaType == MediaType.image,
        );

        uploadedItems.add(mediaItem);

        onProgress(MediaUploadProgress(
          fileId: fileId,
          fileName: path.basename(file.path),
          progress: 1.0,
          isCompleted: true,
        ));
      } catch (e) {
        onProgress(MediaUploadProgress(
          fileId: fileId,
          fileName: path.basename(file.path),
          progress: 0.0,
          error: e.toString(),
        ));
      }
    }

    return uploadedItems;
  }

  /// Delete a file from Firebase Storage
  static Future<void> deleteFile(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Delete multiple files from Firebase Storage
  static Future<void> deleteFiles(List<String> storagePaths) async {
    final List<Future<void>> deleteTasks = storagePaths.map((path) => deleteFile(path)).toList();
    await Future.wait(deleteTasks);
  }

  /// Generate a unique storage path for a file
  static String _generateStoragePath({
    required String postId,
    required String fileId,
    required MediaType mediaType,
    required String fileExtension,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final folder = mediaType == MediaType.image ? 'images' : 'pdfs';
    return 'posts/$postId/$folder/${fileId}_$timestamp$fileExtension';
  }

  /// Generates StateInfo-specific storage path for media files.
  static String _generateStateInfoStoragePath({
    required String entityType, // e.g., 'power_generator', 'transmission_line', 'distribution_company'
    required String entityId, // ID of the entity
    required MediaType mediaType,
    required String fileId,
    required String fileExtension,
  }) {
    // Determine sub-type based on context (posts or product_designs)
    final subType = entityType.contains('posts') ? 'posts' : 'product_designs';
    return 'stateInfo/$entityType/$entityId/$subType/$fileId$fileExtension';
  }

  /// Get file metadata from storage
  static Future<FullMetadata> getFileMetadata(String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      return await ref.getMetadata();
    } catch (e) {
      throw Exception('Failed to get file metadata: $e');
    }
  }

  /// Generate a thumbnail for an image (placeholder implementation)
  /// In production, you might want to use image processing libraries
  static Future<String?> generateImageThumbnail({
    required String imageUrl,
    required String postId,
    required String fileId,
    int maxWidth = 300,
    int maxHeight = 300,
  }) async {
    try {
      // For now, return the original URL as thumbnail
      // In production, implement actual thumbnail generation
      return imageUrl;
    } catch (e) {
      return null;
    }
  }

  /// Generate a thumbnail for a PDF (placeholder implementation)
  /// In production, you might want to use PDF processing libraries
  static Future<String?> generatePdfThumbnail({
    required String pdfUrl,
    required String postId,
    required String fileId,
  }) async {
    try {
      // For now, return null (no thumbnail)
      // In production, implement PDF first-page thumbnail generation
      return null;
    } catch (e) {
      return null;
    }
  }
}

/// Upload task manager for handling cancellable uploads
class MediaUploadTask {
  final String taskId;
  final List<File> files;
  final List<MediaType> mediaTypes;
  final String postId;
  final Function(MediaUploadProgress) onProgress;
  
  bool _isCancelled = false;
  final List<MediaItem> _uploadedItems = [];

  MediaUploadTask({
    required this.taskId,
    required this.files,
    required this.mediaTypes,
    required this.postId,
    required this.onProgress,
  });

  bool get isCancelled => _isCancelled;
  List<MediaItem> get uploadedItems => List.unmodifiable(_uploadedItems);

  void cancel() {
    _isCancelled = true;
  }

  Future<List<MediaItem>> execute() async {
    return await MediaStorageService.uploadFiles(
      files: files,
      postId: postId,
      mediaTypes: mediaTypes,
      onProgress: onProgress,
      cancelUploads: _isCancelled,
    );
  }
}

/// Upload manager for handling multiple concurrent upload tasks
class MediaUploadManager {
  static final Map<String, MediaUploadTask> _activeTasks = {};

  static String startUpload({
    required List<File> files,
    required List<MediaType> mediaTypes,
    required String postId,
    required Function(MediaUploadProgress) onProgress,
  }) {
    final taskId = const Uuid().v4();
    final task = MediaUploadTask(
      taskId: taskId,
      files: files,
      mediaTypes: mediaTypes,
      postId: postId,
      onProgress: onProgress,
    );

    _activeTasks[taskId] = task;
    return taskId;
  }

  static void cancelUpload(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.cancel();
      _activeTasks.remove(taskId);
    }
  }

  static Future<List<MediaItem>> executeUpload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task == null) {
      throw Exception('Upload task not found: $taskId');
    }

    try {
      final result = await task.execute();
      _activeTasks.remove(taskId);
      return result;
    } catch (e) {
      _activeTasks.remove(taskId);
      rethrow;
    }
  }

  static void clearAllTasks() {
    for (final task in _activeTasks.values) {
      task.cancel();
    }
    _activeTasks.clear();
  }
}

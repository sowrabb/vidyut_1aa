import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math';

/// Service for handling image upload, compression, optimization, and storage
class ImageManagementService extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();
  final http.Client _httpClient = http.Client();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  // Getters
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  /// Pick multiple images from gallery
  Future<List<XFile>> pickMultipleImages({
    int maxImages = 5,
    ImageQuality quality = ImageQuality.medium,
  }) async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: _getImageQuality(quality),
        maxWidth: _getMaxWidth(quality),
        maxHeight: _getMaxHeight(quality),
      );

      if (images.length > maxImages) {
        _setError('Maximum $maxImages images allowed');
        return [];
      }

      return images;
    } catch (e) {
      _setError('Failed to pick images: ${e.toString()}');
      return [];
    }
  }

  /// Pick single image from camera
  Future<XFile?> pickImageFromCamera({
    ImageQuality quality = ImageQuality.medium,
  }) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: _getImageQuality(quality),
        maxWidth: _getMaxWidth(quality),
        maxHeight: _getMaxHeight(quality),
      );

      return image;
    } catch (e) {
      _setError('Failed to capture image: ${e.toString()}');
      return null;
    }
  }

  /// Compress and optimize image
  Future<Uint8List> compressImage(
    XFile imageFile, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: maxWidth,
        targetHeight: maxHeight,
      );

      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ByteData? byteData = await frameInfo.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      return byteData!.buffer.asUint8List();
    } catch (e) {
      _setError('Failed to compress image: ${e.toString()}');
      rethrow;
    }
  }

  /// Upload image to cloud storage
  Future<String?> uploadImage(
    Uint8List imageBytes, {
    String? fileName,
    String? folder = 'products',
  }) async {
    _setUploading(true);
    _setError(null);

    try {
      if (kIsWeb) {
        final String finalFileName = fileName ?? _generateUniqueFileName();
        final Reference ref = FirebaseStorage.instance.ref().child('$folder/$finalFileName');
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=31536000,immutable',
        );
        final UploadTask task = ref.putData(imageBytes, metadata);
        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            _setUploadProgress(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        });
        final TaskSnapshot snap = await task;
        final String downloadUrl = await snap.ref.getDownloadURL();
        _setUploading(false);
        return downloadUrl;
      }
      final String finalFileName = fileName ?? _generateUniqueFileName();
      final Reference ref =
          FirebaseStorage.instance.ref().child('$folder/$finalFileName');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'public,max-age=31536000,immutable',
      );

      final UploadTask task = ref.putData(imageBytes, metadata);

      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          _setUploadProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });

      final TaskSnapshot snap = await task;
      final String downloadUrl = await snap.ref.getDownloadURL();

      _setUploading(false);
      return downloadUrl;
    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      _setUploading(false);
      return null;
    }
  }

  /// Upload multiple images
  Future<List<String>> uploadMultipleImages(
    List<XFile> imageFiles, {
    String? folder = 'products',
    int quality = 85,
  }) async {
    _setUploading(true);
    _setError(null);

    final List<String> uploadedUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        final XFile imageFile = imageFiles[i];

        // Compress image
        final Uint8List compressedBytes = await compressImage(
          imageFile,
          quality: quality,
        );

        // Upload image
        final String? imageUrl = await uploadImage(
          compressedBytes,
          fileName: _generateUniqueFileName(index: i + 1),
          folder: folder,
        );

        if (imageUrl != null) {
          uploadedUrls.add(imageUrl);
        }

        // Update progress
        _setUploadProgress((i + 1) / imageFiles.length);
      }

      _setUploading(false);
      return uploadedUrls;
    } catch (e) {
      _setError('Failed to upload images: ${e.toString()}');
      _setUploading(false);
      return uploadedUrls;
    }
  }

  /// Delete image from cloud storage
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // In a real app, this would delete from your cloud storage
      // For demo purposes, we'll just return true
      return true;
    } catch (e) {
      _setError('Failed to delete image: ${e.toString()}');
      return false;
    }
  }

  /// Get image dimensions
  Future<Size> getImageDimensions(String imageUrl) async {
    try {
      final http.Response response = await _httpClient.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final ui.Codec codec = await ui.instantiateImageCodec(bytes);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        return Size(
          frameInfo.image.width.toDouble(),
          frameInfo.image.height.toDouble(),
        );
      }
      return const Size(0, 0);
    } catch (e) {
      return const Size(0, 0);
    }
  }

  // Private helper methods
  int _getImageQuality(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 50;
      case ImageQuality.medium:
        return 75;
      case ImageQuality.high:
        return 90;
    }
  }

  double? _getMaxWidth(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 800;
      case ImageQuality.medium:
        return 1200;
      case ImageQuality.high:
        return 1920;
    }
  }

  double? _getMaxHeight(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 600;
      case ImageQuality.medium:
        return 900;
      case ImageQuality.high:
        return 1080;
    }
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    if (!uploading) {
      _uploadProgress = 0.0;
    }
    notifyListeners();
  }

  void _setUploadProgress(double progress) {
    _uploadProgress = progress;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  String _generateUniqueFileName({int? index}) {
    final int ts = DateTime.now().microsecondsSinceEpoch;
    final int rand = Random().nextInt(1 << 32);
    final prefix = index != null ? 'img_${index}_' : 'img_';
    return '${prefix}${ts}_$rand.jpg';
  }

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}

/// Image quality enum
enum ImageQuality { low, medium, high }

/// Image upload result
class ImageUploadResult {
  final String url;
  final String fileName;
  final int fileSize;
  final Size dimensions;

  const ImageUploadResult({
    required this.url,
    required this.fileName,
    required this.fileSize,
    required this.dimensions,
  });
}

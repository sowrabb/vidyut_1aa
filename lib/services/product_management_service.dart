import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:vidyut/models/product_status.dart';

// Uses shared ProductStatus

class ProductVersion {
  final String id;
  final String productId;
  final Map<String, dynamic> data;
  final String changeDescription;
  final String changedBy;
  final DateTime createdAt;
  final String versionNumber;

  ProductVersion({
    required this.id,
    required this.productId,
    required this.data,
    required this.changeDescription,
    required this.changedBy,
    required this.createdAt,
    required this.versionNumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'data': data,
        'changeDescription': changeDescription,
        'changedBy': changedBy,
        'createdAt': createdAt.toIso8601String(),
        'versionNumber': versionNumber,
      };

  factory ProductVersion.fromJson(Map<String, dynamic> json) => ProductVersion(
        id: json['id'],
        productId: json['productId'],
        data: Map<String, dynamic>.from(json['data']),
        changeDescription: json['changeDescription'],
        changedBy: json['changedBy'],
        createdAt: DateTime.parse(json['createdAt']),
        versionNumber: json['versionNumber'],
      );
}

class ProductMedia {
  final String id;
  final String productId;
  final String url;
  final String type; // 'image', 'video', 'document'
  final String fileName;
  final int fileSize;
  final String mimeType;
  final DateTime uploadedAt;
  final bool isPrimary;
  final Map<String, dynamic> metadata;

  ProductMedia({
    required this.id,
    required this.productId,
    required this.url,
    required this.type,
    required this.fileName,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
    this.isPrimary = false,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'url': url,
        'type': type,
        'fileName': fileName,
        'fileSize': fileSize,
        'mimeType': mimeType,
        'uploadedAt': uploadedAt.toIso8601String(),
        'isPrimary': isPrimary,
        'metadata': metadata,
      };

  factory ProductMedia.fromJson(Map<String, dynamic> json) => ProductMedia(
        id: json['id'],
        productId: json['productId'],
        url: json['url'],
        type: json['type'],
        fileName: json['fileName'],
        fileSize: json['fileSize'],
        mimeType: json['mimeType'],
        uploadedAt: DateTime.parse(json['uploadedAt']),
        isPrimary: json['isPrimary'] ?? false,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}

class ProductManagementService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Removed unused picker to satisfy lints
  // final ImagePicker _imagePicker = ImagePicker();

  List<ProductVersion> _productVersions = [];
  List<ProductMedia> _productMedia = [];

  bool _isLoading = false;
  String? _error;
  double _uploadProgress = 0.0;

  // Getters
  List<ProductVersion> get productVersions => _productVersions;
  List<ProductMedia> get productMedia => _productMedia;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;

  // Create product with validation
  Future<String?> createProduct(Map<String, dynamic> productData,
      {String? userId}) async {
    _setLoading(true);
    _clearError();

    try {
      // Validate required fields
      final validationError = _validateProductData(productData);
      if (validationError != null) {
        _setError(validationError);
        return null;
      }

      // Add metadata
      final productWithMetadata = {
        ...productData,
        'status': ProductStatus.active.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'createdBy': userId,
        'version': 1,
        'viewCount': 0,
        'orderCount': 0,
        'rating': 0.0,
      };

      // Create product document
      final docRef =
          await _firestore.collection('products').add(productWithMetadata);
      final productId = docRef.id;

      // Create initial version
      await _createProductVersion(
        productId,
        productData,
        'Initial product creation',
        userId ?? 'system',
      );

      return productId;
    } catch (e) {
      _setError('Failed to create product: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Update product with validation
  Future<bool> updateProduct(String productId, Map<String, dynamic> updateData,
      {String? userId, String? changeDescription}) async {
    _setLoading(true);
    _clearError();

    try {
      // Get current product data
      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) {
        _setError('Product not found');
        return false;
      }

      final currentData = productDoc.data()!;

      // Validate update data
      final validationError = _validateProductData(updateData, isUpdate: true);
      if (validationError != null) {
        _setError(validationError);
        return false;
      }

      // Prepare update data
      final updateWithMetadata = {
        ...updateData,
        'updatedAt': FieldValue.serverTimestamp(),
        'version': (currentData['version'] ?? 1) + 1,
      };

      // Update product
      await _firestore
          .collection('products')
          .doc(productId)
          .update(updateWithMetadata);

      // Create version record
      await _createProductVersion(
        productId,
        updateData,
        changeDescription ?? 'Product updated',
        userId ?? 'system',
      );

      return true;
    } catch (e) {
      _setError('Failed to update product: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Soft delete product
  Future<bool> softDeleteProduct(String productId,
      {String? userId, String? reason}) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore.collection('products').doc(productId).update({
        'status': ProductStatus.archived.value,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
        'deletionReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create version record
      await _createProductVersion(
        productId,
        {'status': ProductStatus.archived.value},
        'Product soft deleted: ${reason ?? 'No reason provided'}',
        userId ?? 'system',
      );

      return true;
    } catch (e) {
      _setError('Failed to delete product: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Hard delete product
  Future<bool> hardDeleteProduct(String productId, {String? userId}) async {
    _setLoading(true);
    _clearError();

    try {
      // Delete product media first
      await _deleteProductMedia(productId);

      // Delete product versions
      await _deleteProductVersions(productId);

      // Delete product document
      await _firestore.collection('products').doc(productId).delete();

      return true;
    } catch (e) {
      _setError('Failed to permanently delete product: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Duplicate product
  Future<String?> duplicateProduct(String productId,
      {String? userId, String? newTitle}) async {
    _setLoading(true);
    _clearError();

    try {
      // Get original product
      final productDoc =
          await _firestore.collection('products').doc(productId).get();
      if (!productDoc.exists) {
        _setError('Product not found');
        return null;
      }

      final originalData = productDoc.data()!;

      // Create duplicate data
      final duplicateData = Map<String, dynamic>.from(originalData);
      duplicateData.remove('id');
      duplicateData['title'] = newTitle ?? '${originalData['title']} (Copy)';
      duplicateData['status'] = ProductStatus.draft.value;
      duplicateData['createdAt'] = FieldValue.serverTimestamp();
      duplicateData['updatedAt'] = FieldValue.serverTimestamp();
      duplicateData['createdBy'] = userId;
      duplicateData['version'] = 1;
      duplicateData['viewCount'] = 0;
      duplicateData['orderCount'] = 0;

      // Create duplicate product
      final docRef = await _firestore.collection('products').add(duplicateData);
      final newProductId = docRef.id;

      // Duplicate media
      await _duplicateProductMedia(productId, newProductId);

      // Create initial version
      await _createProductVersion(
        newProductId,
        duplicateData,
        'Product duplicated from ${originalData['title']}',
        userId ?? 'system',
      );

      return newProductId;
    } catch (e) {
      _setError('Failed to duplicate product: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Bulk operations
  Future<Map<String, dynamic>> bulkUpdateProducts(
    List<String> productIds,
    Map<String, dynamic> updateData, {
    String? userId,
    String? changeDescription,
  }) async {
    _setLoading(true);
    _clearError();

    final results = {
      'success': <String>[],
      'failed': <String, String>{},
    };

    try {
      final batch = _firestore.batch();

      for (final productId in productIds) {
        try {
          final productRef = _firestore.collection('products').doc(productId);
          batch.update(productRef, {
            ...updateData,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          // Create version record for each product
          await _createProductVersion(
            productId,
            updateData,
            changeDescription ?? 'Bulk update',
            userId ?? 'system',
          );

          (results['success'] as List<String>).add(productId);
        } catch (e) {
          (results['failed'] as Map<String, String>)[productId] = e.toString();
        }
      }

      await batch.commit();
    } catch (e) {
      _setError('Failed to bulk update products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }

    return results;
  }

  Future<Map<String, dynamic>> bulkDeleteProducts(
    List<String> productIds, {
    String? userId,
    String? reason,
    bool hardDelete = false,
  }) async {
    _setLoading(true);
    _clearError();

    final results = {
      'success': <String>[],
      'failed': <String, String>{},
    };

    try {
      for (final productId in productIds) {
        try {
          if (hardDelete) {
            await hardDeleteProduct(productId, userId: userId);
          } else {
            await softDeleteProduct(productId, userId: userId, reason: reason);
          }
          (results['success'] as List<String>).add(productId);
        } catch (e) {
          (results['failed'] as Map<String, String>)[productId] = e.toString();
        }
      }
    } catch (e) {
      _setError('Failed to bulk delete products: ${e.toString()}');
    } finally {
      _setLoading(false);
    }

    return results;
  }

  // Upload product image
  Future<String?> uploadProductImage(
    String productId,
    XFile imageFile, {
    bool isPrimary = false,
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();
    _uploadProgress = 0.0;

    try {
      // Compress image
      final compressedImage = await _compressImage(imageFile);

      // Generate unique filename
      final fileName =
          '${productId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('products/$productId/images/$fileName');

      // Upload with progress tracking
      final uploadTask = ref.putFile(compressedImage);

      uploadTask.snapshotEvents.listen((snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save media record
      final mediaId = DateTime.now().millisecondsSinceEpoch.toString();
      final media = ProductMedia(
        id: mediaId,
        productId: productId,
        url: downloadUrl,
        type: 'image',
        fileName: fileName,
        fileSize: await compressedImage.length(),
        mimeType: 'image/jpeg',
        uploadedAt: DateTime.now(),
        isPrimary: isPrimary,
        metadata: metadata ?? {},
      );

      await _firestore
          .collection('product_media')
          .doc(mediaId)
          .set(media.toJson());

      // Update product with image URL if it's the first image
      if (isPrimary) {
        await _firestore.collection('products').doc(productId).update({
          'primaryImage': downloadUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return downloadUrl;
    } catch (e) {
      _setError('Failed to upload image: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
      _uploadProgress = 0.0;
    }
  }

  // Upload product document
  Future<String?> uploadProductDocument(
    String productId,
    File documentFile, {
    Map<String, dynamic>? metadata,
  }) async {
    _setLoading(true);
    _clearError();
    _uploadProgress = 0.0;

    try {
      // Generate unique filename
      final fileName =
          '${productId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final ref =
          _storage.ref().child('products/$productId/documents/$fileName');

      // Upload with progress tracking
      final uploadTask = ref.putFile(documentFile);

      uploadTask.snapshotEvents.listen((snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Save media record
      final mediaId = DateTime.now().millisecondsSinceEpoch.toString();
      final media = ProductMedia(
        id: mediaId,
        productId: productId,
        url: downloadUrl,
        type: 'document',
        fileName: fileName,
        fileSize: await documentFile.length(),
        mimeType: 'application/pdf',
        uploadedAt: DateTime.now(),
        metadata: metadata ?? {},
      );

      await _firestore
          .collection('product_media')
          .doc(mediaId)
          .set(media.toJson());

      return downloadUrl;
    } catch (e) {
      _setError('Failed to upload document: ${e.toString()}');
      return null;
    } finally {
      _setLoading(false);
      _uploadProgress = 0.0;
    }
  }

  // Get product media
  Future<List<ProductMedia>> getProductMedia(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('product_media')
          .where('productId', isEqualTo: productId)
          .orderBy('uploadedAt', descending: true)
          .get();

      _productMedia = snapshot.docs
          .map((doc) => ProductMedia.fromJson(doc.data()))
          .toList();

      notifyListeners();
      return _productMedia;
    } catch (e) {
      _setError('Failed to fetch product media: ${e.toString()}');
      return [];
    }
  }

  // Get product versions
  Future<List<ProductVersion>> getProductVersions(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('product_versions')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .get();

      _productVersions = snapshot.docs
          .map((doc) => ProductVersion.fromJson(doc.data()))
          .toList();

      notifyListeners();
      return _productVersions;
    } catch (e) {
      _setError('Failed to fetch product versions: ${e.toString()}');
      return [];
    }
  }

  // Approve product
  Future<bool> approveProduct(String productId,
      {String? userId, String? notes}) async {
    _setLoading(true);
    _clearError();

    try {
      await _firestore.collection('products').doc(productId).update({
        'status': ProductStatus.active.value,
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': userId,
        'approvalNotes': notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create version record
      await _createProductVersion(
        productId,
        {'status': ProductStatus.active.value},
        'Product approved${notes != null ? ': $notes' : ''}',
        userId ?? 'system',
      );

      return true;
    } catch (e) {
      _setError('Failed to approve product: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  String? _validateProductData(Map<String, dynamic> data,
      {bool isUpdate = false}) {
    if (!isUpdate) {
      if (data['title'] == null || data['title'].toString().trim().isEmpty) {
        return 'Product title is required';
      }
      if (data['brand'] == null || data['brand'].toString().trim().isEmpty) {
        return 'Product brand is required';
      }
      if (data['price'] == null || (data['price'] as num) <= 0) {
        return 'Product price must be greater than 0';
      }
    }

    if (data['title'] != null && data['title'].toString().trim().isEmpty) {
      return 'Product title cannot be empty';
    }
    if (data['price'] != null && (data['price'] as num) <= 0) {
      return 'Product price must be greater than 0';
    }

    return null;
  }

  Future<void> _createProductVersion(
    String productId,
    Map<String, dynamic> data,
    String changeDescription,
    String changedBy,
  ) async {
    final versionId = DateTime.now().millisecondsSinceEpoch.toString();
    final version = ProductVersion(
      id: versionId,
      productId: productId,
      data: data,
      changeDescription: changeDescription,
      changedBy: changedBy,
      createdAt: DateTime.now(),
      versionNumber: '1.0.${DateTime.now().millisecondsSinceEpoch}',
    );

    await _firestore
        .collection('product_versions')
        .doc(versionId)
        .set(version.toJson());
  }

  Future<File> _compressImage(XFile imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.path,
      tempPath,
      quality: 85,
      minWidth: 800,
      minHeight: 600,
    );

    return File(compressedFile!.path);
  }

  Future<void> _deleteProductMedia(String productId) async {
    final mediaSnapshot = await _firestore
        .collection('product_media')
        .where('productId', isEqualTo: productId)
        .get();

    for (final doc in mediaSnapshot.docs) {
      final media = ProductMedia.fromJson(doc.data());

      // Delete from storage
      try {
        await _storage.refFromURL(media.url).delete();
      } catch (e) {
        // Ignore storage deletion errors
      }

      // Delete from Firestore
      await doc.reference.delete();
    }
  }

  Future<void> _deleteProductVersions(String productId) async {
    final versionsSnapshot = await _firestore
        .collection('product_versions')
        .where('productId', isEqualTo: productId)
        .get();

    final batch = _firestore.batch();
    for (final doc in versionsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> _duplicateProductMedia(
      String sourceProductId, String targetProductId) async {
    final mediaSnapshot = await _firestore
        .collection('product_media')
        .where('productId', isEqualTo: sourceProductId)
        .get();

    final batch = _firestore.batch();
    for (final doc in mediaSnapshot.docs) {
      final media = ProductMedia.fromJson(doc.data());
      final newMedia = ProductMedia(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        productId: targetProductId,
        url: media.url, // Same URL for now
        type: media.type,
        fileName: media.fileName,
        fileSize: media.fileSize,
        mimeType: media.mimeType,
        uploadedAt: DateTime.now(),
        isPrimary: false, // Reset primary status
        metadata: media.metadata,
      );

      batch.set(_firestore.collection('product_media').doc(newMedia.id),
          newMedia.toJson());
    }
    await batch.commit();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

/// Service for handling document upload and management
class DocumentManagementService extends ChangeNotifier {
  final http.Client _httpClient = http.Client();

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;

  // Getters
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get error => _error;

  /// Pick PDF document
  Future<PlatformFile?> pickPDFDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }

      return null;
    } catch (e) {
      _setError('Failed to pick document: ${e.toString()}');
      return null;
    }
  }

  /// Pick multiple documents
  Future<List<PlatformFile>> pickMultipleDocuments({
    List<String> allowedExtensions = const ['pdf', 'doc', 'docx', 'txt'],
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );

      if (result != null) {
        return result.files;
      }

      return [];
    } catch (e) {
      _setError('Failed to pick documents: ${e.toString()}');
      return [];
    }
  }

  /// Upload document to cloud storage
  Future<String?> uploadDocument(
    PlatformFile document, {
    String? folder = 'documents',
  }) async {
    _setUploading(true);
    _setError(null);

    try {
      // Simulate upload progress
      for (int i = 0; i <= 100; i += 10) {
        _setUploadProgress(i / 100);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // In a real app, this would upload to your cloud storage
      // For demo purposes, we'll return a placeholder URL
      final String fileName = document.name;
      final String documentUrl = 'https://cdn.example.com/$folder/$fileName';

      _setUploading(false);
      return documentUrl;
    } catch (e) {
      _setError('Failed to upload document: ${e.toString()}');
      _setUploading(false);
      return null;
    }
  }

  /// Upload multiple documents
  Future<List<String>> uploadMultipleDocuments(
    List<PlatformFile> documents, {
    String? folder = 'documents',
  }) async {
    _setUploading(true);
    _setError(null);

    final List<String> uploadedUrls = [];

    try {
      for (int i = 0; i < documents.length; i++) {
        final PlatformFile document = documents[i];

        // Upload document
        final String? documentUrl = await uploadDocument(
          document,
          folder: folder,
        );

        if (documentUrl != null) {
          uploadedUrls.add(documentUrl);
        }

        // Update progress
        _setUploadProgress((i + 1) / documents.length);
      }

      _setUploading(false);
      return uploadedUrls;
    } catch (e) {
      _setError('Failed to upload documents: ${e.toString()}');
      _setUploading(false);
      return uploadedUrls;
    }
  }

  /// Delete document from cloud storage
  Future<bool> deleteDocument(String documentUrl) async {
    try {
      // In a real app, this would delete from your cloud storage
      // For demo purposes, we'll just return true
      return true;
    } catch (e) {
      _setError('Failed to delete document: ${e.toString()}');
      return false;
    }
  }

  /// Get document info
  DocumentInfo getDocumentInfo(PlatformFile document) {
    return DocumentInfo(
      name: document.name,
      size: document.size,
      extension: document.extension ?? '',
      path: document.path,
    );
  }

  // Private helper methods
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

  @override
  void dispose() {
    _httpClient.close();
    super.dispose();
  }
}

/// Document information
class DocumentInfo {
  final String name;
  final int size;
  final String extension;
  final String? path;

  const DocumentInfo({
    required this.name,
    required this.size,
    required this.extension,
    this.path,
  });

  String get sizeFormatted {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    if (size < 1024 * 1024 * 1024)
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool get isPDF => extension.toLowerCase() == 'pdf';
  bool get isImage =>
      ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension.toLowerCase());
}

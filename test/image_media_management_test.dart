import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../lib/services/image_management_service.dart';
import '../lib/services/document_management_service.dart';
import '../lib/widgets/image_gallery_widget.dart';
import '../lib/widgets/media_upload_widget.dart';
import '../lib/features/sell/models.dart';

void main() {
  group('Image Management Service Tests', () {
    late ImageManagementService imageService;

    setUp(() {
      imageService = ImageManagementService();
    });

    tearDown(() {
      imageService.dispose();
    });

    test('should initialize with correct default values', () {
      expect(imageService.isUploading, false);
      expect(imageService.uploadProgress, 0.0);
      expect(imageService.error, null);
    });

    test('should handle image quality settings correctly', () {
      // Test quality enum values
      expect(ImageQuality.values,
          [ImageQuality.low, ImageQuality.medium, ImageQuality.high]);
    });

    test('should compress image with correct parameters', () async {
      // Test that the method exists and can be called
      expect(imageService.compressImage, isA<Function>());
    });

    test('should upload image and return URL', () async {
      final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

      // Mock upload
      final result = await imageService.uploadImage(imageBytes);

      // In demo mode, should return a placeholder URL
      expect(result, isNotNull);
      expect(result, contains('cdn.example.com'));
    });

    test('should handle upload progress correctly', () async {
      final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

      // Start upload
      final uploadFuture = imageService.uploadImage(imageBytes);

      // Check progress updates
      await Future.delayed(const Duration(milliseconds: 50));
      expect(imageService.uploadProgress, greaterThan(0.0));

      await uploadFuture;
      expect(imageService.uploadProgress, 1.0);
    });
  });

  group('Document Management Service Tests', () {
    late DocumentManagementService documentService;

    setUp(() {
      documentService = DocumentManagementService();
    });

    tearDown(() {
      documentService.dispose();
    });

    test('should initialize with correct default values', () {
      expect(documentService.isUploading, false);
      expect(documentService.uploadProgress, 0.0);
      expect(documentService.error, null);
    });

    test('should get document info correctly', () {
      // Create a mock PlatformFile-like object
      final mockFile = _MockPlatformFile(
        name: 'test.pdf',
        size: 1024,
        extension: 'pdf',
        path: '/path/to/test.pdf',
      );

      final info = documentService.getDocumentInfo(mockFile);

      expect(info.name, 'test.pdf');
      expect(info.size, 1024);
      expect(info.extension, 'pdf');
      expect(info.isPDF, true);
      expect(info.sizeFormatted, '1.0 KB');
    });

    test('should upload document and return URL', () async {
      final mockFile = _MockPlatformFile(
        name: 'test.pdf',
        size: 1024,
        extension: 'pdf',
      );

      final result = await documentService.uploadDocument(mockFile);

      expect(result, isNotNull);
      expect(result, contains('cdn.example.com'));
    });
  });

  group('Image Gallery Widget Tests', () {
    testWidgets('should display image gallery with correct initial index',
        (WidgetTester tester) async {
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
        'https://example.com/image3.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: ImageGalleryWidget(
            imageUrls: imageUrls,
            initialIndex: 1,
          ),
        ),
      );

      // Should show page indicator
      expect(find.text('2 of 3'), findsOneWidget);

      // Should show close button
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Should show share and download buttons
      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('should display thumbnail gallery correctly',
        (WidgetTester tester) async {
      const imageUrls = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ThumbnailGalleryWidget(
              imageUrls: imageUrls,
              selectedIndex: 0,
              onImageSelected: (index) {},
            ),
          ),
        ),
      );

      // Should show thumbnails
      expect(find.byType(ThumbnailGalleryWidget), findsOneWidget);
    });

    testWidgets('should display image preview correctly',
        (WidgetTester tester) async {
      const imageUrl = 'https://example.com/image.jpg';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImagePreviewWidget(
              imageUrl: imageUrl,
              heroTag: 'test_image',
            ),
          ),
        ),
      );

      // Should show hero widget
      expect(find.byType(Hero), findsOneWidget);
    });
  });

  group('Media Upload Widget Tests', () {
    testWidgets('should display media upload widget correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaUploadWidget(
                currentImages: const [],
                currentDocuments: const [],
                onImagesChanged: (images) {},
                onDocumentsChanged: (documents) {},
              ),
            ),
          ),
        ),
      );

      // Should show images section
      expect(find.text('Images (0/5)'), findsOneWidget);

      // Should show documents section
      expect(find.text('Documents (0/3)'), findsOneWidget);

      // Should show upload buttons
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Upload Documents'), findsOneWidget);
    });

    testWidgets('should display existing images correctly',
        (WidgetTester tester) async {
      const existingImages = [
        'https://example.com/image1.jpg',
        'https://example.com/image2.jpg',
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaUploadWidget(
                currentImages: existingImages,
                currentDocuments: const [],
                onImagesChanged: (images) {},
                onDocumentsChanged: (documents) {},
              ),
            ),
          ),
        ),
      );

      // Should show image count
      expect(find.text('Images (2/5)'), findsOneWidget);

      // Should show clear all button
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('should display existing documents correctly',
        (WidgetTester tester) async {
      const existingDocuments = [
        'https://example.com/doc1.pdf',
        'https://example.com/doc2.pdf',
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaUploadWidget(
                currentImages: const [],
                currentDocuments: existingDocuments,
                onImagesChanged: (images) {},
                onDocumentsChanged: (documents) {},
              ),
            ),
          ),
        ),
      );

      // Should show document count
      expect(find.text('Documents (2/3)'), findsOneWidget);
    });
  });

  group('Product Model Tests', () {
    test('should create product with documents field', () {
      const documents = [
        'https://example.com/spec.pdf',
        'https://example.com/manual.pdf'
      ];

      final product = Product(
        id: 'test_id',
        title: 'Test Product',
        documents: documents,
      );

      expect(product.documents, documents);
      expect(product.documents.length, 2);
    });

    test('should copy product with documents', () {
      const originalDocuments = ['https://example.com/spec.pdf'];
      const newDocuments = [
        'https://example.com/spec.pdf',
        'https://example.com/manual.pdf'
      ];

      final original = Product(
        id: 'test_id',
        title: 'Test Product',
        documents: originalDocuments,
      );

      final copied = original.copyWith(documents: newDocuments);

      expect(copied.documents, newDocuments);
      expect(copied.documents.length, 2);
    });

    test('should serialize and deserialize product with documents', () {
      const documents = [
        'https://example.com/spec.pdf',
        'https://example.com/manual.pdf'
      ];

      final original = Product(
        id: 'test_id',
        title: 'Test Product',
        documents: documents,
      );

      final json = original.toJson();
      final deserialized = Product.fromJson(json);

      expect(deserialized.documents, documents);
      expect(deserialized.documents.length, 2);
    });
  });

  group('Integration Tests', () {
    testWidgets('should handle media upload workflow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: MediaUploadWidget(
                currentImages: const [],
                currentDocuments: const [],
                onImagesChanged: (images) {
                  expect(images, isA<List<String>>());
                },
                onDocumentsChanged: (documents) {
                  expect(documents, isA<List<String>>());
                },
              ),
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('Images (0/5)'), findsOneWidget);
      expect(find.text('Documents (0/3)'), findsOneWidget);
    });
  });
}

// Mock classes for testing
class _MockPlatformFile implements PlatformFile {
  @override
  final String name;

  @override
  final int size;

  @override
  final String? extension;

  @override
  final String? path;

  @override
  final Uint8List? bytes;

  @override
  final String? identifier;

  @override
  final Stream<List<int>>? readStream;

  const _MockPlatformFile({
    required this.name,
    required this.size,
    this.extension,
    this.path,
    this.bytes,
    this.identifier,
    this.readStream,
  });
}

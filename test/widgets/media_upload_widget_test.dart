import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:vidyut/widgets/media_upload_widget.dart';
import 'package:vidyut/services/image_management_service.dart';
import 'package:vidyut/services/document_management_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows gallery button and no camera when disabled', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MediaUploadWidget(
          showDocuments: false,
          maxImages: 1,
          showCamera: false,
          galleryButtonLabel: 'Select Image',
        ),
      ),
    ));

    expect(find.text('Select Image'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsNothing);
  });

  group('MediaUploadWidget', () {
    testWidgets('renders empty state without crashing', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MediaUploadWidget(
            currentImages: const [],
            currentDocuments: const [],
            showDocuments: true,
            imageService: _FakeImageService(),
            documentService: _FakeDocService(),
          ),
        ),
      ));

      expect(find.textContaining('Images ('), findsOneWidget);
      expect(find.textContaining('Documents ('), findsOneWidget);
    });

    testWidgets('renders image grid when images provided', (tester) async {
      final images = [
        'https://example.com/a.jpg',
        'https://example.com/b.jpg',
        'https://example.com/c.jpg',
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: MediaUploadWidget(
            currentImages: images,
            currentDocuments: const [],
            showDocuments: false,
            imageService: _FakeImageService(),
            documentService: _FakeDocService(),
          ),
        ),
      ));

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}

class _FakeImageService extends ImageManagementService {
  @override
  bool get isUploading => false;

  @override
  double get uploadProgress => 0;

  @override
  String? get error => null;

  @override
  Future<String?> uploadImage(Uint8List imageBytes,
          {String? fileName, String? folder = 'products'}) async =>
      'https://example.com/fake.jpg';
}

class _FakeDocService extends DocumentManagementService {
  @override
  bool get isUploading => false;

  @override
  double get uploadProgress => 0;

  @override
  String? get error => null;

  @override
  Future<List<PlatformFile>> pickMultipleDocuments(
          {List<String> allowedExtensions = const [
            'pdf',
            'doc',
            'docx',
            'txt'
          ]}) async =>
      [];

  @override
  Future<List<String>> uploadMultipleDocuments(List<PlatformFile> documents,
          {String? folder = 'documents'}) async =>
      [];
}

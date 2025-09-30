// Widget tests for MediaUploaderWidget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:uuid/uuid.dart';
import '../../lib/features/stateinfo/models/media_models.dart';
import '../../lib/features/stateinfo/models/state_info_models.dart';
import '../../lib/features/stateinfo/widgets/media_uploader_widget.dart';

// Generate mocks
@GenerateMocks([])
void main() {
  group('MediaUploaderWidget', () {
    late List<MediaItem> mockMediaItems;
    late Function(List<MediaItem>) mockOnMediaChanged;
    late String mockPostId;

    setUp(() {
      mockMediaItems = [
        MediaItem(
          id: 'test_image_1',
          type: MediaType.image,
          storagePath: 'posts/test/images/image1.jpg',
          downloadUrl: 'https://example.com/image1.jpg',
          thumbnailUrl: 'https://example.com/image1_thumb.jpg',
          isCover: true,
          name: 'image1.jpg',
          sizeBytes: 1024000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'test_user',
        ),
        MediaItem(
          id: 'test_pdf_1',
          type: MediaType.pdf,
          storagePath: 'posts/test/pdfs/doc1.pdf',
          downloadUrl: 'https://example.com/doc1.pdf',
          name: 'doc1.pdf',
          sizeBytes: 2048000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'test_user',
        ),
      ];
      mockOnMediaChanged = (media) {};
      mockPostId = const Uuid().v4();
    });

    testWidgets('renders empty state when no media items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: [],
              onMediaChanged: mockOnMediaChanged,
              postId: mockPostId,
            ),
          ),
        ),
      );

      expect(find.text('No files uploaded yet'), findsOneWidget);
      expect(find.text('Upload images and PDFs to enhance your post'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_outlined), findsOneWidget);
    });

    testWidgets('renders upload buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: [],
              onMediaChanged: mockOnMediaChanged,
              postId: mockPostId,
            ),
          ),
        ),
      );

      expect(find.text('Upload Files'), findsOneWidget);
      expect(find.byIcon(Icons.upload_file), findsOneWidget);
    });

    testWidgets('renders existing media items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: mockMediaItems,
              onMediaChanged: mockOnMediaChanged,
              postId: mockPostId,
            ),
          ),
        ),
      );

      expect(find.text('image1.jpg'), findsOneWidget);
      expect(find.text('doc1.pdf'), findsOneWidget);
      expect(find.text('COVER'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('displays file sizes correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: mockMediaItems,
              onMediaChanged: mockOnMediaChanged,
              postId: mockPostId,
            ),
          ),
        ),
      );

      expect(find.text('1000.0 KB'), findsOneWidget); // image size
      expect(find.text('2000.0 KB'), findsOneWidget); // pdf size
    });

    testWidgets('shows media count in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: mockMediaItems,
              onMediaChanged: mockOnMediaChanged,
              postId: mockPostId,
              maxTotalFiles: 10,
            ),
          ),
        ),
      );

      expect(find.text('2/10 files'), findsOneWidget);
    });

    testWidgets('has remove buttons for media items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: mockMediaItems,
              onMediaChanged: mockOnMediaChanged,
              postId: mockPostId,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));
    });

    testWidgets('has set cover button for non-cover images', (WidgetTester tester) async {
      final nonCoverImage = MediaItem(
        id: 'test_image_2',
        type: MediaType.image,
        storagePath: 'posts/test/images/image2.jpg',
        downloadUrl: 'https://example.com/image2.jpg',
        name: 'image2.jpg',
        sizeBytes: 1024000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'test_user',
        isCover: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: [mockMediaItems[0], nonCoverImage],
              onMediaChanged: mockOnMediaChanged,
              postId: mockPostId,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.star_border), findsOneWidget);
    });
  });

  group('Media Item Rendering', () {
    late MediaItem mockImageItem;
    late MediaItem mockPdfItem;

    setUp(() {
      mockImageItem = MediaItem(
        id: 'test_image',
        type: MediaType.image,
        storagePath: 'posts/test/images/image.jpg',
        downloadUrl: 'https://example.com/image.jpg',
        thumbnailUrl: 'https://example.com/image_thumb.jpg',
        isCover: true,
        name: 'image.jpg',
        sizeBytes: 1024000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'test_user',
      );

      mockPdfItem = MediaItem(
        id: 'test_pdf',
        type: MediaType.pdf,
        storagePath: 'posts/test/pdfs/doc.pdf',
        downloadUrl: 'https://example.com/doc.pdf',
        name: 'doc.pdf',
        sizeBytes: 2048000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'test_user',
      );
    });

    testWidgets('renders image item correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: [mockImageItem],
              onMediaChanged: (media) {},
              postId: 'test_post',
            ),
          ),
        ),
      );

      expect(find.text('image.jpg'), findsOneWidget);
      expect(find.text('IMAGE'), findsOneWidget);
      expect(find.text('1000.0 KB'), findsOneWidget);
      expect(find.text('COVER'), findsOneWidget);
    });

    testWidgets('renders PDF item correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaUploaderWidget(
              initialMedia: [mockPdfItem],
              onMediaChanged: (media) {},
              postId: 'test_post',
            ),
          ),
        ),
      );

      expect(find.text('doc.pdf'), findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);
      expect(find.text('2000.0 KB'), findsOneWidget);
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });
  });

  group('MediaConstraints', () {
    test('validates image types correctly', () {
      expect(MediaConstraints.isValidImageType('image.jpg'), isTrue);
      expect(MediaConstraints.isValidImageType('image.jpeg'), isTrue);
      expect(MediaConstraints.isValidImageType('image.png'), isTrue);
      expect(MediaConstraints.isValidImageType('image.webp'), isTrue);
      expect(MediaConstraints.isValidImageType('image.gif'), isFalse);
      expect(MediaConstraints.isValidImageType('image.bmp'), isFalse);
    });

    test('validates PDF types correctly', () {
      expect(MediaConstraints.isValidPdfType('document.pdf'), isTrue);
      expect(MediaConstraints.isValidPdfType('document.docx'), isFalse);
      expect(MediaConstraints.isValidPdfType('document.doc'), isFalse);
    });

    test('validates file sizes correctly', () {
      expect(MediaConstraints.isValidImageSize(5 * 1024 * 1024), isTrue); // 5MB
      expect(MediaConstraints.isValidImageSize(15 * 1024 * 1024), isFalse); // 15MB
      expect(MediaConstraints.isValidPdfSize(25 * 1024 * 1024), isTrue); // 25MB
      expect(MediaConstraints.isValidPdfSize(75 * 1024 * 1024), isFalse); // 75MB
    });

    test('validates media list correctly', () {
      final validMedia = [
        MediaItem(
          id: '1',
          type: MediaType.image,
          storagePath: 'test.jpg',
          downloadUrl: 'https://example.com/test.jpg',
          name: 'test.jpg',
          sizeBytes: 1024000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'user',
          isCover: true,
        ),
        MediaItem(
          id: '2',
          type: MediaType.image,
          storagePath: 'test2.jpg',
          downloadUrl: 'https://example.com/test2.jpg',
          name: 'test2.jpg',
          sizeBytes: 1024000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'user',
        ),
      ];

      final validationError = MediaConstraints.validateMediaList(validMedia);
      expect(validationError, isNull);
    });

    test('rejects media list with too many images', () {
      final tooManyImages = List.generate(15, (index) => MediaItem(
        id: '$index',
        type: MediaType.image,
        storagePath: 'test$index.jpg',
        downloadUrl: 'https://example.com/test$index.jpg',
        name: 'test$index.jpg',
        sizeBytes: 1024000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'user',
        isCover: index == 0,
      ));

      final validationError = MediaConstraints.validateMediaList(tooManyImages);
      expect(validationError, isNotNull);
      expect(validationError!.contains('Too many images'), isTrue);
    });

    test('rejects media list with multiple cover images', () {
      final multipleCovers = [
        MediaItem(
          id: '1',
          type: MediaType.image,
          storagePath: 'test1.jpg',
          downloadUrl: 'https://example.com/test1.jpg',
          name: 'test1.jpg',
          sizeBytes: 1024000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'user',
          isCover: true,
        ),
        MediaItem(
          id: '2',
          type: MediaType.image,
          storagePath: 'test2.jpg',
          downloadUrl: 'https://example.com/test2.jpg',
          name: 'test2.jpg',
          sizeBytes: 1024000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'user',
          isCover: true,
        ),
      ];

      final validationError = MediaConstraints.validateMediaList(multipleCovers);
      expect(validationError, isNotNull);
      expect(validationError!.contains('Exactly one image must be marked as cover'), isTrue);
    });
  });

  group('MediaAdapter', () {
    test('converts legacy Post to MediaItem list', () {
      final legacyData = MediaAdapter.fromLegacyPost(
        imageUrl: 'https://example.com/cover.jpg',
        imageUrls: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        pdfUrls: ['https://example.com/doc1.pdf'],
        postId: 'test_post',
        uploadedBy: 'test_user',
      );

      expect(legacyData.length, equals(4));
      expect(legacyData.where((m) => m.type == MediaType.image).length, equals(3));
      expect(legacyData.where((m) => m.type == MediaType.pdf).length, equals(1));
      expect(legacyData.where((m) => m.isCover).length, equals(1));
    });

    test('converts legacy ProductDesign to MediaItem list', () {
      final legacyFiles = <ProductDesignFile>[
        ProductDesignFile(
          id: '1',
          fileName: 'design.jpg',
          fileType: 'image',
          fileUrl: 'https://example.com/design.jpg',
          fileSize: 1024000,
          uploadDate: DateTime.now().toIso8601String(),
          isThumbnail: true,
        ),
        ProductDesignFile(
          id: '2',
          fileName: 'spec.pdf',
          fileType: 'pdf',
          fileUrl: 'https://example.com/spec.pdf',
          fileSize: 2048000,
          uploadDate: DateTime.now().toIso8601String(),
        ),
      ];

      final legacyData = MediaAdapter.fromLegacyProductDesign(
        files: legacyFiles,
        designId: 'test_design',
        uploadedBy: 'test_user',
      );

      expect(legacyData.length, equals(2));
      expect(legacyData.where((m) => m.type == MediaType.image).length, equals(1));
      expect(legacyData.where((m) => m.type == MediaType.pdf).length, equals(1));
      expect(legacyData.where((m) => m.isCover).length, equals(1));
    });

    test('converts MediaItem list back to legacy format', () {
      final mediaItems = [
        MediaItem(
          id: '1',
          type: MediaType.image,
          storagePath: 'test.jpg',
          downloadUrl: 'https://example.com/test.jpg',
          name: 'test.jpg',
          sizeBytes: 1024000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'user',
          isCover: true,
        ),
        MediaItem(
          id: '2',
          type: MediaType.pdf,
          storagePath: 'test.pdf',
          downloadUrl: 'https://example.com/test.pdf',
          name: 'test.pdf',
          sizeBytes: 2048000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'user',
        ),
      ];

      final legacyData = MediaAdapter.toLegacyPost(mediaItems);
      expect(legacyData['imageUrl'], equals('https://example.com/test.jpg'));
      expect(legacyData['imageUrls'], contains('https://example.com/test.jpg'));
      expect(legacyData['pdfUrls'], contains('https://example.com/test.pdf'));
    });
  });
}

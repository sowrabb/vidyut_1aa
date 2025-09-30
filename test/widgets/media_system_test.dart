// Simplified tests for the media upload system
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/features/stateinfo/models/media_models.dart';

void main() {
  group('Media System Core Tests', () {
    test('MediaItem model works correctly', () {
      final mediaItem = MediaItem(
        id: 'test_id',
        type: MediaType.image,
        storagePath: 'posts/test/images/image.jpg',
        downloadUrl: 'https://example.com/image.jpg',
        name: 'image.jpg',
        sizeBytes: 1024000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'test_user',
        isCover: true,
      );

      expect(mediaItem.id, equals('test_id'));
      expect(mediaItem.type, equals(MediaType.image));
      expect(mediaItem.name, equals('image.jpg'));
      expect(mediaItem.isCover, isTrue);
    });

    test('MediaType enum values are correct', () {
      expect(MediaType.image.name, equals('image'));
      expect(MediaType.pdf.name, equals('pdf'));
    });

    test('MediaConstraints validates image types correctly', () {
      expect(MediaConstraints.isValidImageType('image.jpg'), isTrue);
      expect(MediaConstraints.isValidImageType('image.jpeg'), isTrue);
      expect(MediaConstraints.isValidImageType('image.png'), isTrue);
      expect(MediaConstraints.isValidImageType('image.webp'), isTrue);
      expect(MediaConstraints.isValidImageType('image.gif'), isFalse);
    });

    test('MediaConstraints validates PDF types correctly', () {
      expect(MediaConstraints.isValidPdfType('document.pdf'), isTrue);
      expect(MediaConstraints.isValidPdfType('document.docx'), isFalse);
    });

    test('MediaConstraints validates file sizes correctly', () {
      expect(MediaConstraints.isValidImageSize(5 * 1024 * 1024), isTrue); // 5MB
      expect(MediaConstraints.isValidImageSize(15 * 1024 * 1024), isFalse); // 15MB
      expect(MediaConstraints.isValidPdfSize(25 * 1024 * 1024), isTrue); // 25MB
      expect(MediaConstraints.isValidPdfSize(75 * 1024 * 1024), isFalse); // 75MB
    });

    test('MediaConstraints validates media list correctly', () {
      final validMedia = [
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
        ),
      ];

      final validationError = MediaConstraints.validateMediaList(validMedia);
      expect(validationError, isNull);
    });

    test('MediaConstraints rejects too many images', () {
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

    test('MediaConstraints rejects multiple cover images', () {
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

    test('MediaAdapter converts legacy Post data correctly', () {
      final legacyData = MediaAdapter.fromLegacyPost(
        imageUrl: 'https://example.com/cover.jpg',
        imageUrls: ['https://example.com/image1.jpg'],
        pdfUrls: ['https://example.com/doc1.pdf'],
        postId: 'test_post',
        uploadedBy: 'test_user',
      );

      expect(legacyData.length, equals(3));
      expect(legacyData.where((m) => m.type == MediaType.image).length, equals(2));
      expect(legacyData.where((m) => m.type == MediaType.pdf).length, equals(1));
      expect(legacyData.where((m) => m.isCover).length, equals(1));
    });

    test('MediaAdapter converts to legacy format correctly', () {
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

  group('MediaUploadProgress Tests', () {
    test('MediaUploadProgress tracks progress correctly', () {
      final progress = MediaUploadProgress(
        fileId: 'test_file',
        fileName: 'image1.jpg',
        progress: 0.5,
        isCompleted: false,
        isCancelled: false,
      );

      expect(progress.fileId, equals('test_file'));
      expect(progress.fileName, equals('image1.jpg'));
      expect(progress.progress, equals(0.5));
      expect(progress.isCompleted, isFalse);
      expect(progress.isCancelled, isFalse);
    });

    test('MediaUploadProgress handles completion correctly', () {
      final progress = MediaUploadProgress(
        fileId: 'test_file',
        fileName: 'image1.jpg',
        progress: 1.0,
        isCompleted: true,
        isCancelled: false,
      );

      expect(progress.progress, equals(1.0));
      expect(progress.isCompleted, isTrue);
    });
  });
}

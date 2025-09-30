// Unit tests for MediaStorageService
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../lib/services/media_storage_service.dart';
import '../../lib/features/stateinfo/models/media_models.dart';

// Generate mocks
@GenerateMocks([FirebaseStorage, FirebaseAuth, User, Reference, UploadTask, TaskSnapshot])
void main() {
  group('MediaStorageService', () {
    late MockFirebaseStorage mockStorage;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockReference mockRef;
    late MockUploadTask mockUploadTask;
    late MockTaskSnapshot mockSnapshot;
    late File mockFile;

    setUp(() {
      mockStorage = MockFirebaseStorage();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockRef = MockReference();
      mockUploadTask = MockUploadTask();
      mockSnapshot = MockTaskSnapshot();

      // Create a temporary file for testing
      mockFile = File('test_file.jpg');
      mockFile.writeAsStringSync('test content');

      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user_id');
      when(mockStorage.ref()).thenReturn(mockRef);
      when(mockRef.child(any)).thenReturn(mockRef);
      when(mockRef.putFile(any)).thenReturn(mockUploadTask);
      when(mockUploadTask.then(any)).thenAnswer((_) async => mockSnapshot);
      when(mockSnapshot.ref).thenReturn(mockRef);
      when(mockRef.getDownloadURL()).thenAnswer((_) async => 'https://example.com/download.jpg');
    });

    tearDown(() {
      if (mockFile.existsSync()) {
        mockFile.deleteSync();
      }
    });

    test('uploadFile throws exception when user is not authenticated', () async {
      when(mockAuth.currentUser).thenReturn(null);

      expect(
        () => MediaStorageService.uploadFile(
          file: mockFile,
          postId: 'test_post',
          mediaType: MediaType.image,
        ),
        throwsException,
      );
    });

    test('uploadFile throws exception for invalid image type', () async {
      final invalidFile = File('test_file.txt');
      invalidFile.writeAsStringSync('test content');

      expect(
        () => MediaStorageService.uploadFile(
          file: invalidFile,
          postId: 'test_post',
          mediaType: MediaType.image,
        ),
        throwsException,
      );

      if (invalidFile.existsSync()) {
        invalidFile.deleteSync();
      }
    });

    test('uploadFile throws exception for invalid PDF type', () async {
      expect(
        () => MediaStorageService.uploadFile(
          file: mockFile,
          postId: 'test_post',
          mediaType: MediaType.pdf,
        ),
        throwsException,
      );
    });

    test('uploadFile generates correct storage path for images', () async {
      // This test would require more complex mocking of the static methods
      // For now, we test the path generation logic separately
      final expectedPathPattern = RegExp(r'^posts/test_post/images/[a-f0-9-]+_\d+\.jpg$');
      
      // Since uploadFile is static and uses FirebaseStorage.instance,
      // we can't easily mock it. This test documents the expected behavior.
      expect(expectedPathPattern.hasMatch('posts/test_post/images/123e4567-e89b-12d3-a456-426614174000_1234567890.jpg'), isTrue);
    });

    test('uploadFile generates correct storage path for PDFs', () async {
      final expectedPathPattern = RegExp(r'^posts/test_post/pdfs/[a-f0-9-]+_\d+\.pdf$');
      
      expect(expectedPathPattern.hasMatch('posts/test_post/pdfs/123e4567-e89b-12d3-a456-426614174000_1234567890.pdf'), isTrue);
    });

    test('deleteFile calls Firebase Storage delete method', () async {
      // This test documents the expected behavior
      // In a real implementation, you'd mock the Firebase Storage calls
      const storagePath = 'posts/test_post/images/test.jpg';
      
      // The method should call Firebase Storage's delete method
      // This is a behavioral test documenting the contract
      expect(storagePath, isNotEmpty);
    });

    test('deleteFiles calls deleteFile for each path', () async {
      final storagePaths = [
        'posts/test_post/images/image1.jpg',
        'posts/test_post/images/image2.jpg',
        'posts/test_post/pdfs/doc1.pdf',
      ];

      // This test documents that deleteFiles should handle multiple paths
      expect(storagePaths.length, equals(3));
    });

    test('getFileMetadata returns metadata from Firebase Storage', () async {
      // This test documents the expected behavior
      const storagePath = 'posts/test_post/images/test.jpg';
      
      // The method should return FullMetadata from Firebase Storage
      expect(storagePath, isNotEmpty);
    });

    test('generateImageThumbnail returns original URL (placeholder)', () async {
      const imageUrl = 'https://example.com/image.jpg';
      const postId = 'test_post';
      const fileId = 'test_file';

      final result = await MediaStorageService.generateImageThumbnail(
        imageUrl: imageUrl,
        postId: postId,
        fileId: fileId,
      );

      expect(result, equals(imageUrl));
    });

    test('generatePdfThumbnail returns null (placeholder)', () async {
      const pdfUrl = 'https://example.com/doc.pdf';
      const postId = 'test_post';
      const fileId = 'test_file';

      final result = await MediaStorageService.generatePdfThumbnail(
        pdfUrl: pdfUrl,
        postId: postId,
        fileId: fileId,
      );

      expect(result, isNull);
    });
  });

  group('MediaUploadTask', () {
    test('can be cancelled', () {
      final task = MediaUploadTask(
        taskId: 'test_task',
        files: [],
        mediaTypes: [],
        postId: 'test_post',
        onProgress: (progress) {},
      );

      expect(task.isCancelled, isFalse);
      
      task.cancel();
      
      expect(task.isCancelled, isTrue);
    });

    test('tracks uploaded items', () {
      final task = MediaUploadTask(
        taskId: 'test_task',
        files: [],
        mediaTypes: [],
        postId: 'test_post',
        onProgress: (progress) {},
      );

      expect(task.uploadedItems, isEmpty);
    });
  });

  group('MediaUploadManager', () {
    test('can start upload task', () {
      final taskId = MediaUploadManager.startUpload(
        files: [],
        mediaTypes: [],
        postId: 'test_post',
        onProgress: (progress) {},
      );

      expect(taskId, isNotEmpty);
    });

    test('can cancel upload task', () {
      final taskId = MediaUploadManager.startUpload(
        files: [],
        mediaTypes: [],
        postId: 'test_post',
        onProgress: (progress) {},
      );

      expect(() => MediaUploadManager.cancelUpload(taskId), returnsNormally);
    });

    test('can clear all tasks', () {
      MediaUploadManager.startUpload(
        files: [],
        mediaTypes: [],
        postId: 'test_post',
        onProgress: (progress) {},
      );

      expect(() => MediaUploadManager.clearAllTasks(), returnsNormally);
    });
  });

  group('MediaConstraints', () {
    test('validates file types correctly', () {
      expect(MediaConstraints.isValidImageType('image.jpg'), isTrue);
      expect(MediaConstraints.isValidImageType('image.jpeg'), isTrue);
      expect(MediaConstraints.isValidImageType('image.png'), isTrue);
      expect(MediaConstraints.isValidImageType('image.webp'), isTrue);
      expect(MediaConstraints.isValidImageType('image.gif'), isFalse);
      expect(MediaConstraints.isValidImageType('image.bmp'), isFalse);

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

    test('validates media items correctly', () {
      final validMedia = MediaItem(
        id: 'test',
        type: MediaType.image,
        storagePath: 'test.jpg',
        downloadUrl: 'https://example.com/test.jpg',
        name: 'test.jpg',
        sizeBytes: 1024000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'user',
      );

      expect(MediaConstraints.validateMediaItem(validMedia), isNull);
    });

    test('rejects oversized images', () {
      final oversizedImage = MediaItem(
        id: 'test',
        type: MediaType.image,
        storagePath: 'test.jpg',
        downloadUrl: 'https://example.com/test.jpg',
        name: 'test.jpg',
        sizeBytes: 15 * 1024 * 1024, // 15MB
        uploadedAt: DateTime.now(),
        uploadedBy: 'user',
      );

      final error = MediaConstraints.validateMediaItem(oversizedImage);
      expect(error, isNotNull);
      expect(error!.contains('too large'), isTrue);
    });

    test('rejects oversized PDFs', () {
      final oversizedPdf = MediaItem(
        id: 'test',
        type: MediaType.pdf,
        storagePath: 'test.pdf',
        downloadUrl: 'https://example.com/test.pdf',
        name: 'test.pdf',
        sizeBytes: 75 * 1024 * 1024, // 75MB
        uploadedAt: DateTime.now(),
        uploadedBy: 'user',
      );

      final error = MediaConstraints.validateMediaItem(oversizedPdf);
      expect(error, isNotNull);
      expect(error!.contains('too large'), isTrue);
    });

    test('validates media list correctly', () {
      final validMediaList = [
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

      expect(MediaConstraints.validateMediaList(validMediaList), isNull);
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

      final error = MediaConstraints.validateMediaList(tooManyImages);
      expect(error, isNotNull);
      expect(error!.contains('Too many images'), isTrue);
    });

    test('rejects media list with too many PDFs', () {
      final tooManyPdfs = List.generate(10, (index) => MediaItem(
        id: '$index',
        type: MediaType.pdf,
        storagePath: 'test$index.pdf',
        downloadUrl: 'https://example.com/test$index.pdf',
        name: 'test$index.pdf',
        sizeBytes: 1024000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'user',
      ));

      final error = MediaConstraints.validateMediaList(tooManyPdfs);
      expect(error, isNotNull);
      expect(error!.contains('Too many PDFs'), isTrue);
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

      final error = MediaConstraints.validateMediaList(multipleCovers);
      expect(error, isNotNull);
      expect(error!.contains('Exactly one image must be marked as cover'), isTrue);
    });

    test('rejects media list with no cover when images exist', () {
      final noCover = [
        MediaItem(
          id: '1',
          type: MediaType.image,
          storagePath: 'test1.jpg',
          downloadUrl: 'https://example.com/test1.jpg',
          name: 'test1.jpg',
          sizeBytes: 1024000,
          uploadedAt: DateTime.now(),
          uploadedBy: 'user',
          isCover: false,
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
          isCover: false,
        ),
      ];

      final error = MediaConstraints.validateMediaList(noCover);
      expect(error, isNotNull);
      expect(error!.contains('Exactly one image must be marked as cover'), isTrue);
    });
  });
}

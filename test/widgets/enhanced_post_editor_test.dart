// Widget tests for EnhancedPostEditor
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:uuid/uuid.dart';
import '../../lib/features/stateinfo/models/state_info_models.dart';
import '../../lib/features/stateinfo/models/media_models.dart';
import '../../lib/features/stateinfo/widgets/enhanced_post_editor.dart';

// Generate mocks
@GenerateMocks([])
void main() {
  group('EnhancedPostEditor', () {
    late String mockPostId;
    late String mockAuthor;
    late Function(Post) mockOnSave;

    setUp(() {
      mockPostId = const Uuid().v4();
      mockAuthor = 'test_user';
      mockOnSave = (post) {};
    });

    testWidgets('renders create new post editor', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      expect(find.text('Create New Post'), findsOneWidget);
      expect(find.text('Post Title *'), findsOneWidget);
      expect(find.text('Content *'), findsOneWidget);
      expect(find.text('Media Files'), findsOneWidget);
      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('Preview'), findsOneWidget);
    });

    testWidgets('renders edit post editor with initial data', (WidgetTester tester) async {
      final initialPost = Post(
        id: 'test_post',
        title: 'Test Title',
        content: 'Test Content',
        author: mockAuthor,
        time: DateTime.now().toString(),
        tags: ['tag1', 'tag2'],
        media: [
          MediaItem(
            id: 'test_image',
            type: MediaType.image,
            storagePath: 'posts/test/images/image.jpg',
            downloadUrl: 'https://example.com/image.jpg',
            name: 'image.jpg',
            sizeBytes: 1024000,
            uploadedAt: DateTime.now(),
            uploadedBy: mockAuthor,
            isCover: true,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              initialPost: initialPost,
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      expect(find.text('Edit Post'), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
      expect(find.text('Test Content'), findsOneWidget);
      expect(find.text('tag1'), findsOneWidget);
      expect(find.text('tag2'), findsOneWidget);
    });

    testWidgets('shows validation error for empty title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      // Fill content but leave title empty
      await tester.enterText(find.byType(TextField).at(1), 'Test content');
      await tester.pump();

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
    });

    testWidgets('shows validation error for empty content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      // Fill title but leave content empty
      await tester.enterText(find.byType(TextField).at(0), 'Test title');
      await tester.pump();

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter content'), findsOneWidget);
    });

    testWidgets('adds and removes tags correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      // Add a tag
      await tester.enterText(find.byType(TextField).at(2), 'new_tag');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('new_tag'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Remove the tag
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.text('new_tag'), findsNothing);
    });

    testWidgets('prevents adding duplicate tags', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      // Add a tag
      await tester.enterText(find.byType(TextField).at(2), 'duplicate_tag');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('duplicate_tag'), findsOneWidget);

      // Try to add the same tag again
      await tester.enterText(find.byType(TextField).at(2), 'duplicate_tag');
      await tester.tap(find.text('Add'));
      await tester.pump();

      expect(find.text('duplicate_tag'), findsOneWidget); // Still only one
    });

    testWidgets('shows media preview correctly', (WidgetTester tester) async {
      final initialPost = Post(
        id: 'test_post',
        title: 'Test Title',
        content: 'Test Content',
        author: mockAuthor,
        time: DateTime.now().toString(),
        media: [
          MediaItem(
            id: 'test_image',
            type: MediaType.image,
            storagePath: 'posts/test/images/image.jpg',
            downloadUrl: 'https://example.com/image.jpg',
            name: 'image.jpg',
            sizeBytes: 1024000,
            uploadedAt: DateTime.now(),
            uploadedBy: mockAuthor,
            isCover: true,
          ),
          MediaItem(
            id: 'test_pdf',
            type: MediaType.pdf,
            storagePath: 'posts/test/pdfs/doc.pdf',
            downloadUrl: 'https://example.com/doc.pdf',
            name: 'doc.pdf',
            sizeBytes: 2048000,
            uploadedAt: DateTime.now(),
            uploadedBy: mockAuthor,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              initialPost: initialPost,
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      expect(find.text('Images (1)'), findsOneWidget);
      expect(find.text('PDFs (1)'), findsOneWidget);
    });

    testWidgets('shows preview with title and content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      // Enter title and content
      await tester.enterText(find.byType(TextField).at(0), 'Preview Title');
      await tester.enterText(find.byType(TextField).at(1), 'Preview content here');
      await tester.pump();

      expect(find.text('Preview Title'), findsOneWidget);
      expect(find.text('Preview content here'), findsOneWidget);
    });

    testWidgets('handles media constraints validation', (WidgetTester tester) async {
      // Create a post with too many media items
      final tooManyMedia = List.generate(20, (index) => MediaItem(
        id: '$index',
        type: MediaType.image,
        storagePath: 'posts/test/images/image$index.jpg',
        downloadUrl: 'https://example.com/image$index.jpg',
        name: 'image$index.jpg',
        sizeBytes: 1024000,
        uploadedAt: DateTime.now(),
        uploadedBy: mockAuthor,
        isCover: index == 0,
      ));

      final initialPost = Post(
        id: 'test_post',
        title: 'Test Title',
        content: 'Test Content',
        author: mockAuthor,
        time: DateTime.now().toString(),
        media: tooManyMedia,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EnhancedPostEditor(
              initialPost: initialPost,
              postId: mockPostId,
              author: mockAuthor,
              onSave: mockOnSave,
            ),
          ),
        ),
      );

      // Try to save
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Too many files. Maximum allowed: 15'), findsOneWidget);
    });
  });

  group('showEnhancedPostEditor', () {
    testWidgets('shows post editor in modal bottom sheet', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showEnhancedPostEditor(
                    context: context,
                    postId: const Uuid().v4(),
                    author: 'test_user',
                    onSave: (post) {},
                  );
                },
                child: const Text('Show Editor'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Editor'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Post'), findsOneWidget);
      expect(find.text('Post Title *'), findsOneWidget);
    });
  });
}

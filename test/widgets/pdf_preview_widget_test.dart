import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/features/stateinfo/models/media_models.dart';
import 'package:vidyut/features/stateinfo/widgets/pdf_preview_widget.dart';

void main() {
  group('PdfPreviewWidget', () {
    late MediaItem mockPdfItem;

    setUp(() {
      mockPdfItem = MediaItem(
        id: 'test_pdf',
        type: MediaType.pdf,
        storagePath: 'posts/test/pdfs/document.pdf',
        downloadUrl: 'https://example.com/document.pdf',
        name: 'document.pdf',
        sizeBytes: 2048000,
        uploadedAt: DateTime.now(),
        uploadedBy: 'test_user',
      );
    });

    Future<void> _pump(WidgetTester tester, {bool showFileName = true, bool showFileSize = true}) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PdfPreviewWidget(
                pdfItem: mockPdfItem,
                showFileName: showFileName,
                showFileSize: showFileSize,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders PDF preview with default options', (tester) async {
      await _pump(tester);

      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.text('2000.0 KB'), findsOneWidget);
    });

    testWidgets('respects showFileName flag', (tester) async {
      await _pump(tester, showFileName: false);

      expect(find.text('document.pdf'), findsNothing);
    });

    testWidgets('respects showFileSize flag', (tester) async {
      await _pump(tester, showFileSize: false);

      expect(find.text('2000.0 KB'), findsNothing);
    });

    testWidgets('invokes onTap when provided', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PdfPreviewWidget(
                pdfItem: mockPdfItem,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PdfPreviewWidget));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}

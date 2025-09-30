import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/widgets/image_upload_widget.dart';
import 'package:vidyut/widgets/lightweight_image_widget.dart';

void main() {
  testWidgets('ImageUploadWidget shows placeholder when no image',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ImageUploadWidget(
            currentImagePath: null,
            onImageSelected: _noopOnImageSelected,
            showPreview: true,
          ),
        ),
      ),
    );

    expect(find.text('No image selected'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.byIcon(Icons.photo_library), findsOneWidget);
    expect(find.byIcon(Icons.folder_open), findsOneWidget);
  });

  testWidgets('LightweightImageWidget renders asset image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LightweightImageWidget(
            imagePath: 'assets/logo.png',
            width: 100,
            height: 100,
          ),
        ),
      ),
    );

    // Should build an Image widget without throwing
    expect(find.byType(Image), findsOneWidget);
  });
}

void _noopOnImageSelected(dynamic _) {}

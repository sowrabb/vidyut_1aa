import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/widgets/lightweight_image_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('LightweightImageWidget shows error for invalid path',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: LightweightImageWidget(imagePath: 'invalid://path'),
      ),
    ));

    expect(find.byIcon(Icons.broken_image), findsOneWidget);
  });
}

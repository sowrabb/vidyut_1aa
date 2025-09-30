import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/app/app.dart';
import 'package:vidyut/app/auth_wrapper.dart';
import 'package:vidyut/app/theme.dart';

/// Test-specific main function that bypasses Firebase initialization
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Skip Firebase initialization for testing
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Optimize image cache for better performance
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      100 * 1024 * 1024; // 100MB limit

  runApp(const ProviderScope(child: VidyutTestApp()));
}

/// Test version of the app that bypasses Firebase auth
class VidyutTestApp extends StatelessWidget {
  const VidyutTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidyut Test',
      debugShowCheckedModeBanner: false,
      theme: buildVidyutTheme(),
      home: const TestAuthWrapper(),
    );
  }
}

/// Test version of auth wrapper that always shows the main app
class TestAuthWrapper extends StatelessWidget {
  const TestAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Always show the main app for testing
    return const MainApp();
  }
}

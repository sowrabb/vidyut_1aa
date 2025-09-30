import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/theme.dart';
import 'app/main_app_v2.dart';
import 'firebase_options.dart';

class TestAppV2 extends StatelessWidget {
  const TestAppV2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidyut V2 (Unified Providers)',
      debugShowCheckedModeBanner: false,
      theme: buildVidyutTheme(),
      home: const MainAppV2(),
    );
  }
}

void mainV2() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optimize image cache for better performance
  PaintingBinding.instance.imageCache.maximumSize = 100;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;

  runApp(const ProviderScope(child: TestAppV2()));
}


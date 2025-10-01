import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
import 'firebase_options.dart';
import 'state/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Optimize image cache for better performance
  PaintingBinding.instance.imageCache.maximumSize =
      100; // Increased cache size for gallery screens
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      100 * 1024 * 1024; // 100MB limit

  runApp(buildAppProviderScope(child: const VidyutApp()));
}

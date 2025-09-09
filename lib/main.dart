import 'package:flutter/widgets.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';
// import 'services/firebase_service.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (temporarily commented out for web deployment)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  // Initialize Firebase services
  // await FirebaseService.initialize();
  
  runApp(const VidyutApp());
}

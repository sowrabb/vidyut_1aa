import 'package:flutter/material.dart';
import 'theme.dart';
import 'auth_wrapper.dart';
import '../features/auth/phone_signup_page.dart';
import '../features/reviews/reviews_page.dart';
import '../features/reviews/review_composer.dart';

class VidyutApp extends StatelessWidget {
  const VidyutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vidyut',
      debugShowCheckedModeBanner: false,
      theme: buildVidyutTheme(),
      home: const AuthWrapper(),
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith('/seller/orders')) {
          // Redirect legacy orders URLs to Seller hub (safe default)
          return MaterialPageRoute(
            builder: (_) => const AuthWrapper(),
            settings: const RouteSettings(name: '/sell'),
          );
        }
        return null; // fallback to routes map
      },
      routes: {
        '/signup': (context) => const PhoneSignupPage(),
        // Reviews feature routes (avoid registering '/' when home is set)
        '/reviews': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final productId = (args is String) ? args : '';
          return ReviewsPage(productId: productId);
        },
        '/write-review': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final productId = (args is String) ? args : '';
          return ReviewComposer(productId: productId);
        },
      },
    );
  }
}

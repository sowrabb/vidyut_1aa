import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  // Method to reset splash screen behavior (for testing)
  static Future<void> resetSplashBehavior() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('app_loaded_before');
  }
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'Loading...';

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  void _handleNavigation() async {
    if (kIsWeb) {
      // For web, check if this is the first time loading
      final prefs = await SharedPreferences.getInstance();
      final hasLoadedBefore = prefs.getBool('app_loaded_before') ?? false;
      
      if (!hasLoadedBefore) {
        // First time loading - show splash screen for the full Flutter web loading time
        setState(() {
          _statusText = 'Initializing app for the first time...';
        });
        await prefs.setBool('app_loaded_before', true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      } else {
        // Subsequent loads - navigate immediately
        setState(() {
          _statusText = 'App already loaded, redirecting...';
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        });
      }
    } else {
      // For mobile, use the standard 3-second delay
      setState(() {
        _statusText = 'Loading app...';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with subtle shadow
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/logo.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (_, __, ___) => Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.electrical_services,
                      size: 80,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // App Name with Material 3 typography
            Text(
              'VidyutNidhi',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Produced by Madhu Powertech Pvt. Ltd.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 24),
            
            // Status text
            Text(
              _statusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            
            // Material 3 Circular Progress Indicator with custom styling
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

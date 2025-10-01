import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/firebase_auth_page.dart';
import '../features/auth/pages/seller_onboarding_page.dart';
import '../features/profile/user_profile_page.dart';
import '../app/layout/responsive_scaffold.dart';
import '../app/tokens.dart';
import '../../../app/provider_registry.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final sessionState = ref.watch(sessionControllerProvider);

    if (authState.isLoading || sessionState.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to Vidyut...'),
            ],
          ),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const MainApp();
    }

    return const FirebaseAuthPage();
  }
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const ResponsiveScaffold(initialIndex: 0),
      // Removed floatingActionButton to eliminate overlap with navigation bar
    );
  }


  void _showProfileDialog(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final authController = ref.read(authControllerProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              session.isGuest
                  ? Icons.person_outline
                  : session.isSeller
                      ? Icons.store
                      : Icons.person,
              color: session.isGuest
                  ? Colors.orange
                  : session.isSeller
                      ? Colors.green
                      : Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(session.isGuest
                ? 'Guest User'
                : session.isSeller
                    ? 'Seller Hub'
                    : 'Profile'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (session.isGuest) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade600, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Guest Mode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You\'re browsing as a guest. Sign up to save preferences, create listings and access all features.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('Name: ${session.displayName ?? 'Guest User'}'),
            const SizedBox(height: 8),
            Text('Email: ${session.email ?? 'Not provided'}'),
            const SizedBox(height: 8),
            Text('Role: ${session.role.displayName}'),
            if (!session.isGuest) ...[
              const SizedBox(height: 8),
              Text('Email Verified: ${session.isEmailVerified ? 'Yes' : 'No'}'),
            ],
            if (session.profile?.phone != null) ...[
              const SizedBox(height: 8),
              Text('Phone: ${session.profile!.phone!}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!session.isGuest) ...[
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UserProfilePage(),
                  ),
                );
              },
              child: const Text('Edit Profile'),
            ),
          ],
          if (session.canBecomeSeller) ...[
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SellerOnboardingPage(),
                  ),
                );
              },
              icon: const Icon(Icons.store_mall_directory_outlined),
              label: const Text('Become a Seller'),
            ),
          ],
          if (session.isAuthenticated)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await authController.signOut();
              },
              child: const Text('Sign Out'),
            ),
        ],
      ),
    );
  }
}

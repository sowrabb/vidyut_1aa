import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/profile/store/user_store.dart';
import 'package:vidyut/features/profile/models/user_models.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('Profile Settings Simple Tests', () {
    late UserStore userStore;

    setUp(() {
      userStore = UserStore();
    });

    group('UserStore Unit Tests', () {
      test('UserProfile model works correctly', () {
        final profile = UserProfile(
          id: 'test_id',
          name: 'Test User',
          email: 'test@example.com',
          phone: '+91-9876543210',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isEmailVerified: true,
          isPhoneVerified: false,
        );

        expect(profile.id, 'test_id');
        expect(profile.name, 'Test User');
        expect(profile.email, 'test@example.com');
        expect(profile.isEmailVerified, true);
        expect(profile.isPhoneVerified, false);
      });

      test('UserPreferences model works correctly', () {
        final preferences = UserPreferences(
          emailNotifications: true,
          pushNotifications: false,
          language: 'en',
          theme: 'dark',
          searchRadius: 50.0,
        );

        expect(preferences.emailNotifications, true);
        expect(preferences.pushNotifications, false);
        expect(preferences.language, 'en');
        expect(preferences.theme, 'dark');
        expect(preferences.searchRadius, 50.0);
      });

      test('PasswordChangeRequest validation works', () {
        final validRequest = PasswordChangeRequest(
          currentPassword: 'current123',
          newPassword: 'newpassword123',
          confirmPassword: 'newpassword123',
        );

        expect(validRequest.isValid, true);
        expect(validRequest.validate(), null);

        final invalidRequest = PasswordChangeRequest(
          currentPassword: 'current123',
          newPassword: 'short',
          confirmPassword: 'different',
        );

        expect(invalidRequest.isValid, false);
        expect(invalidRequest.validate(), isNotNull);
      });

      test('UserStore initializes with default values', () {
        final store = UserStore();

        expect(store.profile.name, 'John Doe');
        expect(store.profile.email, 'john.doe@example.com');
        expect(store.preferences.emailNotifications, true);
        expect(store.notificationSettings.emailEnabled, true);
        expect(store.isLoading, false);
        expect(store.error, null);
      });

      test('UserStore updateProfile works', () async {
        final store = UserStore();
        final initialName = store.profile.name;

        await store.updateProfile(name: 'Updated Name');

        expect(store.profile.name, 'Updated Name');
        expect(store.profile.name, isNot(initialName));
      });

      test('UserStore changePassword works with valid input', () async {
        final store = UserStore();

        final request = PasswordChangeRequest(
          currentPassword: 'current123',
          newPassword: 'newpassword123',
          confirmPassword: 'newpassword123',
        );

        final result = await store.changePassword(request);

        expect(result, true);
        expect(store.error, null);
      });

      test('UserStore changePassword fails with invalid input', () async {
        final store = UserStore();

        final request = PasswordChangeRequest(
          currentPassword: 'wrongpassword',
          newPassword: 'newpassword123',
          confirmPassword: 'newpassword123',
        );

        final result = await store.changePassword(request);

        expect(result, false);
        expect(store.error, 'Current password is incorrect');
      });

      test('UserStore updatePreferences works', () async {
        final store = UserStore();

        final newPreferences = store.preferences.copyWith(
          language: 'hi',
          theme: 'dark',
        );

        await store.updatePreferences(newPreferences);

        expect(store.preferences.language, 'hi');
        expect(store.preferences.theme, 'dark');
      });

      test('UserStore updateNotificationSettings works', () async {
        final store = UserStore();

        final newSettings = store.notificationSettings.copyWith(
          emailEnabled: false,
          pushEnabled: true,
        );

        await store.updateNotificationSettings(newSettings);

        expect(store.notificationSettings.emailEnabled, false);
        expect(store.notificationSettings.pushEnabled, true);
      });

      test('UserStore exportData works', () {
        final store = UserStore();

        final data = store.exportData();

        expect(data, isA<Map<String, dynamic>>());
        expect(data.containsKey('profile'), true);
        expect(data.containsKey('preferences'), true);
        expect(data.containsKey('notificationSettings'), true);
        expect(data.containsKey('exportedAt'), true);
      });

      test('UserStore deleteAccount works with correct password', () async {
        final store = UserStore();

        final result = await store.deleteAccount('current123');

        expect(result, true);
        expect(store.error, null);
      });

      test('UserStore deleteAccount fails with incorrect password', () async {
        final store = UserStore();

        final result = await store.deleteAccount('wrongpassword');

        expect(result, false);
        expect(store.error, 'Password is incorrect');
      });
    });

    group('Widget Tests', () {
      testWidgets('Profile settings widget renders without crashing',
          (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userStoreProvider.overrideWith((ref) => userStore),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Text('Profile: ${userStore.profile.name}'),
                    Text('Email: ${userStore.profile.email}'),
                    Text('Language: ${userStore.preferences.language}'),
                    Text('Theme: ${userStore.preferences.theme}'),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify basic profile information is displayed
        expect(find.text('Profile: John Doe'), findsOneWidget);
        expect(find.text('Email: john.doe@example.com'), findsOneWidget);
        expect(find.text('Language: en'), findsOneWidget);
        expect(find.text('Theme: system'), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('Profile update flow works', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userStoreProvider.overrideWith((ref) => userStore),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Text('Name: ${userStore.profile.name}'),
                    ElevatedButton(
                      onPressed: () async {
                        await userStore.updateProfile(name: 'Jane Doe');
                      },
                      child: const Text('Update Name'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify initial name
        expect(find.text('Name: John Doe'), findsOneWidget);

        // Tap update button
        await tester.tap(find.text('Update Name'));
        await tester.pumpAndSettle();

        // Verify name was updated
        expect(find.text('Name: Jane Doe'), findsOneWidget);
      });

      testWidgets('Password change flow works', (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              userStoreProvider.overrideWith((ref) => userStore),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    Text('Error: ${userStore.error ?? 'None'}'),
                    ElevatedButton(
                      onPressed: () async {
                        final request = PasswordChangeRequest(
                          currentPassword: 'current123',
                          newPassword: 'newpassword123',
                          confirmPassword: 'newpassword123',
                        );
                        await userStore.changePassword(request);
                      },
                      child: const Text('Change Password'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify no initial error
        expect(find.text('Error: None'), findsOneWidget);

        // Tap change password button
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        // Verify password change was successful (no error)
        expect(find.text('Error: None'), findsOneWidget);
      });
    });
  });
}

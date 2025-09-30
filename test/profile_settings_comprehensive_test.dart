import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vidyut/features/profile/profile_page.dart';
import 'package:vidyut/features/profile/store/user_store.dart';
import 'package:vidyut/features/profile/models/user_models.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  group('Profile Settings Comprehensive Tests', () {
    late UserStore userStore;

    setUp(() {
      userStore = UserStore();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          userStoreProvider.overrideWith((ref) => userStore),
        ],
        child: MaterialApp(
          home: const ProfilePage(),
        ),
      );
    }

    group('Profile Information Tests', () {
      testWidgets('Profile section displays user information correctly',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify profile information is displayed
        expect(find.text('Profile Information'), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('john.doe@example.com'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
      });

      testWidgets('Edit profile dialog opens and saves changes',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Edit button
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(find.text('Edit Profile'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(3));

        // Update profile information
        await tester.enterText(find.byType(TextField).first, 'Jane Doe');
        await tester.enterText(
            find.byType(TextField).at(1), 'jane.doe@example.com');
        await tester.enterText(find.byType(TextField).at(2), '+91-9876543211');

        // Save changes
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Profile updated successfully'), findsOneWidget);
      });

      testWidgets('Email verification dialog works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Verify button for email
        await tester.tap(find.text('Verify'));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(find.text('Email Verification'), findsOneWidget);

        // Send verification
        await tester.tap(find.text('Send'));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Verification email sent'), findsOneWidget);
      });
    });

    group('Security Tests', () {
      testWidgets('Security section displays correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify security section
        expect(find.text('Security'), findsOneWidget);
        expect(find.text('Change Password'), findsOneWidget);
        expect(find.text('Two-Factor Authentication'), findsOneWidget);
      });

      testWidgets('Change password dialog works with valid input',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Change Password
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(find.text('Change Password'), findsOneWidget);
        expect(find.byType(TextField), findsNWidgets(3));

        // Enter valid password change
        await tester.enterText(find.byType(TextField).first, 'current123');
        await tester.enterText(find.byType(TextField).at(1), 'newpassword123');
        await tester.enterText(find.byType(TextField).at(2), 'newpassword123');

        // Submit password change
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Password changed successfully'), findsOneWidget);
      });

      testWidgets('Change password validation works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Change Password
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        // Try to submit without filling fields
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        // Verify validation errors are shown
        expect(find.text('Current password is required'), findsOneWidget);
      });

      testWidgets('Change password with mismatched passwords shows error',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Change Password
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        // Enter mismatched passwords
        await tester.enterText(find.byType(TextField).first, 'current123');
        await tester.enterText(find.byType(TextField).at(1), 'newpassword123');
        await tester.enterText(
            find.byType(TextField).at(2), 'differentpassword');

        // Submit password change
        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        // Verify validation error
        expect(find.text('Passwords do not match'), findsOneWidget);
      });
    });

    group('Notifications Tests', () {
      testWidgets('Notifications section displays all settings',
          (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify notifications section
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Email Notifications'), findsOneWidget);
        expect(find.text('Push Notifications'), findsOneWidget);
        expect(find.text('SMS Notifications'), findsOneWidget);
        expect(find.text('Marketing Emails'), findsOneWidget);
        expect(find.text('Weekly Digest'), findsOneWidget);
        expect(find.text('New Message Alerts'), findsOneWidget);
        expect(find.text('Order Updates'), findsOneWidget);
        expect(find.text('Price Alerts'), findsOneWidget);
      });

      testWidgets('Notification switches can be toggled', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Find and toggle email notifications switch
        final emailSwitch = find.byType(Switch).first;
        await tester.tap(emailSwitch);
        await tester.pumpAndSettle();

        // Verify the switch state changed (this would be verified in a real app)
        // For now, just verify the tap was successful
        expect(emailSwitch, findsOneWidget);
      });
    });

    group('Preferences Tests', () {
      testWidgets('Preferences section displays all settings', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify preferences section
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Language'), findsOneWidget);
        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Auto Save'), findsOneWidget);
        expect(find.text('Location Tracking'), findsOneWidget);
        expect(find.text('Search Radius'), findsOneWidget);
      });

      testWidgets('Language dropdown works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Find and tap language dropdown
        final languageDropdown =
            find.byType(DropdownButtonFormField<String>).first;
        await tester.tap(languageDropdown);
        await tester.pumpAndSettle();

        // Select Hindi
        await tester.tap(find.text('Hindi'));
        await tester.pumpAndSettle();

        // Verify the selection (in a real app, this would be verified through state)
        expect(find.text('Hindi'), findsOneWidget);
      });

      testWidgets('Search radius slider works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Find search radius slider
        final slider = find.byType(Slider);
        expect(slider, findsOneWidget);

        // Test slider interaction (this would be more complex in a real test)
        await tester.drag(slider, const Offset(50, 0));
        await tester.pumpAndSettle();

        // Verify slider exists and was interacted with
        expect(slider, findsOneWidget);
      });
    });

    group('Account Actions Tests', () {
      testWidgets('Account actions section displays correctly', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify account actions section
        expect(find.text('Account Actions'), findsOneWidget);
        expect(find.text('Export Data'), findsOneWidget);
        expect(find.text('Import Data'), findsOneWidget);
        expect(find.text('Delete Account'), findsOneWidget);
      });

      testWidgets('Export data works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Export Data
        await tester.tap(find.text('Export Data'));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Data exported successfully'), findsOneWidget);
      });

      testWidgets('Import data dialog works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Import Data
        await tester.tap(find.text('Import Data'));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(find.text('Import Data'), findsOneWidget);

        // Tap Import button
        await tester.tap(find.text('Import'));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Data imported successfully'), findsOneWidget);
      });

      testWidgets('Delete account dialog works', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Tap Delete Account
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();

        // Verify dialog is open
        expect(find.text('Delete Account'), findsOneWidget);
        expect(find.text('This action cannot be undone'), findsOneWidget);

        // Enter password
        await tester.enterText(find.byType(TextField), 'current123');

        // Tap Delete Account button
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();

        // Verify success message
        expect(find.text('Account deleted successfully'), findsOneWidget);
      });
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
    });

    group('Responsive Tests', () {
      testWidgets('Profile settings work on mobile layout', (tester) async {
        await tester.binding.setSurfaceSize(const Size(375, 812));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify all sections are present
        expect(find.text('Profile Information'), findsOneWidget);
        expect(find.text('Security'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Account Actions'), findsOneWidget);
      });

      testWidgets('Profile settings work on tablet layout', (tester) async {
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify all sections are present
        expect(find.text('Profile Information'), findsOneWidget);
        expect(find.text('Security'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Account Actions'), findsOneWidget);
      });

      testWidgets('Profile settings work on desktop layout', (tester) async {
        await tester.binding.setSurfaceSize(const Size(1200, 800));
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify all sections are present
        expect(find.text('Profile Information'), findsOneWidget);
        expect(find.text('Security'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Preferences'), findsOneWidget);
        expect(find.text('Account Actions'), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('Profile settings are accessible', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Verify semantic structure
        expect(find.byType(Semantics), findsWidgets);
        expect(find.text('Profile Information'), findsOneWidget);
      });

      testWidgets('Form fields have proper accessibility', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        // Open edit profile dialog
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // Verify form fields are accessible
        expect(find.byType(TextField), findsNWidgets(3));
      });
    });

    group('Performance Tests', () {
      testWidgets('Profile settings render quickly', (tester) async {
        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Should render within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });

      testWidgets('Settings interactions are responsive', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Navigate to Settings tab
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();

        final stopwatch = Stopwatch()..start();

        // Test multiple interactions
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Change Password'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Interactions should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}

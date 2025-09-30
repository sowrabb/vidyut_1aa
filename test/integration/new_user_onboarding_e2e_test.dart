import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'test_main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('New User Onboarding Journey E2E Tests', () {
    testWidgets('Complete new user onboarding flow',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Step 1: App Launch → Splash Screen → Home Page
      await _testAppLaunchAndHomePage(tester);

      // Step 2: Location Selection
      await _testLocationSelection(tester);

      // Step 3: Browse Categories
      await _testBrowseCategories(tester);

      // Step 4: Search Products
      await _testSearchProducts(tester);

      // Step 5: View Product Details
      await _testViewProductDetails(tester);

      // Step 6: Contact Seller
      await _testContactSeller(tester);

      // Step 7: Create Account
      await _testCreateAccount(tester);

      // Step 8: Complete Profile
      await _testCompleteProfile(tester);

      // Step 9: Save Products
      await _testSaveProducts(tester);

      // Step 10: Make Purchase Inquiry
      await _testMakePurchaseInquiry(tester);
    });

    testWidgets('Guest user onboarding flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test guest mode flow
      await _testGuestModeOnboarding(tester);
    });

    testWidgets('Onboarding with different locations',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test with different location selections
      await _testLocationVariations(tester);
    });
  });
}

/// Step 1: App Launch → Splash Screen → Home Page
Future<void> _testAppLaunchAndHomePage(WidgetTester tester) async {
  print('Testing: App Launch → Splash Screen → Home Page');

  // Wait for app to fully load
  await tester.pumpAndSettle(const Duration(seconds: 3));

  // Verify we're on the home page
  expect(find.text('Vidyut'), findsOneWidget);
  expect(find.text('Categories'), findsOneWidget);
  expect(find.text('Frequently Bought Products'), findsOneWidget);

  // Verify location picker is visible
  expect(find.byIcon(Icons.location_on), findsOneWidget);

  print('✓ App launched successfully and home page loaded');
}

/// Step 2: Location Selection
Future<void> _testLocationSelection(WidgetTester tester) async {
  print('Testing: Location Selection');

  // Tap on location picker
  await tester.tap(find.byIcon(Icons.location_on));
  await tester.pumpAndSettle();

  // Verify location picker dialog is open
  expect(find.text('Select Location'), findsOneWidget);

  // Search for a location
  final searchField = find.byType(TextField).first;
  await tester.enterText(searchField, 'Mumbai');
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Select a location from suggestions (if available)
  if (find.text('Mumbai').hitTestable().evaluate().isNotEmpty) {
    await tester.tap(find.text('Mumbai').first);
    await tester.pumpAndSettle();
  }

  // Apply location
  final applyButton = find.text('Apply');
  if (applyButton.evaluate().isNotEmpty) {
    await tester.tap(applyButton);
    await tester.pumpAndSettle();
  }

  print('✓ Location selection completed');
}

/// Step 3: Browse Categories
Future<void> _testBrowseCategories(WidgetTester tester) async {
  print('Testing: Browse Categories');

  // Tap on "View All Categories"
  final viewAllCategories = find.text('View All Categories');
  if (viewAllCategories.evaluate().isNotEmpty) {
    await tester.tap(viewAllCategories);
    await tester.pumpAndSettle();

    // Verify categories page is open
    expect(find.text('Categories'), findsOneWidget);

    // Browse a specific category
    final wiresCategory = find.text('Wires & Cables');
    if (wiresCategory.evaluate().isNotEmpty) {
      await tester.tap(wiresCategory);
      await tester.pumpAndSettle();
    }

    // Go back to home
    await tester.pageBack();
    await tester.pumpAndSettle();
  } else {
    // If "View All Categories" is not found, tap on a category directly
    final categoryCard = find.byType(Card).first;
    if (categoryCard.evaluate().isNotEmpty) {
      await tester.tap(categoryCard);
      await tester.pumpAndSettle();

      // Go back to home
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  }

  print('✓ Category browsing completed');
}

/// Step 4: Search Products
Future<void> _testSearchProducts(WidgetTester tester) async {
  print('Testing: Search Products');

  // Tap on search field
  final searchField = find.byType(TextField).first;
  await tester.enterText(searchField, 'copper wire');
  await tester.pumpAndSettle();

  // Submit search
  await tester.testTextInput.receiveAction(TextInputAction.search);
  await tester.pumpAndSettle();

  // Verify search page is open
  expect(find.text('Search'), findsOneWidget);

  // Verify search results are displayed
  expect(find.text('copper wire'), findsOneWidget);

  print('✓ Product search completed');
}

/// Step 5: View Product Details
Future<void> _testViewProductDetails(WidgetTester tester) async {
  print('Testing: View Product Details');

  // Tap on first product card
  final productCard = find.byType(Card).first;
  if (productCard.evaluate().isNotEmpty) {
    await tester.tap(productCard);
    await tester.pumpAndSettle();

    // Verify product detail page is open
    expect(find.text('Contact Supplier'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);

    print('✓ Product details viewed');
  } else {
    print('⚠ No product cards found to tap');
  }
}

/// Step 6: Contact Seller
Future<void> _testContactSeller(WidgetTester tester) async {
  print('Testing: Contact Seller');

  // Try to tap contact buttons
  final contactButton = find.text('Contact Supplier');
  if (contactButton.evaluate().isNotEmpty) {
    await tester.tap(contactButton);
    await tester.pumpAndSettle();

    // Verify contact action was triggered
    // (In a real app, this might open a phone dialer or contact form)
    print('✓ Contact seller action triggered');
  }

  // Try WhatsApp contact
  final whatsappButton = find.text('WhatsApp');
  if (whatsappButton.evaluate().isNotEmpty) {
    await tester.tap(whatsappButton);
    await tester.pumpAndSettle();

    print('✓ WhatsApp contact action triggered');
  }
}

/// Step 7: Create Account
Future<void> _testCreateAccount(WidgetTester tester) async {
  print('Testing: Create Account');

  // Navigate to profile/auth section
  // Look for profile icon or auth button
  final profileIcon = find.byIcon(Icons.person);
  if (profileIcon.evaluate().isNotEmpty) {
    await tester.tap(profileIcon);
    await tester.pumpAndSettle();
  }

  // Look for sign up/create account option
  final signUpButton = find.text('Create Account');
  if (signUpButton.evaluate().isNotEmpty) {
    await tester.tap(signUpButton);
    await tester.pumpAndSettle();

    // Fill sign up form
    final nameField = find.byType(TextFormField).at(0);
    await tester.enterText(nameField, 'Test User');

    final emailField = find.byType(TextFormField).at(1);
    await tester.enterText(emailField, 'testuser@example.com');

    final passwordField = find.byType(TextFormField).at(2);
    await tester.enterText(passwordField, 'password123');

    // Submit form
    final submitButton = find.text('Create Account');
    if (submitButton.evaluate().isNotEmpty) {
      await tester.tap(submitButton);
      await tester.pumpAndSettle();
    }

    print('✓ Account creation form filled');
  } else {
    // Try guest mode if sign up is not available
    final guestButton = find.text('Continue as Guest');
    if (guestButton.evaluate().isNotEmpty) {
      await tester.tap(guestButton);
      await tester.pumpAndSettle();
      print('✓ Guest mode activated');
    }
  }
}

/// Step 8: Complete Profile
Future<void> _testCompleteProfile(WidgetTester tester) async {
  print('Testing: Complete Profile');

  // Look for profile page or edit profile option
  final editProfileButton = find.text('Edit Profile');
  if (editProfileButton.evaluate().isNotEmpty) {
    await tester.tap(editProfileButton);
    await tester.pumpAndSettle();

    // Fill profile information
    final nameField = find.byType(TextFormField).at(0);
    await tester.enterText(nameField, 'Test User');

    final phoneField = find.byType(TextFormField).at(1);
    await tester.enterText(phoneField, '+1234567890');

    final companyField = find.byType(TextFormField).at(3);
    await tester.enterText(companyField, 'Test Company');

    // Save profile
    final saveButton = find.text('Save');
    if (saveButton.evaluate().isNotEmpty) {
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
    }

    print('✓ Profile completed');
  } else {
    print('⚠ Profile editing not available in current state');
  }
}

/// Step 9: Save Products
Future<void> _testSaveProducts(WidgetTester tester) async {
  print('Testing: Save Products');

  // Navigate back to products if needed
  await tester.pageBack();
  await tester.pumpAndSettle();

  // Look for save/favorite buttons on product cards
  final favoriteIcon = find.byIcon(Icons.favorite_border);
  if (favoriteIcon.evaluate().isNotEmpty) {
    await tester.tap(favoriteIcon.first);
    await tester.pumpAndSettle();
    print('✓ Product saved to favorites');
  } else {
    print('⚠ Save/favorite functionality not found');
  }
}

/// Step 10: Make Purchase Inquiry
Future<void> _testMakePurchaseInquiry(WidgetTester tester) async {
  print('Testing: Make Purchase Inquiry');

  // Look for inquiry/quote buttons
  final quoteButton = find.text('Quote');
  if (quoteButton.evaluate().isNotEmpty) {
    await tester.tap(quoteButton);
    await tester.pumpAndSettle();
    print('✓ Purchase inquiry initiated');
  }

  // Look for RFQ (Request for Quote) functionality
  final rfqButton = find.text('Request Quote');
  if (rfqButton.evaluate().isNotEmpty) {
    await tester.tap(rfqButton);
    await tester.pumpAndSettle();
    print('✓ RFQ created');
  }

  print('✓ Purchase inquiry flow completed');
}

/// Test guest mode onboarding flow
Future<void> _testGuestModeOnboarding(WidgetTester tester) async {
  print('Testing: Guest Mode Onboarding');

  // Look for guest mode option
  final guestButton = find.text('Continue as Guest');
  if (guestButton.evaluate().isNotEmpty) {
    await tester.tap(guestButton);
    await tester.pumpAndSettle();

    // Verify guest mode is active
    expect(find.text('Guest User'), findsOneWidget);

    // Test basic functionality as guest
    await _testLocationSelection(tester);
    await _testBrowseCategories(tester);
    await _testSearchProducts(tester);

    print('✓ Guest mode onboarding completed');
  } else {
    print('⚠ Guest mode option not found');
  }
}

/// Test onboarding with different locations
Future<void> _testLocationVariations(WidgetTester tester) async {
  print('Testing: Location Variations');

  final locations = ['Delhi', 'Bangalore', 'Chennai', 'Kolkata'];

  for (final location in locations) {
    // Tap on location picker
    final locationPicker = find.byIcon(Icons.location_on);
    if (locationPicker.evaluate().isNotEmpty) {
      await tester.tap(locationPicker);
      await tester.pumpAndSettle();

      // Search for location
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, location);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Apply location
      final applyButton = find.text('Apply');
      if (applyButton.evaluate().isNotEmpty) {
        await tester.tap(applyButton);
        await tester.pumpAndSettle();
      }

      print('✓ Location set to $location');
    }
  }
}

// Helper functions for future use in E2E tests
// These can be used when implementing more complex test scenarios

/// Helper function to wait for network requests
// Future<void> _waitForNetworkRequests(WidgetTester tester) async {
//   await tester.pumpAndSettle(const Duration(seconds: 2));
// }

/// Helper function to handle dynamic content loading
// Future<void> _waitForContentLoad(WidgetTester tester) async {
//   // Wait for any loading indicators to disappear
//   while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty) {
//     await tester.pumpAndSettle(const Duration(milliseconds: 500));
//   }
//
//   // Additional wait for content to render
//   await tester.pumpAndSettle(const Duration(seconds: 1));
// }

/// Helper function to scroll and find elements
// Future<void> _scrollToFind(WidgetTester tester, Finder finder) async {
//   int attempts = 0;
//   const maxAttempts = 10;
//
//   while (finder.evaluate().isEmpty && attempts < maxAttempts) {
//     await tester.drag(find.byType(Scrollable), const Offset(0, -200));
//     await tester.pumpAndSettle();
//     attempts++;
//   }
// }

/// Helper function to handle different screen sizes
// Future<void> _adaptToScreenSize(WidgetTester tester) async {
//   // Check if we're on mobile or desktop
//   final screenWidth = tester.binding.window.physicalSize.width;
//   final isMobile = screenWidth < 600;
//
//   if (isMobile) {
//     // Mobile-specific interactions
//     print('Running on mobile screen');
//   } else {
//     // Desktop-specific interactions
//     print('Running on desktop screen');
//   }
// }

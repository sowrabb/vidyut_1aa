# Vidyut E2E Tests - New User Onboarding Journey

This directory contains comprehensive End-to-End (E2E) tests for the Vidyut app, specifically focusing on the new user onboarding journey.

## Overview

The E2E tests cover the complete user journey from app launch to making a purchase inquiry:

```
App Launch → Splash Screen → Home Page → Location Selection → Browse Categories → Search Products → View Product Details → Contact Seller → Create Account → Complete Profile → Save Products → Make Purchase Inquiry
```

## Test Files

### 1. `new_user_onboarding_e2e_test.dart`
Main E2E test file containing:
- Complete new user onboarding flow
- Guest user onboarding flow
- Onboarding with different locations
- Comprehensive test scenarios for each step

### 2. `test_data_setup.dart`
Test data and utilities for E2E tests:
- Test user data
- Test product data
- Test location data
- Test search queries
- Performance metrics
- Error scenarios

### 3. `run_e2e_tests.sh`
Test runner script that:
- Sets up the test environment
- Builds the app for testing
- Runs all E2E tests
- Generates test reports
- Handles different test scenarios

## Prerequisites

1. **Flutter SDK**: Ensure Flutter is installed and in PATH
2. **Device/Emulator**: Have a device connected or emulator running
3. **Dependencies**: Run `flutter pub get` to install dependencies
4. **Integration Test Package**: Already included in `pubspec.yaml`

## Running the Tests

### Quick Start
```bash
# Make the script executable (if not already)
chmod +x test/integration/run_e2e_tests.sh

# Run all E2E tests
./test/integration/run_e2e_tests.sh
```

### Manual Execution
```bash
# Run specific test
flutter test integration_test/new_user_onboarding_e2e_test.dart

# Run with specific device
flutter test integration_test/new_user_onboarding_e2e_test.dart --device-id="your_device_id"

# Run specific test case
flutter test integration_test/new_user_onboarding_e2e_test.dart --name="Complete new user onboarding flow"
```

### Verbose Output
```bash
# Run with verbose output
./test/integration/run_e2e_tests.sh --verbose

# Run specific test with verbose output
flutter test integration_test/new_user_onboarding_e2e_test.dart --verbose
```

## Test Scenarios

### 1. Complete New User Onboarding Flow
Tests the entire journey from app launch to purchase inquiry:
- ✅ App launch and splash screen
- ✅ Home page navigation
- ✅ Location selection
- ✅ Category browsing
- ✅ Product search
- ✅ Product detail viewing
- ✅ Seller contact
- ✅ Account creation
- ✅ Profile completion
- ✅ Product saving
- ✅ Purchase inquiry

### 2. Guest User Onboarding Flow
Tests the journey for users who choose to continue as guests:
- ✅ Guest mode activation
- ✅ Basic functionality access
- ✅ Limited feature availability
- ✅ Upgrade prompts

### 3. Location Variations
Tests onboarding with different location selections:
- ✅ Multiple city selections
- ✅ State-based filtering
- ✅ Location persistence
- ✅ Location-based product recommendations

## Test Data

The tests use comprehensive test data including:

### User Data
- Test email: `testuser@vidyut.com`
- Test password: `TestPassword123!`
- Test phone: `+919876543210`
- Test company: `Test Electrical Company`

### Location Data
- Mumbai, Maharashtra
- Delhi, Delhi
- Bangalore, Karnataka
- Chennai, Tamil Nadu
- Hyderabad, Telangana
- Kolkata, West Bengal

### Product Data
- Categories: Wires & Cables, Circuit Breakers, Lights, Motors, Tools
- Materials: Copper, Aluminium, PVC, XLPE, Steel
- Search queries: copper wire, circuit breaker, LED lights, etc.

## Test Reports

After running tests, reports are generated in `test_reports/` directory:
- Timestamped report folders
- Markdown format reports
- Performance metrics
- Test coverage information
- Recommendations

## Performance Benchmarks

The tests include performance benchmarks:
- App launch time: < 3 seconds
- Home page load time: < 2 seconds
- Search response time: < 1 second
- Product detail load time: < 1.5 seconds
- Total onboarding time: < 5 minutes

## Error Handling

Tests include comprehensive error handling:
- Network connectivity issues
- Invalid input validation
- Permission denials
- Server errors
- Timeout scenarios

## Accessibility Testing

Tests verify accessibility features:
- Screen reader compatibility
- High contrast mode
- Font scaling
- Color blind support
- Reduced motion

## Cross-Platform Testing

Tests are designed to work across:
- Android devices
- iOS devices
- Web browsers
- Desktop applications

## Continuous Integration

For CI/CD integration:

```yaml
# Example GitHub Actions workflow
- name: Run E2E Tests
  run: |
    flutter test integration_test/new_user_onboarding_e2e_test.dart
    ./test/integration/run_e2e_tests.sh
```

## Troubleshooting

### Common Issues

1. **No devices found**
   - Ensure device is connected via USB
   - Check `flutter devices` command
   - Start an emulator if needed

2. **Test failures**
   - Check device logs: `flutter logs`
   - Verify app permissions
   - Ensure stable network connection

3. **Build failures**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Check for dependency conflicts

### Debug Mode
```bash
# Run tests in debug mode
flutter test integration_test/new_user_onboarding_e2e_test.dart --debug

# Enable verbose logging
flutter test integration_test/new_user_onboarding_e2e_test.dart --verbose
```

## Best Practices

1. **Test Isolation**: Each test is independent and can run in any order
2. **Data Cleanup**: Tests clean up after themselves
3. **Realistic Data**: Uses realistic test data that mirrors production
4. **Performance Monitoring**: Includes performance benchmarks
5. **Error Scenarios**: Tests both success and failure paths
6. **Accessibility**: Verifies accessibility compliance
7. **Cross-Platform**: Tests work across different platforms

## Contributing

When adding new E2E tests:

1. Follow the existing test structure
2. Add comprehensive test data
3. Include error scenarios
4. Update documentation
5. Add performance benchmarks
6. Test across different devices

## Support

For issues with E2E tests:
1. Check the troubleshooting section
2. Review test logs
3. Verify device compatibility
4. Check Flutter and dependency versions

---

*Last updated: $(date)*
*Flutter version: $(flutter --version | head -n 1)*


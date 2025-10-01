# Example Code - Archived

This directory contains example and test helper code that has been moved out of the main `lib/` directory.

## Files

### Examples
- `firebase_integration_examples.dart` - Widget examples showing Firebase integration patterns
- `cloud_functions_usage_example.dart` - Examples of Cloud Functions usage

### Test Helpers (Deprecated)
- `test_providers_v2.dart` - Old test provider setup (use `test/admin/admin_provider_overrides_example.dart` instead)
- `test_unified_providers.dart` - Legacy unified provider tests
- `verify_providers.dart` - Provider verification script

## Usage

These files are kept for reference but are **not** included in production builds.

For current testing patterns, see:
- `test/admin/admin_provider_overrides_example.dart` - Modern provider override examples
- `MANUAL_TESTING_GUIDE.md` - Manual testing procedures

## Migration Notes

These files were moved in Phase 4 to clean up the codebase and reduce analyzer errors.
They used legacy provider patterns and are superseded by the modern architecture.





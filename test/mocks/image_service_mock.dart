import 'package:flutter/services.dart';

/// Mock image service for tests to avoid HTTP 400 errors from picsum.photos
class MockImageService {
  static const String _mockImageData = '''
    data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAwIiBoZWlnaHQ9IjMwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KICA8cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZjBmMGYwIi8+CiAgPHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxOCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPk1vY2sgSW1hZ2U8L3RleHQ+Cjwvc3ZnPg==
  ''';

  /// Returns a mock image URL that won't cause HTTP errors in tests
  static String getMockImageUrl(String seed) {
    // Return a data URI instead of external URL to avoid HTTP requests
    return _mockImageData;
  }

  /// Returns a mock image asset for testing
  static String getMockImageAsset() {
    return 'assets/images/placeholder.png';
  }

  /// Creates a mock image widget for tests
  static Widget createMockImageWidget({
    double? width,
    double? height,
    String? placeholder,
  }) {
    return Container(
      width: width ?? 400,
      height: height ?? 300,
      color: const Color(0xFFF0F0F0),
      child: Center(
        child: Text(
          placeholder ?? 'Mock Image',
          style: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

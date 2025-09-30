// This file has been replaced by lightweight_image_widget.dart
// Please use LightweightImageWidget instead of OptimizedImage

import 'lightweight_image_widget.dart';

// Alias for backward compatibility
class OptimizedImageWidget extends LightweightImageWidget {
  const OptimizedImageWidget({
    super.key,
    required super.imagePath,
    super.width,
    super.height,
    super.fit,
    super.placeholder,
    super.errorWidget,
    super.borderRadius,
  });
}

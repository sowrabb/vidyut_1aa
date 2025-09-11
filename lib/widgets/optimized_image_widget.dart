import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:typed_data';
import '../services/image_service.dart';

class OptimizedImageWidget extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableLazyLoading;
  final bool enableProgressiveLoading;
  final Duration fadeInDuration;
  final Color? placeholderColor;
  final Color? errorColor;

  const OptimizedImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableLazyLoading = true,
    this.enableProgressiveLoading = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.placeholderColor,
    this.errorColor,
  });

  @override
  State<OptimizedImageWidget> createState() => _OptimizedImageWidgetState();
}

class _OptimizedImageWidgetState extends State<OptimizedImageWidget>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _hasError = false;
  Uint8List? _imageBytes;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (!widget.enableLazyLoading) {
      _loadImage();
    }
  }

  @override
  void didUpdateWidget(OptimizedImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      if (widget.imagePath.startsWith('assets/')) {
        // For assets, no loading needed
        setState(() {
          _isLoading = false;
        });
      } else if (widget.imagePath.startsWith('http')) {
        // For network images, no loading needed
        setState(() {
          _isLoading = false;
        });
      } else {
        // For local files, load bytes
        final bytes = await ImageService.getImageBytes(widget.imagePath);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = bytes == null;
            _imageBytes = bytes;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading && widget.enableLazyLoading) {
      return _buildPlaceholder();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    Widget imageWidget;

    if (widget.imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        widget.imagePath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else if (widget.imagePath.startsWith('http')) {
      imageWidget = _buildNetworkImage();
    } else if (_imageBytes != null) {
      imageWidget = _buildMemoryImage();
    } else {
      return _buildErrorWidget();
    }

    // Apply border radius if specified
    if (widget.borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: imageWidget,
      );
    }

    // Apply fade-in animation if enabled
    if (widget.enableProgressiveLoading && !_isLoading) {
      imageWidget = AnimatedOpacity(
        opacity: _isLoading ? 0.0 : 1.0,
        duration: widget.fadeInDuration,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildNetworkImage() {
    return ExtendedImage.network(
      widget.imagePath,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cache: true,
      enableLoadState: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return _buildPlaceholder();
          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            );
          case LoadState.failed:
            return _buildErrorWidget();
        }
      },
      clearMemoryCacheWhenDispose: true,
      clearMemoryCacheIfFailed: true,
    );
  }

  Widget _buildMemoryImage() {
    return ExtendedImage.memory(
      _imageBytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      enableLoadState: true,
      loadStateChanged: (state) {
        switch (state.extendedImageLoadState) {
          case LoadState.loading:
            return _buildPlaceholder();
          case LoadState.completed:
            return ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
            );
          case LoadState.failed:
            return _buildErrorWidget();
        }
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.placeholderColor ?? Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.errorColor ?? Colors.grey[200],
        borderRadius: widget.borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 48,
        ),
      ),
    );
  }
}

/// Optimized image widget specifically for hero sections
class HeroImageWidget extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const HeroImageWidget({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    if (imagePath == null || imagePath!.isEmpty) {
      return _buildPlaceholder();
    }

    return OptimizedImageWidget(
      imagePath: imagePath!,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      enableLazyLoading: false,
      enableProgressiveLoading: true,
      placeholder: _buildPlaceholder(),
      errorWidget: _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 48,
        ),
      ),
    );
  }
}

/// Optimized image widget for product galleries
class ProductImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = OptimizedImageWidget(
      imagePath: imageUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      enableLazyLoading: true,
      enableProgressiveLoading: true,
      placeholder: _buildPlaceholder(),
      errorWidget: _buildErrorWidget(),
    );

    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}

/// Optimized image widget for category images
class CategoryImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CategoryImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImageWidget(
      imagePath: imagePath,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      enableLazyLoading: true,
      enableProgressiveLoading: true,
      placeholder: _buildPlaceholder(),
      errorWidget: _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.category,
          color: Colors.grey,
          size: 32,
        ),
      ),
    );
  }
}

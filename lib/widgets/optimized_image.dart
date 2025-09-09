import 'package:flutter/material.dart';
import 'dart:io';
import '../services/image_compression_service.dart';

class OptimizedImage extends StatefulWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableCompression;

  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableCompression = true,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  File? _compressedImage;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(OptimizedImage oldWidget) {
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
        // For assets, no compression needed
        setState(() {
          _isLoading = false;
        });
      } else if (widget.imagePath.startsWith('http')) {
        // For network images, no compression needed
        setState(() {
          _isLoading = false;
        });
      } else {
        // For local files, apply compression if enabled
        final imageFile = File(widget.imagePath);
        if (await imageFile.exists()) {
          if (widget.enableCompression) {
            _compressedImage = await ImageCompressionService.compressImage(imageFile);
          } else {
            _compressedImage = imageFile;
          }
        }
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = _compressedImage == null;
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
    if (_isLoading) {
      return widget.placeholder ?? 
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
    }

    if (_hasError) {
      return widget.errorWidget ?? 
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 48,
          ),
        );
    }

    Widget imageWidget;

    if (widget.imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        widget.imagePath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? 
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            );
        },
      );
    } else if (widget.imagePath.startsWith('http')) {
      imageWidget = Image.network(
        widget.imagePath,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return widget.placeholder ?? 
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
        },
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? 
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            );
        },
      );
    } else if (_compressedImage != null) {
      imageWidget = Image.file(
        _compressedImage!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? 
            Container(
              width: widget.width,
              height: widget.height,
              color: Colors.grey[200],
              child: const Icon(
                Icons.broken_image,
                color: Colors.grey,
                size: 48,
              ),
            );
        },
      );
    } else {
      return widget.errorWidget ?? 
        Container(
          width: widget.width,
          height: widget.height,
          color: Colors.grey[200],
          child: const Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 48,
          ),
        );
    }

    return imageWidget;
  }

  @override
  void dispose() {
    // Clean up compressed image if it's temporary
    if (_compressedImage != null && _compressedImage!.path.contains('compressed_')) {
      _compressedImage!.delete().catchError((e) {
        // Ignore deletion errors
        return _compressedImage!;
      });
    }
    super.dispose();
  }
}

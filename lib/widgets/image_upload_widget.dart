import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/image_service.dart';
import 'optimized_image_widget.dart';

class ImageUploadWidget extends StatefulWidget {
  final String? currentImagePath;
  final Function(ImageUploadResult) onImageSelected;
  final Function(String)? onImageRemoved;
  final double? width;
  final double? height;
  final String? label;
  final String? hint;
  final bool showPreview;
  final bool allowMultipleSources;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;

  const ImageUploadWidget({
    super.key,
    this.currentImagePath,
    required this.onImageSelected,
    this.onImageRemoved,
    this.width,
    this.height,
    this.label,
    this.hint,
    this.showPreview = true,
    this.allowMultipleSources = true,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  bool _isUploading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Image preview
        if (widget.showPreview && widget.currentImagePath != null) ...[
          Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 200,
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              border: Border.all(
                color: widget.borderColor ?? Colors.grey.shade300,
                width: widget.borderWidth,
              ),
            ),
            child: ClipRRect(
              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
              child: OptimizedImageWidget(
                imagePath: widget.currentImagePath!,
                width: widget.width ?? double.infinity,
                height: widget.height ?? 200,
                fit: BoxFit.cover,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                enableLazyLoading: false,
                enableProgressiveLoading: true,
                placeholder: _buildPlaceholder(),
                errorWidget: _buildErrorWidget(),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Upload buttons
        if (widget.allowMultipleSources) ...[
          Row(
            children: [
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: _uploadFromCamera,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: _uploadFromGallery,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.folder_open,
                  label: 'Files',
                  onPressed: _uploadFromFiles,
                ),
              ),
            ],
          ),
        ] else ...[
          SizedBox(
            width: double.infinity,
            child: _buildUploadButton(
              icon: Icons.add_photo_alternate,
              label: 'Select Image',
              onPressed: _uploadFromGallery,
            ),
          ),
        ],
        
        // Remove button
        if (widget.currentImagePath != null && widget.onImageRemoved != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _removeImage,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Remove Image'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
        
        // Error message
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
        
        // Hint text
        if (widget.hint != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.hint!,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: _isUploading ? null : onPressed,
      icon: _isUploading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        side: BorderSide(
          color: widget.borderColor ?? Colors.grey.shade300,
          width: widget.borderWidth,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[100],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: widget.borderColor ?? Colors.grey.shade300,
          width: widget.borderWidth,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              color: Colors.grey,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'No image selected',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 200,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey[100],
        borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: widget.borderColor ?? Colors.grey.shade300,
          width: widget.borderWidth,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: Colors.red,
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'Error loading image',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadFromCamera() async {
    if (kIsWeb) {
      _showUnsupportedMessage('Camera access is not supported on web');
      return;
    }
    
    await _uploadImage(() => ImageService.uploadFromCamera());
  }

  Future<void> _uploadFromGallery() async {
    await _uploadImage(() => ImageService.uploadFromGallery());
  }

  Future<void> _uploadFromFiles() async {
    await _uploadImage(() => ImageService.uploadFromFiles());
  }

  Future<void> _uploadImage(Future<ImageUploadResult?> Function() uploadFunction) async {
    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final result = await uploadFunction();
      
      if (result != null) {
        widget.onImageSelected(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Image uploaded successfully! '
                'Size reduced by ${result.compressionPercentage} '
                '(${result.formattedOriginalSize} → ${result.formattedCompressedSize})',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to upload image. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error uploading image: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _removeImage() {
    if (widget.currentImagePath != null && widget.onImageRemoved != null) {
      widget.onImageRemoved!(widget.currentImagePath!);
    }
  }

  void _showUnsupportedMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}

/// Simple image upload widget for quick use
class SimpleImageUpload extends StatelessWidget {
  final String? imagePath;
  final Function(String) onImageSelected;
  final Function()? onImageRemoved;
  final double? width;
  final double? height;
  final String? label;

  const SimpleImageUpload({
    super.key,
    this.imagePath,
    required this.onImageSelected,
    this.onImageRemoved,
    this.width,
    this.height,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ImageUploadWidget(
      currentImagePath: imagePath,
      onImageSelected: (result) => onImageSelected(result.path),
      onImageRemoved: onImageRemoved != null ? (_) => onImageRemoved!() : null,
      width: width,
      height: height,
      label: label,
      showPreview: true,
      allowMultipleSources: true,
    );
  }
}

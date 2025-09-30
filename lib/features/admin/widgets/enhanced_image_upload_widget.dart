import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

/// Enhanced image upload widget with preview and validation
class EnhancedImageUploadWidget extends StatefulWidget {
  final String? imageUrl;
  final Function(String)? onImageSelected;
  final Function(String)? onImageUploaded;
  final bool isUploading;
  final String? label;
  final double? width;
  final double? height;
  final bool showPreview;

  const EnhancedImageUploadWidget({
    super.key,
    this.imageUrl,
    this.onImageSelected,
    this.onImageUploaded,
    this.isUploading = false,
    this.label,
    this.width,
    this.height,
    this.showPreview = true,
  });

  @override
  State<EnhancedImageUploadWidget> createState() =>
      _EnhancedImageUploadWidgetState();
}

class _EnhancedImageUploadWidgetState extends State<EnhancedImageUploadWidget> {
  String? _selectedImagePath;
  String? _previewUrl;

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(EnhancedImageUploadWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      _previewUrl = widget.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Image preview or upload area
        Container(
          width: widget.width ?? double.infinity,
          height: widget.height ?? 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: _buildImageContent(),
        ),

        const SizedBox(height: 8),

        // Upload button
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: widget.isUploading ? null : _selectImage,
              icon: const Icon(Icons.upload),
              label: const Text('Select Image'),
            ),
            const SizedBox(width: 8),
            if (_previewUrl != null || _selectedImagePath != null)
              ElevatedButton.icon(
                onPressed: widget.isUploading ? null : _clearImage,
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),

        // Upload progress
        if (widget.isUploading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
          const SizedBox(height: 4),
          const Text(
            'Uploading image...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],

        // Image info
        if (_previewUrl != null || _selectedImagePath != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _previewUrl != null
                        ? 'Image uploaded successfully'
                        : 'Image selected: ${_getFileName(_selectedImagePath!)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageContent() {
    if (widget.isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Uploading...'),
          ],
        ),
      );
    }

    if (_previewUrl != null && widget.showPreview) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _previewUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
      );
    }

    if (_selectedImagePath != null && widget.showPreview) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(_selectedImagePath!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
      );
    }

    return _buildUploadPrompt();
  }

  Widget _buildUploadPrompt() {
    return InkWell(
      onTap: _selectImage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey[400]!,
            style: BorderStyle.solid,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Click to select image',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Supports: JPG, PNG, WebP\nMax size: 10MB',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.red[50],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 48,
            color: Colors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final filePath = file.path;

        if (filePath != null) {
          // Validate file size (10MB limit)
          final fileSize = await File(filePath).length();
          if (fileSize > 10 * 1024 * 1024) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Image size must be less than 10MB')),
              );
            }
            return;
          }

          // Validate file type
          final extension = filePath.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                        Text('Only JPG, PNG, and WebP images are supported')),
              );
            }
            return;
          }

          setState(() {
            _selectedImagePath = filePath;
            _previewUrl = null;
          });

          // Notify parent widget
          widget.onImageSelected?.call(filePath);

          // Auto-upload if callback is provided
          if (widget.onImageUploaded != null) {
            // Simulate upload process
            await Future.delayed(const Duration(seconds: 1));
            final uploadedUrl =
                'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/400/300';
            setState(() {
              _previewUrl = uploadedUrl;
              _selectedImagePath = null;
            });
            widget.onImageUploaded!(uploadedUrl);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select image: $e')),
        );
      }
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImagePath = null;
      _previewUrl = null;
    });
  }

  String _getFileName(String path) {
    return path.split('/').last;
  }
}

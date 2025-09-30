import 'package:flutter/material.dart';

/// A simple image upload widget for admin pages
class ImageUploadWidget extends StatefulWidget {
  final String? initialImageUrl;
  final Function(String?) onImageChanged;
  final Function(String)? onImageUploaded;
  final bool? isUploading;
  final String? label;

  const ImageUploadWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageChanged,
    this.onImageUploaded,
    this.isUploading,
    this.label,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = widget.initialImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
        ],
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _imageUrl != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUrl!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Image',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _selectImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Choose Image'),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  void _selectImage() {
    // In a real implementation, this would open file picker
    // For testing purposes, we'll simulate an image URL
    setState(() {
      _imageUrl = 'https://via.placeholder.com/400x200?text=Sample+Image';
    });
    widget.onImageChanged(_imageUrl);
    if (widget.onImageUploaded != null && _imageUrl != null) {
      widget.onImageUploaded!(_imageUrl!);
    }
  }

  void _removeImage() {
    setState(() {
      _imageUrl = null;
    });
    widget.onImageChanged(null);
  }
}

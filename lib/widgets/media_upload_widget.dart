import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../services/image_management_service.dart';
import '../services/document_management_service.dart';
import 'image_gallery_widget.dart';

/// Media upload widget for images and documents
class MediaUploadWidget extends ConsumerStatefulWidget {
  final List<String> currentImages;
  final List<String> currentDocuments;
  final ValueChanged<List<String>>? onImagesChanged;
  final ValueChanged<List<String>>? onDocumentsChanged;
  final int maxImages;
  final int maxDocuments;
  final bool showDocuments;
  final String? folder;
  final ImageManagementService? imageService;
  final DocumentManagementService? documentService;
  final bool showCamera;
  final String galleryButtonLabel;

  const MediaUploadWidget({
    super.key,
    this.currentImages = const [],
    this.currentDocuments = const [],
    this.onImagesChanged,
    this.onDocumentsChanged,
    this.maxImages = 5,
    this.maxDocuments = 3,
    this.showDocuments = true,
    this.folder,
    this.imageService,
    this.documentService,
    this.showCamera = true,
    this.galleryButtonLabel = 'Gallery',
  });

  @override
  ConsumerState<MediaUploadWidget> createState() => _MediaUploadWidgetState();
}

class _MediaUploadWidgetState extends ConsumerState<MediaUploadWidget> {
  late final ImageManagementService _imageService;
  late final DocumentManagementService _documentService;

  // Remote image URLs persisted for the product
  List<String> _images = [];
  // Preview entries shown in the grid. May contain remote URLs or memory placeholders
  List<_PreviewEntry> _previews = [];
  // Track upload errors per preview index
  final Set<int> _errorIndices = <int>{};
  List<String> _documents = [];

  @override
  void initState() {
    super.initState();
    _imageService = widget.imageService ?? ImageManagementService();
    _documentService = widget.documentService ?? DocumentManagementService();
    _images = List.from(widget.currentImages);
    // Initialize previews from existing remote URLs
    _previews = _images.map((u) => _PreviewEntry.remote(u)).toList();
    _documents = List.from(widget.currentDocuments);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Images Section
        _buildImagesSection(),
        const SizedBox(height: 24),

        // Documents Section
        if (widget.showDocuments) ...[
          _buildDocumentsSection(),
          const SizedBox(height: 24),
        ],

        // Upload Progress
        if (_imageService.isUploading || _documentService.isUploading)
          _buildUploadProgress(),
      ],
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.image, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Images (${_images.length}/${widget.maxImages})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Image Grid - show local previews immediately
        if (_previews.isNotEmpty) ...[
          _buildImageGrid(),
          const SizedBox(height: 12),
        ],

        // Upload Buttons
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (_images.length < widget.maxImages) ...[
              ElevatedButton.icon(
                onPressed: _pickImagesFromGallery,
                icon: const Icon(Icons.photo_library),
                label: Text(widget.galleryButtonLabel),
              ),
              if (widget.showCamera)
                ElevatedButton.icon(
                  onPressed: _pickImageFromCamera,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
            ],
            if (_images.isNotEmpty)
              OutlinedButton.icon(
                onPressed: _clearAllImages,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              'Documents (${_documents.length}/${widget.maxDocuments})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Document List
        if (_documents.isNotEmpty) ...[
          _buildDocumentList(),
          const SizedBox(height: 12),
        ],

        // Upload Button
        if (_documents.length < widget.maxDocuments)
          ElevatedButton.icon(
            onPressed: _pickDocuments,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Documents'),
          ),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _previews.length,
      itemBuilder: (context, index) {
        final _PreviewEntry entry = _previews[index];
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildPreviewTile(entry, index),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            if (entry.isUploading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            if (_errorIndices.contains(index))
              Positioned(
                bottom: 4,
                left: 4,
                child: Tooltip(
                  message: 'Upload failed. Tap to retry.',
                  child: InkWell(
                    onTap: () => _retryUpload(index),
                    child: const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.refresh, size: 16, color: Colors.red),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDocumentList() {
    return Column(
      children: _documents.asMap().entries.map((entry) {
        final int index = entry.key;
        final String documentUrl = entry.value;
        final String fileName = documentUrl.split('/').last;

        return Card(
          child: ListTile(
            leading: const Icon(Icons.description, color: Colors.orange),
            title: Text(fileName),
            subtitle: const Text('PDF Document'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeDocument(index),
            ),
            onTap: () => _viewDocument(documentUrl),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUploadProgress() {
    final double progress = _imageService.isUploading
        ? _imageService.uploadProgress
        : _documentService.uploadProgress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.upload),
                const SizedBox(width: 8),
                Text(
                  _imageService.isUploading
                      ? 'Uploading images...'
                      : 'Uploading documents...',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 4),
            Text('${(progress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewTile(_PreviewEntry entry, int index) {
    if (entry.bytes != null) {
      return Image.memory(
        entry.bytes!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => Container(
          color: Colors.grey[300],
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image),
        ),
      );
    }
    // Fallback to network preview
    return ImagePreviewWidget(
      imageUrl: entry.url ?? '',
      heroTag: 'upload_$index',
      fit: BoxFit.cover,
    );
  }

  // Image methods
  Future<void> _pickImagesFromGallery() async {
    final int remaining = widget.maxImages - _images.length;
    if (remaining <= 0) return;

    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: remaining > 1,
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final files = result.files.take(remaining);
      for (final PlatformFile f in files) {
        if (f.bytes == null) continue;
        final Uint8List bytes = f.bytes!;
        final previewIndex = _previews.length;
        setState(() {
          _previews.add(_PreviewEntry.local(bytes));
        });
        await _uploadSingleImage(bytes, previewIndex);
      }
      return;
    }

    final List<XFile> images = await _imageService.pickMultipleImages(
      maxImages: remaining,
    );

    if (images.isEmpty) return;

    for (final img in images) {
      final bytes = await img.readAsBytes();
      final previewIndex = _previews.length;
      setState(() {
        _previews.add(_PreviewEntry.local(bytes));
      });
      await _uploadSingleImage(bytes, previewIndex);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? image = await _imageService.pickImageFromCamera();

    if (image == null) return;

    final bytes = await image.readAsBytes();
    final previewIndex = _previews.length;
    setState(() {
      _previews.add(_PreviewEntry.local(bytes));
    });
    _uploadSingleImage(bytes, previewIndex);
  }

  void _removeImage(int index) {
    setState(() {
      // If this preview corresponds to a remote URL, also remove from _images
      final removed = _previews.removeAt(index);
      if (removed.url != null) {
        _images.remove(removed.url);
      }
      _errorIndices.remove(index);
    });
    widget.onImagesChanged?.call(_images);
  }

  void _clearAllImages() {
    setState(() {
      _images.clear();
      _previews.clear();
      _errorIndices.clear();
    });
    widget.onImagesChanged?.call(_images);
  }

  // Document methods
  Future<void> _pickDocuments() async {
    final List<PlatformFile> documents =
        await _documentService.pickMultipleDocuments();

    if (documents.isNotEmpty) {
      final List<String> uploadedUrls =
          await _documentService.uploadMultipleDocuments(
        documents,
        folder: widget.folder ?? 'documents',
      );

      setState(() {
        _documents.addAll(uploadedUrls);
      });

      widget.onDocumentsChanged?.call(_documents);
    }
  }

  void _removeDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
    widget.onDocumentsChanged?.call(_documents);
  }

  void _viewDocument(String documentUrl) {
    // Implement document viewer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document viewer coming soon')),
    );
  }

  Future<void> _uploadSingleImage(Uint8List bytes, int previewIndex) async {
    // Mark as uploading
    setState(() {
      _previews[previewIndex] =
          _previews[previewIndex].copyWith(isUploading: true);
      _errorIndices.remove(previewIndex);
    });

    try {
      final String? uploadedUrl = await _imageService.uploadImage(
        bytes,
        folder: widget.folder ?? 'products',
      );

      if (!mounted) return;

      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        final String cacheBusted =
            '$uploadedUrl?v=${DateTime.now().millisecondsSinceEpoch}';
        setState(() {
          // Replace preview with remote URL
          _previews[previewIndex] = _PreviewEntry.remote(cacheBusted);
          _images.add(cacheBusted);
        });
        widget.onImagesChanged?.call(_images);
      } else {
        setState(() {
          _previews[previewIndex] =
              _previews[previewIndex].copyWith(isUploading: false);
          _errorIndices.add(previewIndex);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _previews[previewIndex] =
            _previews[previewIndex].copyWith(isUploading: false);
        _errorIndices.add(previewIndex);
      });
    }
  }

  Future<void> _retryUpload(int index) async {
    final entry = _previews[index];
    if (entry.bytes == null) return; // Only retry for local previews
    await _uploadSingleImage(entry.bytes!, index);
  }
}

class _PreviewEntry {
  final Uint8List? bytes; // when local
  final String? url; // when remote
  final bool isUploading;

  _PreviewEntry._({this.bytes, this.url, this.isUploading = false});

  factory _PreviewEntry.local(Uint8List bytes) =>
      _PreviewEntry._(bytes: bytes, url: null, isUploading: false);
  factory _PreviewEntry.remote(String url) =>
      _PreviewEntry._(bytes: null, url: url, isUploading: false);

  _PreviewEntry copyWith({Uint8List? bytes, String? url, bool? isUploading}) {
    return _PreviewEntry._(
      bytes: bytes ?? this.bytes,
      url: url ?? this.url,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

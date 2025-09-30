// Unified Media Uploader widget with drag-drop, progress, and previews
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../app/tokens.dart';
import '../models/media_models.dart';
import '../../../services/media_storage_service.dart';

/// Unified Media Uploader widget for Updates and Product Designs
class MediaUploaderWidget extends StatefulWidget {
  final List<MediaItem> initialMedia;
  final Function(List<MediaItem>) onMediaChanged;
  final String postId;
  final bool isEditMode;
  final int? maxImages;
  final int? maxPdfs;
  final int? maxTotalFiles;

  const MediaUploaderWidget({
    super.key,
    this.initialMedia = const [],
    required this.onMediaChanged,
    required this.postId,
    this.isEditMode = false,
    this.maxImages,
    this.maxPdfs,
    this.maxTotalFiles,
  });

  @override
  State<MediaUploaderWidget> createState() => _MediaUploaderWidgetState();
}

class _MediaUploaderWidgetState extends State<MediaUploaderWidget> {
  List<MediaItem> _mediaItems = [];
  final Map<String, MediaUploadProgress> _uploadProgress = {};
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _mediaItems = List.from(widget.initialMedia);
  }

  @override
  void didUpdateWidget(MediaUploaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMedia != widget.initialMedia) {
      _mediaItems = List.from(widget.initialMedia);
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [...MediaConstraints.allowedImageTypes, ...MediaConstraints.allowedPdfTypes],
      );

      if (result != null && result.files.isNotEmpty) {
        // Handle web and mobile differently
        if (kIsWeb) {
          // On web, we need to process the bytes directly
          await _processWebFiles(result.files);
        } else {
          // On mobile, we can use file paths
          await _processFiles(result.files.map((f) => File(f.path!)).toList());
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick files: $e');
    }
  }

  Future<void> _pickImagesFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        await _processFiles([File(image.path)]);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        await _processFiles(images.map((i) => File(i.path)).toList());
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  Future<void> _processWebFiles(List<PlatformFile> files) async {
    if (files.isEmpty) return;

    // Validate file limits
    final currentImages = _mediaItems.where((m) => m.type == MediaType.image).length;
    final currentPdfs = _mediaItems.where((m) => m.type == MediaType.pdf).length;
    final currentTotal = _mediaItems.length;

    final newImages = files.where((f) => MediaConstraints.isValidImageType(f.name)).length;
    final newPdfs = files.where((f) => MediaConstraints.isValidPdfType(f.name)).length;

    final maxImages = widget.maxImages ?? MediaConstraints.maxImagesPerPost;
    final maxPdfs = widget.maxPdfs ?? MediaConstraints.maxPdfsPerPost;
    final maxTotal = widget.maxTotalFiles ?? MediaConstraints.maxTotalFilesPerPost;

    if (currentImages + newImages > maxImages) {
      _showErrorSnackBar('Too many images. Maximum allowed: $maxImages');
      return;
    }
    if (currentPdfs + newPdfs > maxPdfs) {
      _showErrorSnackBar('Too many PDFs. Maximum allowed: $maxPdfs');
      return;
    }
    if (currentTotal + files.length > maxTotal) {
      _showErrorSnackBar('Too many files. Maximum allowed: $maxTotal');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      for (final platformFile in files) {
        if (platformFile.bytes != null) {
          await _processFileBytes(
            bytes: platformFile.bytes!,
            fileName: platformFile.name,
            sizeBytes: platformFile.size,
          );
        }
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _processFileBytes({
    required Uint8List bytes,
    required String fileName,
    required int sizeBytes,
  }) async {
    try {
      // Show initial progress
      setState(() {
        _uploadProgress[fileName] = MediaUploadProgress(
          fileId: fileName,
          fileName: fileName,
          progress: 0.0,
          isCompleted: false,
          isCancelled: false,
        );
      });

      // Determine media type from file name
      MediaType mediaType;
      if (MediaConstraints.isValidImageType(fileName)) {
        mediaType = MediaType.image;
      } else if (MediaConstraints.isValidPdfType(fileName)) {
        mediaType = MediaType.pdf;
      } else {
        throw Exception('Unsupported file type: $fileName');
      }

      // Show processing message
      setState(() {
        _uploadProgress[fileName] = MediaUploadProgress(
          fileId: fileName,
          fileName: fileName,
          progress: 0.1,
          isCompleted: false,
          isCancelled: false,
        );
      });

      print('Starting upload for $fileName (${bytes.length} bytes)');
      
      // Upload to Firebase Storage with timeout
      final mediaItem = await MediaStorageService.uploadMedia(
        fileBytes: bytes,
        fileName: fileName,
        mimeType: _getMimeType(fileName),
        mediaType: mediaType,
        entityType: 'posts',
        entityId: widget.postId,
        onProgress: (progress) {
          print('Progress callback: ${(progress * 100).toInt()}% for $fileName');
          setState(() {
            _uploadProgress[fileName] = MediaUploadProgress(
              fileId: fileName,
              fileName: fileName,
              progress: 0.1 + (progress * 0.8), // Scale progress to 10%-90%
              isCompleted: false,
              isCancelled: false,
            );
          });
        },
      ).timeout(
        Duration(minutes: 3),
        onTimeout: () {
          throw Exception('Upload timeout - please try again');
        },
      );
      
      print('Upload completed for $fileName');

      // Show completion
      setState(() {
        _uploadProgress[fileName] = MediaUploadProgress(
          fileId: fileName,
          fileName: fileName,
          progress: 1.0,
          isCompleted: true,
          isCancelled: false,
        );
      });

      // Add to media items after a brief delay to show completion
      await Future.delayed(Duration(milliseconds: 500));
      
      setState(() {
        _mediaItems.add(mediaItem);
        _uploadProgress.remove(fileName);
      });

      widget.onMediaChanged(_mediaItems);
    } catch (e) {
      setState(() {
        _uploadProgress.remove(fileName);
      });
      _showErrorSnackBar('Failed to upload $fileName: $e');
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _processFiles(List<File> files) async {
    if (files.isEmpty) return;

    // Validate file limits
    final currentImages = _mediaItems.where((m) => m.type == MediaType.image).length;
    final currentPdfs = _mediaItems.where((m) => m.type == MediaType.pdf).length;
    final currentTotal = _mediaItems.length;

    final newImages = files.where((f) => MediaConstraints.isValidImageType(f.path)).length;
    final newPdfs = files.where((f) => MediaConstraints.isValidPdfType(f.path)).length;

    final maxImages = widget.maxImages ?? MediaConstraints.maxImagesPerPost;
    final maxPdfs = widget.maxPdfs ?? MediaConstraints.maxPdfsPerPost;
    final maxTotal = widget.maxTotalFiles ?? MediaConstraints.maxTotalFilesPerPost;

    if (currentImages + newImages > maxImages) {
      _showErrorSnackBar('Too many images. Maximum allowed: $maxImages');
      return;
    }
    if (currentPdfs + newPdfs > maxPdfs) {
      _showErrorSnackBar('Too many PDFs. Maximum allowed: $maxPdfs');
      return;
    }
    if (currentTotal + files.length > maxTotal) {
      _showErrorSnackBar('Too many files. Maximum allowed: $maxTotal');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      for (final file in files) {
        final bytes = await file.readAsBytes();
        await _processFileBytes(
          bytes: bytes,
          fileName: file.path.split('/').last,
          sizeBytes: await file.length(),
        );
      }
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeMediaItem(MediaItem item) async {
    setState(() {
      _mediaItems.remove(item);
    });

    // Delete from Firebase Storage if it's a new upload
    try {
      await MediaStorageService.deleteFile(item.storagePath);
    } catch (e) {
      // Log error but don't show to user as it might be a legacy URL
      debugPrint('Failed to delete file: $e');
    }

    widget.onMediaChanged(_mediaItems);
  }

  void _setCoverImage(MediaItem item) {
    if (item.type != MediaType.image) return;

    setState(() {
      // Remove cover from all other images
      for (int i = 0; i < _mediaItems.length; i++) {
        if (_mediaItems[i].type == MediaType.image) {
          _mediaItems[i] = _mediaItems[i].copyWith(isCover: false);
        }
      }
      
      // Set this image as cover
      final index = _mediaItems.indexOf(item);
      if (index != -1) {
        _mediaItems[index] = _mediaItems[index].copyWith(isCover: true);
      }
    });

    widget.onMediaChanged(_mediaItems);
  }

  void _reorderMediaItems(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _mediaItems.removeAt(oldIndex);
      _mediaItems.insert(newIndex, item);
    });

    widget.onMediaChanged(_mediaItems);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Text(
              'Media Files',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Spacer(),
            Text(
              '${_mediaItems.length}/${widget.maxTotalFiles ?? MediaConstraints.maxTotalFilesPerPost} files',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Upload buttons
        if (!_isUploading) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _UploadButton(
                icon: Icons.upload_file,
                label: 'Upload Files',
                onPressed: _pickFiles,
                color: AppColors.primary,
              ),
              if (!kIsWeb) ...[
                _UploadButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onPressed: _pickImagesFromCamera,
                  color: Colors.green,
                ),
                _UploadButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onPressed: _pickImagesFromGallery,
                  color: Colors.blue,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Upload progress
        if (_isUploading && _uploadProgress.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Uploading files...',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ..._uploadProgress.values.map((progress) => _UploadProgressItem(progress: progress)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Media items
        if (_mediaItems.isNotEmpty) ...[
          Text(
            'Uploaded Files',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mediaItems.length,
            onReorder: _reorderMediaItems,
            itemBuilder: (context, index) {
              final item = _mediaItems[index];
              return _MediaItemWidget(
                key: ValueKey(item.id),
                mediaItem: item,
                onRemove: () => _removeMediaItem(item),
                onSetCover: item.type == MediaType.image ? () => _setCoverImage(item) : null,
              );
            },
          ),
        ],

        // Empty state
        if (_mediaItems.isEmpty && !_isUploading) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No files uploaded yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload images and PDFs to enhance your post',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Upload button widget
class _UploadButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _UploadButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

/// Upload progress item widget
class _UploadProgressItem extends StatelessWidget {
  final MediaUploadProgress progress;

  const _UploadProgressItem({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            progress.isCompleted
                ? Icons.check_circle
                : progress.error != null
                    ? Icons.error
                    : Icons.cloud_upload,
            size: 16,
            color: progress.isCompleted
                ? Colors.green
                : progress.error != null
                    ? Colors.red
                    : AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        progress.fileName,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      progress.isCompleted 
                          ? 'Complete'
                          : progress.error != null
                              ? 'Failed'
                              : '${(progress.progress * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: progress.isCompleted
                                ? Colors.green
                                : progress.error != null
                                    ? Colors.red
                                    : AppColors.textSecondary,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
                if (progress.error != null)
                  Text(
                    progress.error!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                          fontSize: 11,
                        ),
                  )
                else if (!progress.isCompleted) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress.progress,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getUploadStatusText(progress.progress),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUploadStatusText(double progress) {
    if (progress < 0.1) {
      return 'Preparing upload...';
    } else if (progress < 0.3) {
      return 'Uploading...';
    } else if (progress < 0.7) {
      return 'Processing...';
    } else if (progress < 0.9) {
      return 'Almost done...';
    } else {
      return 'Finalizing...';
    }
  }
}

/// Media item widget
class _MediaItemWidget extends StatelessWidget {
  final MediaItem mediaItem;
  final VoidCallback onRemove;
  final VoidCallback? onSetCover;

  const _MediaItemWidget({
    super.key,
    required this.mediaItem,
    required this.onRemove,
    this.onSetCover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Media preview
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
            child: mediaItem.type == MediaType.image
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      mediaItem.thumbnailUrl ?? mediaItem.downloadUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => const Icon(Icons.image),
                    ),
                  )
                : const Icon(Icons.picture_as_pdf, color: Colors.red),
          ),
          
          const SizedBox(width: 12),
          
          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mediaItem.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      mediaItem.type.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: mediaItem.type == MediaType.image ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatFileSize(mediaItem.sizeBytes),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (mediaItem.isCover)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'COVER',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              if (onSetCover != null && !mediaItem.isCover) ...[
                IconButton(
                  onPressed: onSetCover,
                  icon: const Icon(Icons.star_border, size: 20),
                  tooltip: 'Set as cover',
                ),
              ],
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Remove file',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = (bytes / 1024).floor();
    int suffixIndex = 0;
    
    while (i > 1024 && suffixIndex < suffixes.length - 1) {
      i = (i / 1024).floor();
      suffixIndex++;
    }
    
    return '$i ${suffixes[suffixIndex]}';
  }
}

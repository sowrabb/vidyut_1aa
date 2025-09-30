// Media models for unified file handling in Updates and Product Designs
import 'package:cloud_firestore/cloud_firestore.dart';
import 'state_info_models.dart';

/// Media type enum
enum MediaType {
  image,
  pdf,
}

/// Media item model for the new unified media system
class MediaItem {
  final String id;
  final MediaType type;
  final String storagePath; // Firebase Storage path
  final String downloadUrl; // Public download URL
  final String? thumbnailUrl; // For images: thumbnail URL, for PDFs: first page thumbnail
  final bool isCover; // Only one image can be cover per post
  final String name; // Original filename
  final int sizeBytes; // File size in bytes
  final DateTime uploadedAt;
  final String uploadedBy; // User ID who uploaded

  const MediaItem({
    required this.id,
    required this.type,
    required this.storagePath,
    required this.downloadUrl,
    this.thumbnailUrl,
    this.isCover = false,
    required this.name,
    required this.sizeBytes,
    required this.uploadedAt,
    required this.uploadedBy,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'thumbnailUrl': thumbnailUrl,
        'isCover': isCover,
        'name': name,
        'sizeBytes': sizeBytes,
        'uploadedAt': Timestamp.fromDate(uploadedAt),
        'uploadedBy': uploadedBy,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
        id: json['id'] as String,
        type: MediaType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MediaType.image,
        ),
        storagePath: json['storagePath'] as String,
        downloadUrl: json['downloadUrl'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        isCover: json['isCover'] as bool? ?? false,
        name: json['name'] as String,
        sizeBytes: json['sizeBytes'] as int,
        uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
        uploadedBy: json['uploadedBy'] as String,
      );

  MediaItem copyWith({
    String? id,
    MediaType? type,
    String? storagePath,
    String? downloadUrl,
    String? thumbnailUrl,
    bool? isCover,
    String? name,
    int? sizeBytes,
    DateTime? uploadedAt,
    String? uploadedBy,
  }) {
    return MediaItem(
      id: id ?? this.id,
      type: type ?? this.type,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isCover: isCover ?? this.isCover,
      name: name ?? this.name,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }
}

/// Media upload progress model
class MediaUploadProgress {
  final String fileId;
  final String fileName;
  final double progress; // 0.0 to 1.0
  final String? error;
  final bool isCompleted;
  final bool isCancelled;

  const MediaUploadProgress({
    required this.fileId,
    required this.fileName,
    required this.progress,
    this.error,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  MediaUploadProgress copyWith({
    String? fileId,
    String? fileName,
    double? progress,
    String? error,
    bool? isCompleted,
    bool? isCancelled,
  }) {
    return MediaUploadProgress(
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      isCompleted: isCompleted ?? this.isCompleted,
      isCancelled: isCancelled ?? this.isCancelled,
    );
  }
}

/// Media adapter for converting legacy URL fields to new media system
class MediaAdapter {
  /// Convert legacy Post model to new media array
  static List<MediaItem> fromLegacyPost({
    String? imageUrl,
    List<String> imageUrls = const [],
    List<String> pdfUrls = const [],
    String? postId,
    String? uploadedBy,
  }) {
    final List<MediaItem> mediaItems = [];
    final now = DateTime.now();

    // Convert single image URL
    if (imageUrl != null && imageUrl.isNotEmpty) {
      mediaItems.add(MediaItem(
        id: '${postId ?? 'legacy'}_image_${DateTime.now().millisecondsSinceEpoch}',
        type: MediaType.image,
        storagePath: imageUrl, // Legacy: URL is used as storage path
        downloadUrl: imageUrl,
        isCover: true, // First image is cover by default
        name: _extractFileNameFromUrl(imageUrl),
        sizeBytes: 0, // Unknown for legacy
        uploadedAt: now,
        uploadedBy: uploadedBy ?? 'system',
      ));
    }

    // Convert multiple image URLs
    for (int i = 0; i < imageUrls.length; i++) {
      final url = imageUrls[i];
      if (url.isNotEmpty) {
        mediaItems.add(MediaItem(
          id: '${postId ?? 'legacy'}_image_${i}_${DateTime.now().millisecondsSinceEpoch}',
          type: MediaType.image,
          storagePath: url,
          downloadUrl: url,
          isCover: mediaItems.isEmpty && i == 0, // First image is cover if no single image
          name: _extractFileNameFromUrl(url),
          sizeBytes: 0,
          uploadedAt: now,
          uploadedBy: uploadedBy ?? 'system',
        ));
      }
    }

    // Convert PDF URLs
    for (int i = 0; i < pdfUrls.length; i++) {
      final url = pdfUrls[i];
      if (url.isNotEmpty) {
        mediaItems.add(MediaItem(
          id: '${postId ?? 'legacy'}_pdf_${i}_${DateTime.now().millisecondsSinceEpoch}',
          type: MediaType.pdf,
          storagePath: url,
          downloadUrl: url,
          name: _extractFileNameFromUrl(url),
          sizeBytes: 0,
          uploadedAt: now,
          uploadedBy: uploadedBy ?? 'system',
        ));
      }
    }

    return mediaItems;
  }

  /// Convert legacy ProductDesign model to new media array
  static List<MediaItem> fromLegacyProductDesign({
    List<ProductDesignFile> files = const [],
    String? designId,
    String? uploadedBy,
  }) {
    final List<MediaItem> mediaItems = [];
    final now = DateTime.now();

    for (final file in files) {
      mediaItems.add(MediaItem(
        id: '${designId ?? 'legacy'}_${file.id}',
        type: file.fileType == 'pdf' ? MediaType.pdf : MediaType.image,
        storagePath: file.fileUrl,
        downloadUrl: file.fileUrl,
        thumbnailUrl: file.isThumbnail ? file.fileUrl : null,
        isCover: file.isThumbnail,
        name: file.fileName,
        sizeBytes: file.fileSize,
        uploadedAt: DateTime.tryParse(file.uploadDate) ?? now,
        uploadedBy: uploadedBy ?? 'system',
      ));
    }

    return mediaItems;
  }

  /// Convert new media array back to legacy Post format (for backward compatibility)
  static Map<String, dynamic> toLegacyPost(List<MediaItem> mediaItems) {
    final images = mediaItems.where((m) => m.type == MediaType.image).toList();
    final pdfs = mediaItems.where((m) => m.type == MediaType.pdf).toList();
    
    final coverImage = images.where((m) => m.isCover).firstOrNull;
    final otherImages = images.where((m) => !m.isCover).toList();

    return {
      'imageUrl': coverImage?.downloadUrl,
      'imageUrls': [coverImage?.downloadUrl, ...otherImages.map((m) => m.downloadUrl)].where((url) => url != null).cast<String>().toList(),
      'pdfUrls': pdfs.map((m) => m.downloadUrl).toList(),
    };
  }

  /// Convert new media array back to legacy ProductDesign format
  static List<ProductDesignFile> toLegacyProductDesign(List<MediaItem> mediaItems) {
    return mediaItems.map((media) => ProductDesignFile(
      id: media.id,
      fileName: media.name,
      fileType: media.type.name,
      fileUrl: media.downloadUrl,
      fileSize: media.sizeBytes,
      uploadDate: media.uploadedAt.toIso8601String(),
      isThumbnail: media.isCover,
    )).toList();
  }

  /// Extract filename from URL
  static String _extractFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
}

/// Media validation and limits
class MediaConstraints {
  static const int maxImagesPerPost = 10;
  static const int maxPdfsPerPost = 5;
  static const int maxTotalFilesPerPost = 15;
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB
  static const int maxPdfSizeBytes = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedPdfTypes = ['pdf'];

  static bool isValidImageType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return allowedImageTypes.contains(extension);
  }

  static bool isValidPdfType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return allowedPdfTypes.contains(extension);
  }

  static bool isValidImageSize(int sizeBytes) {
    return sizeBytes <= maxImageSizeBytes;
  }

  static bool isValidPdfSize(int sizeBytes) {
    return sizeBytes <= maxPdfSizeBytes;
  }

  static String? validateMediaItem(MediaItem media) {
    if (media.type == MediaType.image) {
      if (!isValidImageType(media.name)) {
        return 'Invalid image format. Allowed: ${allowedImageTypes.join(', ')}';
      }
      if (!isValidImageSize(media.sizeBytes)) {
        return 'Image too large. Max size: ${maxImageSizeBytes ~/ (1024 * 1024)}MB';
      }
    } else if (media.type == MediaType.pdf) {
      if (!isValidPdfType(media.name)) {
        return 'Invalid PDF format';
      }
      if (!isValidPdfSize(media.sizeBytes)) {
        return 'PDF too large. Max size: ${maxPdfSizeBytes ~/ (1024 * 1024)}MB';
      }
    }
    return null;
  }

  static String? validateMediaList(List<MediaItem> mediaItems) {
    final images = mediaItems.where((m) => m.type == MediaType.image).toList();
    final pdfs = mediaItems.where((m) => m.type == MediaType.pdf).toList();
    final totalFiles = mediaItems.length;

    if (images.length > maxImagesPerPost) {
      return 'Too many images. Max allowed: $maxImagesPerPost';
    }
    if (pdfs.length > maxPdfsPerPost) {
      return 'Too many PDFs. Max allowed: $maxPdfsPerPost';
    }
    if (totalFiles > maxTotalFilesPerPost) {
      return 'Too many files total. Max allowed: $maxTotalFilesPerPost';
    }

    // Check for exactly one cover image if images exist
    final coverImages = images.where((m) => m.isCover).length;
    if (images.isNotEmpty && coverImages != 1) {
      return 'Exactly one image must be marked as cover when images are present';
    }

    // Validate each media item
    for (final media in mediaItems) {
      final error = validateMediaItem(media);
      if (error != null) return error;
    }

    return null;
  }
}


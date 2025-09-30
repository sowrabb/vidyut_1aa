// Shared media components for all StateInfo profiles
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../app/tokens.dart';
import '../../../services/media_storage_service.dart';
import '../models/media_models.dart';
import '../models/state_info_models.dart';
import 'media_uploader_widget.dart';
import 'enhanced_post_editor.dart';
import 'enhanced_product_design_editor.dart';

/// Shared media uploader for all StateInfo profiles
class StateInfoMediaUploader extends StatelessWidget {
  final List<MediaItem> initialMedia;
  final String entityId;
  final String entityType; // 'power_generator', 'transmission_line', 'distribution_company', 'state', 'mandal'
  final String entitySubType; // 'posts' or 'product_designs'
  final Function(List<MediaItem>) onMediaChanged;
  final int? maxImages;
  final int? maxPdfs;
  final int? maxTotalFiles;

  const StateInfoMediaUploader({
    super.key,
    required this.initialMedia,
    required this.entityId,
    required this.entityType,
    required this.entitySubType,
    required this.onMediaChanged,
    this.maxImages,
    this.maxPdfs,
    this.maxTotalFiles,
  });

  @override
  Widget build(BuildContext context) {
    return MediaUploaderWidget(
      initialMedia: initialMedia,
      postId: entityId,
      onMediaChanged: onMediaChanged,
      maxImages: maxImages,
      maxPdfs: maxPdfs,
      maxTotalFiles: maxTotalFiles,
    );
  }
}

/// Shared post editor for all StateInfo profiles
class StateInfoPostEditor {
  static void show({
    required BuildContext context,
    required String entityId,
    required String entityType,
    required String author,
    Post? initialPost,
    required Function(Post) onSave,
  }) {
    showEnhancedPostEditor(
      context: context,
      initialPost: initialPost,
      postId: initialPost?.id ?? const Uuid().v4(),
      author: author,
      onSave: onSave,
    );
  }
}

/// Shared product design editor for all StateInfo profiles
class StateInfoProductDesignEditor {
  static void show({
    required BuildContext context,
    required String entityId,
    required String entityType,
    required String author,
    required String sectorType,
    required String sectorId,
    required String stateId,
    ProductDesign? initialDesign,
    required Function(ProductDesign) onSave,
  }) {
    showEnhancedProductDesignEditor(
      context: context,
      initialDesign: initialDesign,
      designId: initialDesign?.id ?? const Uuid().v4(),
      author: author,
      sectorType: sectorType,
      sectorId: sectorId,
      stateId: stateId,
      onSave: onSave,
    );
  }
}

/// Shared media constraints for all StateInfo profiles
class StateInfoMediaConstraints {
  // Default limits for all profiles
  static const int defaultMaxImagesPerPost = 10;
  static const int defaultMaxPdfsPerPost = 5;
  static const int defaultMaxTotalFilesPerPost = 15;
  
  // Profile-specific limits (can be overridden)
  static const Map<String, Map<String, int>> profileLimits = {
    'power_generator': {
      'maxImages': 15,
      'maxPdfs': 8,
      'maxTotalFiles': 20,
    },
    'transmission_line': {
      'maxImages': 12,
      'maxPdfs': 6,
      'maxTotalFiles': 18,
    },
    'distribution_company': {
      'maxImages': 10,
      'maxPdfs': 5,
      'maxTotalFiles': 15,
    },
    'state': {
      'maxImages': 20,
      'maxPdfs': 10,
      'maxTotalFiles': 25,
    },
    'mandal': {
      'maxImages': 8,
      'maxPdfs': 4,
      'maxTotalFiles': 12,
    },
  };

  static int getMaxImages(String entityType) {
    return profileLimits[entityType]?['maxImages'] ?? defaultMaxImagesPerPost;
  }

  static int getMaxPdfs(String entityType) {
    return profileLimits[entityType]?['maxPdfs'] ?? defaultMaxPdfsPerPost;
  }

  static int getMaxTotalFiles(String entityType) {
    return profileLimits[entityType]?['maxTotalFiles'] ?? defaultMaxTotalFilesPerPost;
  }
}

/// Shared Firebase Storage path generator for all StateInfo profiles
class StateInfoStoragePaths {
  static String getPostMediaPath(String entityType, String entityId, String mediaId, String fileExtension) {
    return 'stateInfo/$entityType/$entityId/posts/$mediaId$fileExtension';
  }

  static String getProductDesignMediaPath(String entityType, String entityId, String mediaId, String fileExtension) {
    return 'stateInfo/$entityType/$entityId/product_designs/$mediaId$fileExtension';
  }

  static String getEntityPath(String entityType, String entityId) {
    return 'stateInfo/$entityType/$entityId';
  }
}

/// Shared media adapter for all StateInfo profiles
class StateInfoMediaAdapter {
  /// Convert legacy Post data to MediaItem list for any profile type
  static List<MediaItem> fromLegacyPost({
    String? imageUrl,
    List<String> imageUrls = const [],
    List<String> pdfUrls = const [],
    required String postId,
    required String entityType,
  }) {
    return MediaAdapter.fromLegacyPost(
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      pdfUrls: pdfUrls,
      postId: postId,
    );
  }

  /// Convert legacy ProductDesign data to MediaItem list for any profile type
  static List<MediaItem> fromLegacyProductDesign({
    List<ProductDesignFile> files = const [],
    required String designId,
    required String entityType,
  }) {
    return MediaAdapter.fromLegacyProductDesign(
      files: files,
      designId: designId,
    );
  }
}

/// Shared profile media utilities
class StateInfoMediaUtils {
  /// Get media limits for a specific profile type
  static Map<String, int> getMediaLimits(String entityType) {
    return {
      'maxImages': StateInfoMediaConstraints.getMaxImages(entityType),
      'maxPdfs': StateInfoMediaConstraints.getMaxPdfs(entityType),
      'maxTotalFiles': StateInfoMediaConstraints.getMaxTotalFiles(entityType),
    };
  }

  /// Validate media upload for a specific profile type
  static bool validateMediaUpload(String entityType, List<MediaItem> currentMedia, List<MediaItem> newMedia) {
    final limits = getMediaLimits(entityType);
    final currentImages = currentMedia.where((m) => m.type == MediaType.image).length;
    final currentPdfs = currentMedia.where((m) => m.type == MediaType.pdf).length;
    final currentTotal = currentMedia.length;

    final newImages = newMedia.where((m) => m.type == MediaType.image).length;
    final newPdfs = newMedia.where((m) => m.type == MediaType.pdf).length;
    final newTotal = newMedia.length;

    return (currentImages + newImages) <= limits['maxImages']! &&
           (currentPdfs + newPdfs) <= limits['maxPdfs']! &&
           (currentTotal + newTotal) <= limits['maxTotalFiles']!;
  }

  /// Get validation error message for media upload
  static String? getValidationError(String entityType, List<MediaItem> currentMedia, List<MediaItem> newMedia) {
    final limits = getMediaLimits(entityType);
    final currentImages = currentMedia.where((m) => m.type == MediaType.image).length;
    final currentPdfs = currentMedia.where((m) => m.type == MediaType.pdf).length;
    final currentTotal = currentMedia.length;

    final newImages = newMedia.where((m) => m.type == MediaType.image).length;
    final newPdfs = newMedia.where((m) => m.type == MediaType.pdf).length;
    final newTotal = newMedia.length;

    if ((currentImages + newImages) > limits['maxImages']!) {
      return 'Too many images. Maximum allowed: ${limits['maxImages']}';
    }
    if ((currentPdfs + newPdfs) > limits['maxPdfs']!) {
      return 'Too many PDFs. Maximum allowed: ${limits['maxPdfs']}';
    }
    if ((currentTotal + newTotal) > limits['maxTotalFiles']!) {
      return 'Too many files. Maximum allowed: ${limits['maxTotalFiles']}';
    }
    return null;
  }
}

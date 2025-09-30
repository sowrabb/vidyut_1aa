/// Media & Storage Management Models
library;

class MediaFile {
  final String id;
  final String filename;
  final String originalFilename;
  final String mimeType;
  final int fileSize;
  final String url;
  final String? thumbnailUrl;
  final Map<String, String> variants;
  final MediaFileType type;
  final MediaFileStatus status;
  final Map<String, dynamic> metadata;
  final String uploadedBy;
  final DateTime uploadedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaFile({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.mimeType,
    required this.fileSize,
    required this.url,
    this.thumbnailUrl,
    required this.variants,
    required this.type,
    required this.status,
    required this.metadata,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) => MediaFile(
        id: json['id'] as String,
        filename: json['filename'] as String,
        originalFilename: json['original_filename'] as String,
        mimeType: json['mime_type'] as String,
        fileSize: json['file_size'] as int,
        url: json['url'] as String,
        thumbnailUrl: json['thumbnail_url'] as String?,
        variants: Map<String, String>.from(json['variants'] ?? {}),
        type: MediaFileType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => MediaFileType.image,
        ),
        status: MediaFileStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => MediaFileStatus.uploaded,
        ),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        uploadedBy: json['uploaded_by'] as String,
        uploadedAt: DateTime.parse(json['uploaded_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'original_filename': originalFilename,
        'mime_type': mimeType,
        'file_size': fileSize,
        'url': url,
        'thumbnail_url': thumbnailUrl,
        'variants': variants,
        'type': type.value,
        'status': status.value,
        'metadata': metadata,
        'uploaded_by': uploadedBy,
        'uploaded_at': uploadedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

enum MediaFileType {
  image('image'),
  video('video'),
  audio('audio'),
  document('document'),
  archive('archive'),
  other('other');

  const MediaFileType(this.value);
  final String value;
}

enum MediaFileStatus {
  uploading('uploading'),
  uploaded('uploaded'),
  processing('processing'),
  processed('processed'),
  failed('failed'),
  deleted('deleted');

  const MediaFileStatus(this.value);
  final String value;
}

class CDNVariant {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> transformation;
  final String urlPattern;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CDNVariant({
    required this.id,
    required this.name,
    required this.description,
    required this.transformation,
    required this.urlPattern,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CDNVariant.fromJson(Map<String, dynamic> json) => CDNVariant(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        transformation: Map<String, dynamic>.from(json['transformation'] ?? {}),
        urlPattern: json['url_pattern'] as String,
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'transformation': transformation,
        'url_pattern': urlPattern,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class MediaUploadJob {
  final String id;
  final String filename;
  final String originalFilename;
  final String mimeType;
  final int fileSize;
  final UploadJobStatus status;
  final double progress;
  final String? error;
  final String? fileId;
  final Map<String, dynamic> metadata;
  final String uploadedBy;
  final DateTime createdAt;
  final DateTime? completedAt;

  MediaUploadJob({
    required this.id,
    required this.filename,
    required this.originalFilename,
    required this.mimeType,
    required this.fileSize,
    required this.status,
    required this.progress,
    this.error,
    this.fileId,
    required this.metadata,
    required this.uploadedBy,
    required this.createdAt,
    this.completedAt,
  });

  factory MediaUploadJob.fromJson(Map<String, dynamic> json) => MediaUploadJob(
        id: json['id'] as String,
        filename: json['filename'] as String,
        originalFilename: json['original_filename'] as String,
        mimeType: json['mime_type'] as String,
        fileSize: json['file_size'] as int,
        status: UploadJobStatus.values.firstWhere(
          (e) => e.value == json['status'],
          orElse: () => UploadJobStatus.pending,
        ),
        progress: (json['progress'] as num).toDouble(),
        error: json['error'] as String?,
        fileId: json['file_id'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        uploadedBy: json['uploaded_by'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'original_filename': originalFilename,
        'mime_type': mimeType,
        'file_size': fileSize,
        'status': status.value,
        'progress': progress,
        'error': error,
        'file_id': fileId,
        'metadata': metadata,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
      };
}

enum UploadJobStatus {
  pending('pending'),
  uploading('uploading'),
  processing('processing'),
  completed('completed'),
  failed('failed'),
  cancelled('cancelled');

  const UploadJobStatus(this.value);
  final String value;
}

class StorageQuota {
  final String userId;
  final int totalSpace;
  final int usedSpace;
  final int availableSpace;
  final Map<String, int> usageByType;
  final DateTime lastUpdated;

  StorageQuota({
    required this.userId,
    required this.totalSpace,
    required this.usedSpace,
    required this.availableSpace,
    required this.usageByType,
    required this.lastUpdated,
  });

  factory StorageQuota.fromJson(Map<String, dynamic> json) => StorageQuota(
        userId: json['user_id'] as String,
        totalSpace: json['total_space'] as int,
        usedSpace: json['used_space'] as int,
        availableSpace: json['available_space'] as int,
        usageByType: Map<String, int>.from(json['usage_by_type'] ?? {}),
        lastUpdated: DateTime.parse(json['last_updated'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'total_space': totalSpace,
        'used_space': usedSpace,
        'available_space': availableSpace,
        'usage_by_type': usageByType,
        'last_updated': lastUpdated.toIso8601String(),
      };
}

class MediaValidationRule {
  final String id;
  final String name;
  final String description;
  final MediaFileType fileType;
  final int maxFileSize;
  final List<String> allowedMimeTypes;
  final List<String> allowedExtensions;
  final Map<String, dynamic> validationRules;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaValidationRule({
    required this.id,
    required this.name,
    required this.description,
    required this.fileType,
    required this.maxFileSize,
    required this.allowedMimeTypes,
    required this.allowedExtensions,
    required this.validationRules,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaValidationRule.fromJson(Map<String, dynamic> json) =>
      MediaValidationRule(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        fileType: MediaFileType.values.firstWhere(
          (e) => e.value == json['file_type'],
          orElse: () => MediaFileType.image,
        ),
        maxFileSize: json['max_file_size'] as int,
        allowedMimeTypes: List<String>.from(json['allowed_mime_types'] ?? []),
        allowedExtensions: List<String>.from(json['allowed_extensions'] ?? []),
        validationRules:
            Map<String, dynamic>.from(json['validation_rules'] ?? {}),
        isActive: json['is_active'] as bool,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'file_type': fileType.value,
        'max_file_size': maxFileSize,
        'allowed_mime_types': allowedMimeTypes,
        'allowed_extensions': allowedExtensions,
        'validation_rules': validationRules,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class OrphanedFile {
  final String id;
  final String filename;
  final String url;
  final MediaFileType type;
  final int fileSize;
  final DateTime createdAt;
  final DateTime lastAccessed;
  final bool isReferenced;

  OrphanedFile({
    required this.id,
    required this.filename,
    required this.url,
    required this.type,
    required this.fileSize,
    required this.createdAt,
    required this.lastAccessed,
    required this.isReferenced,
  });

  factory OrphanedFile.fromJson(Map<String, dynamic> json) => OrphanedFile(
        id: json['id'] as String,
        filename: json['filename'] as String,
        url: json['url'] as String,
        type: MediaFileType.values.firstWhere(
          (e) => e.value == json['type'],
          orElse: () => MediaFileType.image,
        ),
        fileSize: json['file_size'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        lastAccessed: DateTime.parse(json['last_accessed'] as String),
        isReferenced: json['is_referenced'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'filename': filename,
        'url': url,
        'type': type.value,
        'file_size': fileSize,
        'created_at': createdAt.toIso8601String(),
        'last_accessed': lastAccessed.toIso8601String(),
        'is_referenced': isReferenced,
      };
}

// Request/Response Models

class CreateCDNVariantRequest {
  final String name;
  final String description;
  final Map<String, dynamic> transformation;
  final String urlPattern;

  CreateCDNVariantRequest({
    required this.name,
    required this.description,
    required this.transformation,
    required this.urlPattern,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'transformation': transformation,
        'url_pattern': urlPattern,
      };
}

class UpdateCDNVariantRequest {
  final String? name;
  final String? description;
  final Map<String, dynamic>? transformation;
  final String? urlPattern;
  final bool? isActive;

  UpdateCDNVariantRequest({
    this.name,
    this.description,
    this.transformation,
    this.urlPattern,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
        if (transformation != null) 'transformation': transformation,
        if (urlPattern != null) 'url_pattern': urlPattern,
        if (isActive != null) 'is_active': isActive,
      };
}

class CreateMediaValidationRuleRequest {
  final String name;
  final String description;
  final MediaFileType fileType;
  final int maxFileSize;
  final List<String> allowedMimeTypes;
  final List<String> allowedExtensions;
  final Map<String, dynamic> validationRules;

  CreateMediaValidationRuleRequest({
    required this.name,
    required this.description,
    required this.fileType,
    required this.maxFileSize,
    required this.allowedMimeTypes,
    required this.allowedExtensions,
    required this.validationRules,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'file_type': fileType.value,
        'max_file_size': maxFileSize,
        'allowed_mime_types': allowedMimeTypes,
        'allowed_extensions': allowedExtensions,
        'validation_rules': validationRules,
      };
}

class MediaFileListResponse {
  final List<MediaFile> files;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  MediaFileListResponse({
    required this.files,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory MediaFileListResponse.fromJson(Map<String, dynamic> json) =>
      MediaFileListResponse(
        files:
            (json['files'] as List).map((f) => MediaFile.fromJson(f)).toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class CDNVariantListResponse {
  final List<CDNVariant> variants;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  CDNVariantListResponse({
    required this.variants,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory CDNVariantListResponse.fromJson(Map<String, dynamic> json) =>
      CDNVariantListResponse(
        variants: (json['variants'] as List)
            .map((v) => CDNVariant.fromJson(v))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class MediaUploadJobListResponse {
  final List<MediaUploadJob> jobs;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  MediaUploadJobListResponse({
    required this.jobs,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory MediaUploadJobListResponse.fromJson(Map<String, dynamic> json) =>
      MediaUploadJobListResponse(
        jobs: (json['jobs'] as List)
            .map((j) => MediaUploadJob.fromJson(j))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

class OrphanedFileListResponse {
  final List<OrphanedFile> files;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;
  final int totalSizeBytes;

  OrphanedFileListResponse({
    required this.files,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.totalSizeBytes,
  });

  factory OrphanedFileListResponse.fromJson(Map<String, dynamic> json) =>
      OrphanedFileListResponse(
        files: (json['files'] as List)
            .map((f) => OrphanedFile.fromJson(f))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
        totalSizeBytes: json['total_size_bytes'] as int,
      );
}

class MediaUploadResponse {
  final String jobId;
  final String uploadUrl;
  final Map<String, dynamic> fields;
  final DateTime expiresAt;

  MediaUploadResponse({
    required this.jobId,
    required this.uploadUrl,
    required this.fields,
    required this.expiresAt,
  });

  factory MediaUploadResponse.fromJson(Map<String, dynamic> json) =>
      MediaUploadResponse(
        jobId: json['job_id'] as String,
        uploadUrl: json['upload_url'] as String,
        fields: Map<String, dynamic>.from(json['fields'] ?? {}),
        expiresAt: DateTime.parse(json['expires_at'] as String),
      );
}

class MediaValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  MediaValidationResult({
    required this.isValid,
    required this.errors,
    required this.warnings,
    required this.metadata,
  });

  factory MediaValidationResult.fromJson(Map<String, dynamic> json) =>
      MediaValidationResult(
        isValid: json['is_valid'] as bool,
        errors: List<String>.from(json['errors'] ?? []),
        warnings: List<String>.from(json['warnings'] ?? []),
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      );
}

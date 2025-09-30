import 'dart:typed_data';
import 'package:flutter/foundation.dart';

enum StagedAttachmentType { image, pdf }

enum UploadState { idle, uploading, success, failed, canceled }

class StagedAttachment {
  final String localId;
  final String name;
  final StagedAttachmentType type;
  final int sizeBytes;
  final Uint8List? originalBytes; // when available (web or preloaded)
  final Uint8List? previewThumbnailBytes;
  final int? imageWidth;
  final int? imageHeight;

  // Upload state
  final UploadState state;
  final double progress; // 0..1
  final String? errorMessage;
  final String? storagePath;
  final String? downloadUrl;
  final String? thumbnailUrl;

  const StagedAttachment({
    required this.localId,
    required this.name,
    required this.type,
    required this.sizeBytes,
    this.originalBytes,
    this.previewThumbnailBytes,
    this.imageWidth,
    this.imageHeight,
    this.state = UploadState.idle,
    this.progress = 0.0,
    this.errorMessage,
    this.storagePath,
    this.downloadUrl,
    this.thumbnailUrl,
  });

  bool get isImage => type == StagedAttachmentType.image;
  bool get isPdf => type == StagedAttachmentType.pdf;

  StagedAttachment copyWith({
    String? localId,
    String? name,
    StagedAttachmentType? type,
    int? sizeBytes,
    Uint8List? originalBytes,
    Uint8List? previewThumbnailBytes,
    int? imageWidth,
    int? imageHeight,
    UploadState? state,
    double? progress,
    String? errorMessage,
    String? storagePath,
    String? downloadUrl,
    String? thumbnailUrl,
  }) {
    return StagedAttachment(
      localId: localId ?? this.localId,
      name: name ?? this.name,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      originalBytes: originalBytes ?? this.originalBytes,
      previewThumbnailBytes:
          previewThumbnailBytes ?? this.previewThumbnailBytes,
      imageWidth: imageWidth ?? this.imageWidth,
      imageHeight: imageHeight ?? this.imageHeight,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      storagePath: storagePath ?? this.storagePath,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    );
  }
}



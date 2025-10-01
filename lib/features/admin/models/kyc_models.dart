import 'package:flutter/foundation.dart';

/// KYC Submission Model (simplified for providers)
class KycSubmission {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String businessName; // Company/business name
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewerId;
  final String? reviewedBy; // Reviewer name
  final String? reviewComments;
  final String? notes; // Additional notes
  final List<Map<String, dynamic>> documents;
  final Map<String, dynamic>? metadata;

  KycSubmission({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.businessName = '',
    required this.status,
    required this.createdAt,
    this.reviewedAt,
    this.reviewerId,
    this.reviewedBy,
    this.reviewComments,
    this.notes,
    this.documents = const [],
    this.metadata,
  });

  factory KycSubmission.fromJson(Map<String, dynamic> json) => KycSubmission(
    id: json['id'] as String,
    userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
    userName: json['user_name'] as String? ?? json['userName'] as String? ?? '',
    userEmail: json['user_email'] as String? ?? json['userEmail'] as String? ?? '',
    businessName: json['business_name'] as String? ?? json['businessName'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
    reviewedAt: json['reviewed_at'] != null
        ? DateTime.parse(json['reviewed_at'] as String)
        : json['reviewedAt'] != null
            ? DateTime.parse(json['reviewedAt'] as String)
            : null,
    reviewerId: json['reviewer_id'] as String? ?? json['reviewerId'] as String?,
    reviewedBy: json['reviewed_by'] as String? ?? json['reviewedBy'] as String?,
    reviewComments: json['review_comments'] as String? ?? json['reviewComments'] as String?,
    notes: json['notes'] as String?,
    documents: List<Map<String, dynamic>>.from(json['documents'] ?? []),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'user_name': userName,
    'user_email': userEmail,
    'business_name': businessName,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
    if (reviewerId != null) 'reviewer_id': reviewerId,
    if (reviewedBy != null) 'reviewed_by': reviewedBy,
    if (reviewComments != null) 'review_comments': reviewComments,
    if (notes != null) 'notes': notes,
    'documents': documents,
    if (metadata != null) 'metadata': metadata,
  };

  KycSubmission copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? businessName,
    String? status,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewerId,
    String? reviewedBy,
    String? reviewComments,
    String? notes,
    List<Map<String, dynamic>>? documents,
    Map<String, dynamic>? metadata,
  }) => KycSubmission(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    userName: userName ?? this.userName,
    userEmail: userEmail ?? this.userEmail,
    businessName: businessName ?? this.businessName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    reviewerId: reviewerId ?? this.reviewerId,
    reviewedBy: reviewedBy ?? this.reviewedBy,
    reviewComments: reviewComments ?? this.reviewComments,
    notes: notes ?? this.notes,
    documents: documents ?? this.documents,
    metadata: metadata ?? this.metadata,
  );
}

/// KYC Document Types
enum KycDocumentType {
  panCard('pan_card', 'PAN Card'),
  aadharCard('aadhar_card', 'Aadhar Card'),
  passport('passport', 'Passport'),
  drivingLicense('driving_license', 'Driving License'),
  voterId('voter_id', 'Voter ID'),
  bankStatement('bank_statement', 'Bank Statement'),
  utilityBill('utility_bill', 'Utility Bill'),
  businessLicense('business_license', 'Business License'),
  gstCertificate('gst_certificate', 'GST Certificate'),
  companyIncorporation('company_incorporation', 'Company Incorporation'),
  other('other', 'Other');

  const KycDocumentType(this.value, this.displayName);
  final String value;
  final String displayName;

  static KycDocumentType fromString(String value) {
    return KycDocumentType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => KycDocumentType.other,
    );
  }
}

/// KYC Document Status
enum KycDocumentStatus {
  pending('pending', 'Pending'),
  underReview('under_review', 'Under Review'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  expired('expired', 'Expired'),
  requiresResubmission('requires_resubmission', 'Requires Resubmission');

  const KycDocumentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static KycDocumentStatus fromString(String value) {
    return KycDocumentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => KycDocumentStatus.pending,
    );
  }
}

/// KYC Review Status
enum KycReviewStatus {
  pending('pending', 'Pending'),
  inProgress('in_progress', 'In Progress'),
  approved('approved', 'Approved'),
  rejected('rejected', 'Rejected'),
  requiresAdditionalInfo(
      'requires_additional_info', 'Requires Additional Info'),
  onHold('on_hold', 'On Hold');

  const KycReviewStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static KycReviewStatus fromString(String value) {
    return KycReviewStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => KycReviewStatus.pending,
    );
  }
}

/// KYC Document Model
class KycDocument {
  final String id;
  final String userId;
  final KycDocumentType type;
  final String fileName;
  final String fileUrl;
  final String? thumbnailUrl;
  final KycDocumentStatus status;
  final String? rejectionReason;
  final String? reviewerId;
  final DateTime? reviewedAt;
  final DateTime uploadedAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? extractedData;
  final List<String> tags;
  final int fileSize;
  final String mimeType;

  KycDocument({
    required this.id,
    required this.userId,
    required this.type,
    required this.fileName,
    required this.fileUrl,
    this.thumbnailUrl,
    required this.status,
    this.rejectionReason,
    this.reviewerId,
    this.reviewedAt,
    required this.uploadedAt,
    this.expiresAt,
    this.extractedData,
    this.tags = const [],
    required this.fileSize,
    required this.mimeType,
  });

  factory KycDocument.fromJson(Map<String, dynamic> json) => KycDocument(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        type: KycDocumentType.fromString(json['type'] as String),
        fileName: json['file_name'] as String,
        fileUrl: json['file_url'] as String,
        thumbnailUrl: json['thumbnail_url'] as String?,
        status: KycDocumentStatus.fromString(json['status'] as String),
        rejectionReason: json['rejection_reason'] as String?,
        reviewerId: json['reviewer_id'] as String?,
        reviewedAt: json['reviewed_at'] != null
            ? DateTime.parse(json['reviewed_at'] as String)
            : null,
        uploadedAt: DateTime.parse(json['uploaded_at'] as String),
        expiresAt: json['expires_at'] != null
            ? DateTime.parse(json['expires_at'] as String)
            : null,
        extractedData: json['extracted_data'] as Map<String, dynamic>?,
        tags: List<String>.from(json['tags'] ?? []),
        fileSize: json['file_size'] as int,
        mimeType: json['mime_type'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'type': type.value,
        'file_name': fileName,
        'file_url': fileUrl,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
        'status': status.value,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (reviewerId != null) 'reviewer_id': reviewerId,
        if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
        'uploaded_at': uploadedAt.toIso8601String(),
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        if (extractedData != null) 'extracted_data': extractedData,
        'tags': tags,
        'file_size': fileSize,
        'mime_type': mimeType,
      };

  KycDocument copyWith({
    String? id,
    String? userId,
    KycDocumentType? type,
    String? fileName,
    String? fileUrl,
    String? thumbnailUrl,
    KycDocumentStatus? status,
    String? rejectionReason,
    String? reviewerId,
    DateTime? reviewedAt,
    DateTime? uploadedAt,
    DateTime? expiresAt,
    Map<String, dynamic>? extractedData,
    List<String>? tags,
    int? fileSize,
    String? mimeType,
  }) =>
      KycDocument(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        type: type ?? this.type,
        fileName: fileName ?? this.fileName,
        fileUrl: fileUrl ?? this.fileUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        status: status ?? this.status,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        reviewerId: reviewerId ?? this.reviewerId,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        uploadedAt: uploadedAt ?? this.uploadedAt,
        expiresAt: expiresAt ?? this.expiresAt,
        extractedData: extractedData ?? this.extractedData,
        tags: tags ?? this.tags,
        fileSize: fileSize ?? this.fileSize,
        mimeType: mimeType ?? this.mimeType,
      );
}

/// KYC Review Model
class KycReview {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final KycReviewStatus status;
  final List<KycDocument> documents;
  final String? reviewerId;
  final String? reviewerName;
  final DateTime? reviewedAt;
  final String? reviewComments;
  final String? rejectionReason;
  final List<String> requiredDocuments;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? slaDeadline;
  final int priority;
  final Map<String, dynamic>? riskFlags;
  final String? nextSteps;

  KycReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.status,
    required this.documents,
    this.reviewerId,
    this.reviewerName,
    this.reviewedAt,
    this.reviewComments,
    this.rejectionReason,
    this.requiredDocuments = const [],
    required this.createdAt,
    required this.updatedAt,
    this.slaDeadline,
    this.priority = 0,
    this.riskFlags,
    this.nextSteps,
  });

  factory KycReview.fromJson(Map<String, dynamic> json) => KycReview(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        userName: json['user_name'] as String,
        userEmail: json['user_email'] as String,
        status: KycReviewStatus.fromString(json['status'] as String),
        documents: (json['documents'] as List)
            .map((doc) => KycDocument.fromJson(doc))
            .toList(),
        reviewerId: json['reviewer_id'] as String?,
        reviewerName: json['reviewer_name'] as String?,
        reviewedAt: json['reviewed_at'] != null
            ? DateTime.parse(json['reviewed_at'] as String)
            : null,
        reviewComments: json['review_comments'] as String?,
        rejectionReason: json['rejection_reason'] as String?,
        requiredDocuments: List<String>.from(json['required_documents'] ?? []),
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        slaDeadline: json['sla_deadline'] != null
            ? DateTime.parse(json['sla_deadline'] as String)
            : null,
        priority: json['priority'] as int? ?? 0,
        riskFlags: json['risk_flags'] as Map<String, dynamic>?,
        nextSteps: json['next_steps'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'user_name': userName,
        'user_email': userEmail,
        'status': status.value,
        'documents': documents.map((doc) => doc.toJson()).toList(),
        if (reviewerId != null) 'reviewer_id': reviewerId,
        if (reviewerName != null) 'reviewer_name': reviewerName,
        if (reviewedAt != null) 'reviewed_at': reviewedAt!.toIso8601String(),
        if (reviewComments != null) 'review_comments': reviewComments,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        'required_documents': requiredDocuments,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        if (slaDeadline != null) 'sla_deadline': slaDeadline!.toIso8601String(),
        'priority': priority,
        if (riskFlags != null) 'risk_flags': riskFlags,
        if (nextSteps != null) 'next_steps': nextSteps,
      };

  KycReview copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    KycReviewStatus? status,
    List<KycDocument>? documents,
    String? reviewerId,
    String? reviewerName,
    DateTime? reviewedAt,
    String? reviewComments,
    String? rejectionReason,
    List<String>? requiredDocuments,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? slaDeadline,
    int? priority,
    Map<String, dynamic>? riskFlags,
    String? nextSteps,
  }) =>
      KycReview(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userEmail: userEmail ?? this.userEmail,
        status: status ?? this.status,
        documents: documents ?? this.documents,
        reviewerId: reviewerId ?? this.reviewerId,
        reviewerName: reviewerName ?? this.reviewerName,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        reviewComments: reviewComments ?? this.reviewComments,
        rejectionReason: rejectionReason ?? this.rejectionReason,
        requiredDocuments: requiredDocuments ?? this.requiredDocuments,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        slaDeadline: slaDeadline ?? this.slaDeadline,
        priority: priority ?? this.priority,
        riskFlags: riskFlags ?? this.riskFlags,
        nextSteps: nextSteps ?? this.nextSteps,
      );

  bool get isOverdue =>
      slaDeadline != null && DateTime.now().isAfter(slaDeadline!);
  bool get isHighPriority => priority >= 7;
  bool get requiresAttention =>
      status == KycReviewStatus.pending || status == KycReviewStatus.inProgress;
}

/// KYC Review Queue Statistics
class KycQueueStats {
  final int totalPending;
  final int totalInProgress;
  final int totalApproved;
  final int totalRejected;
  final int overdueReviews;
  final int highPriorityReviews;
  final double averageProcessingTime;
  final double slaCompliance;

  KycQueueStats({
    required this.totalPending,
    required this.totalInProgress,
    required this.totalApproved,
    required this.totalRejected,
    required this.overdueReviews,
    required this.highPriorityReviews,
    required this.averageProcessingTime,
    required this.slaCompliance,
  });

  factory KycQueueStats.fromJson(Map<String, dynamic> json) => KycQueueStats(
        totalPending: json['total_pending'] as int,
        totalInProgress: json['total_in_progress'] as int,
        totalApproved: json['total_approved'] as int,
        totalRejected: json['total_rejected'] as int,
        overdueReviews: json['overdue_reviews'] as int,
        highPriorityReviews: json['high_priority_reviews'] as int,
        averageProcessingTime:
            (json['average_processing_time'] as num).toDouble(),
        slaCompliance: (json['sla_compliance'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'total_pending': totalPending,
        'total_in_progress': totalInProgress,
        'total_approved': totalApproved,
        'total_rejected': totalRejected,
        'overdue_reviews': overdueReviews,
        'high_priority_reviews': highPriorityReviews,
        'average_processing_time': averageProcessingTime,
        'sla_compliance': slaCompliance,
      };
}

/// KYC Review Request Models
class UpdateKycReviewRequest {
  final KycReviewStatus? status;
  final String? reviewComments;
  final String? rejectionReason;
  final String? nextSteps;
  final List<String>? requiredDocuments;

  UpdateKycReviewRequest({
    this.status,
    this.reviewComments,
    this.rejectionReason,
    this.nextSteps,
    this.requiredDocuments,
  });

  Map<String, dynamic> toJson() => {
        if (status != null) 'status': status!.value,
        if (reviewComments != null) 'review_comments': reviewComments,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (nextSteps != null) 'next_steps': nextSteps,
        if (requiredDocuments != null) 'required_documents': requiredDocuments,
      };
}

class KycReviewListResponse {
  final List<KycReview> reviews;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  KycReviewListResponse({
    required this.reviews,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory KycReviewListResponse.fromJson(Map<String, dynamic> json) =>
      KycReviewListResponse(
        reviews: (json['reviews'] as List)
            .map((r) => KycReview.fromJson(r))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );
}

/// KYC Audit Log Entry
class KycAuditLog {
  final String id;
  final String reviewId;
  final String userId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final String? reason;
  final String actorId;
  final String actorName;
  final DateTime timestamp;
  final String? ipAddress;
  final String? userAgent;

  KycAuditLog({
    required this.id,
    required this.reviewId,
    required this.userId,
    required this.action,
    this.oldValue,
    this.newValue,
    this.reason,
    required this.actorId,
    required this.actorName,
    required this.timestamp,
    this.ipAddress,
    this.userAgent,
  });

  factory KycAuditLog.fromJson(Map<String, dynamic> json) => KycAuditLog(
        id: json['id'] as String,
        reviewId: json['review_id'] as String,
        userId: json['user_id'] as String,
        action: json['action'] as String,
        oldValue: json['old_value'] as String?,
        newValue: json['new_value'] as String?,
        reason: json['reason'] as String?,
        actorId: json['actor_id'] as String,
        actorName: json['actor_name'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        ipAddress: json['ip_address'] as String?,
        userAgent: json['user_agent'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'review_id': reviewId,
        'user_id': userId,
        'action': action,
        if (oldValue != null) 'old_value': oldValue,
        if (newValue != null) 'new_value': newValue,
        if (reason != null) 'reason': reason,
        'actor_id': actorId,
        'actor_name': actorName,
        'timestamp': timestamp.toIso8601String(),
        if (ipAddress != null) 'ip_address': ipAddress,
        if (userAgent != null) 'user_agent': userAgent,
      };
}

/// Bulk KYC Action Request
@immutable
class BulkKycActionRequest {
  final List<String> reviewIds;
  final String action;
  final String? reason;
  final Map<String, dynamic>? metadata;

  const BulkKycActionRequest({
    required this.reviewIds,
    required this.action,
    this.reason,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
        'review_ids': reviewIds,
        'action': action,
        if (reason != null) 'reason': reason,
        if (metadata != null) 'metadata': metadata,
      };
}

/// Bulk KYC Action Result
@immutable
class BulkKycActionResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final String? jobId;

  const BulkKycActionResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
    this.jobId,
  });

  factory BulkKycActionResult.fromJson(Map<String, dynamic> json) =>
      BulkKycActionResult(
        successCount: json['success_count'] as int,
        failureCount: json['failure_count'] as int,
        errors: List<String>.from(json['errors'] ?? []),
        jobId: json['job_id'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'success_count': successCount,
        'failure_count': failureCount,
        'errors': errors,
        if (jobId != null) 'job_id': jobId,
      };
}

/// KYC Audit Log List Response
@immutable
class KycAuditLogListResponse {
  final List<KycAuditLog> logs;
  final int totalCount;
  final int page;
  final int limit;
  final bool hasMore;

  const KycAuditLogListResponse({
    required this.logs,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory KycAuditLogListResponse.fromJson(Map<String, dynamic> json) =>
      KycAuditLogListResponse(
        logs: (json['logs'] as List)
            .map((log) => KycAuditLog.fromJson(log))
            .toList(),
        totalCount: json['total_count'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
        hasMore: json['has_more'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'logs': logs.map((log) => log.toJson()).toList(),
        'total_count': totalCount,
        'page': page,
        'limit': limit,
        'has_more': hasMore,
      };
}

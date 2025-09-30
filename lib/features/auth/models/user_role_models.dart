// User role and subscription models for seamless user-to-seller transition

import 'package:cloud_firestore/cloud_firestore.dart';

/// User role enumeration
enum UserRole {
  buyer('buyer', 'Buyer'),
  seller('seller', 'Seller'),
  admin('admin', 'Admin'),
  guest('guest', 'Guest');

  const UserRole(this.value, this.displayName);
  final String value;
  final String displayName;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.buyer,
    );
  }
}

/// User status enumeration
enum UserStatus {
  active('active', 'Active'),
  pending('pending', 'Pending'),
  suspended('suspended', 'Suspended'),
  inactive('inactive', 'Inactive');

  const UserStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => UserStatus.pending,
    );
  }
}

/// Subscription plan enumeration
enum SubscriptionPlan {
  free('free', 'Free'),
  plus('plus', 'Plus'),
  pro('pro', 'Pro'),
  enterprise('enterprise', 'Enterprise');

  const SubscriptionPlan(this.value, this.displayName);
  final String value;
  final String displayName;

  static SubscriptionPlan fromString(String value) {
    return SubscriptionPlan.values.firstWhere(
      (plan) => plan.value == value,
      orElse: () => SubscriptionPlan.free,
    );
  }
}

/// User model that combines authentication and business data
class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final UserRole role;
  final UserStatus status;
  final SubscriptionPlan subscriptionPlan;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActive;
  final String? location;
  final String? industry;
  final List<String> materials;
  final Map<String, dynamic> preferences;
  final bool isSeller;
  final String? sellerProfileId;
  final DateTime? sellerActivatedAt;
  final String? currentPlanCode; // Current active plan code

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    required this.role,
    required this.status,
    required this.subscriptionPlan,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastActive,
    this.location,
    this.industry,
    this.materials = const [],
    this.preferences = const {},
    this.isSeller = false,
    this.sellerProfileId,
    this.sellerActivatedAt,
    this.currentPlanCode,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    UserRole? role,
    UserStatus? status,
    SubscriptionPlan? subscriptionPlan,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastActive,
    String? location,
    String? industry,
    List<String>? materials,
    Map<String, dynamic>? preferences,
    bool? isSeller,
    String? sellerProfileId,
    DateTime? sellerActivatedAt,
    String? currentPlanCode,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActive: lastActive ?? this.lastActive,
      location: location ?? this.location,
      industry: industry ?? this.industry,
      materials: materials ?? this.materials,
      preferences: preferences ?? this.preferences,
      isSeller: isSeller ?? this.isSeller,
      sellerProfileId: sellerProfileId ?? this.sellerProfileId,
      sellerActivatedAt: sellerActivatedAt ?? this.sellerActivatedAt,
      currentPlanCode: currentPlanCode ?? this.currentPlanCode,
    );
  }

  /// Check if user can become a seller
  bool get canBecomeSeller {
    return role == UserRole.buyer && status == UserStatus.active && !isSeller;
  }

  /// Check if user is an active seller
  bool get isActiveSeller {
    return isSeller && role == UserRole.seller && status == UserStatus.active;
  }

  /// Check if user has a valid subscription
  bool get hasValidSubscription {
    return subscriptionPlan != SubscriptionPlan.free && currentPlanCode != null;
  }

  /// Get subscription display name
  String get subscriptionDisplayName {
    return subscriptionPlan.displayName;
  }

  /// Get role display name
  String get roleDisplayName {
    return role.displayName;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'role': role.value,
      'status': status.value,
      'subscription_plan': subscriptionPlan.value,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'last_active':
          lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'location': location,
      'industry': industry,
      'materials': materials,
      'preferences': preferences,
      'is_seller': isSeller,
      'seller_profile_id': sellerProfileId,
      'seller_activated_at': sellerActivatedAt != null
          ? Timestamp.fromDate(sellerActivatedAt!)
          : null,
      'current_plan_code': currentPlanCode,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      role: UserRole.fromString(json['role'] as String),
      status: UserStatus.fromString(json['status'] as String),
      subscriptionPlan:
          SubscriptionPlan.fromString(json['subscription_plan'] as String),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
      lastActive: json['last_active'] != null
          ? (json['last_active'] as Timestamp).toDate()
          : null,
      location: json['location'] as String?,
      industry: json['industry'] as String?,
      materials: List<String>.from(json['materials'] ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      isSeller: json['is_seller'] as bool? ?? false,
      sellerProfileId: json['seller_profile_id'] as String?,
      sellerActivatedAt: json['seller_activated_at'] != null
          ? (json['seller_activated_at'] as Timestamp).toDate()
          : null,
      currentPlanCode: json['current_plan_code'] as String?,
    );
  }
}

/// User role transition request
class RoleTransitionRequest {
  final String id;
  final String userId;
  final UserRole fromRole;
  final UserRole toRole;
  final String? planCode;
  final String? reason;
  final String status; // pending, approved, rejected
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? processedBy;

  const RoleTransitionRequest({
    required this.id,
    required this.userId,
    required this.fromRole,
    required this.toRole,
    this.planCode,
    this.reason,
    this.status = 'pending',
    this.adminNotes,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'from_role': fromRole.value,
      'to_role': toRole.value,
      'plan_code': planCode,
      'reason': reason,
      'status': status,
      'admin_notes': adminNotes,
      'created_at': Timestamp.fromDate(createdAt),
      'processed_at':
          processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'processed_by': processedBy,
    };
  }

  factory RoleTransitionRequest.fromJson(Map<String, dynamic> json) {
    return RoleTransitionRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fromRole: UserRole.fromString(json['from_role'] as String),
      toRole: UserRole.fromString(json['to_role'] as String),
      planCode: json['plan_code'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String,
      adminNotes: json['admin_notes'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      processedAt: json['processed_at'] != null
          ? (json['processed_at'] as Timestamp).toDate()
          : null,
      processedBy: json['processed_by'] as String?,
    );
  }
}

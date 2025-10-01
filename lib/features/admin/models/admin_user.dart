import 'package:flutter/foundation.dart';
import '../../sell/models.dart';
import '../../auth/models/user_role_models.dart';

@immutable
class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;
  final SubscriptionPlan subscription;
  final DateTime joinDate;
  final DateTime lastActive;
  final String location;
  final String industry;
  final List<String> materials;
  final DateTime createdAt;
  final String plan;
  final bool isSeller;
  final SellerProfile? sellerProfile;

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.subscription,
    required this.joinDate,
    required this.lastActive,
    required this.location,
    required this.industry,
    this.materials = const [],
    required this.createdAt,
    required this.plan,
    required this.isSeller,
    this.sellerProfile,
  });

  AdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    UserStatus? status,
    SubscriptionPlan? subscription,
    DateTime? joinDate,
    DateTime? lastActive,
    String? location,
    String? industry,
    List<String>? materials,
    DateTime? createdAt,
    String? plan,
    bool? isSeller,
    SellerProfile? sellerProfile,
  }) {
    return AdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      subscription: subscription ?? this.subscription,
      joinDate: joinDate ?? this.joinDate,
      lastActive: lastActive ?? this.lastActive,
      location: location ?? this.location,
      industry: industry ?? this.industry,
      materials: materials ?? this.materials,
      createdAt: createdAt ?? this.createdAt,
      plan: plan ?? this.plan,
      isSeller: isSeller ?? this.isSeller,
      sellerProfile: sellerProfile ?? this.sellerProfile,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role.toString().split('.').last,
        'status': status.toString().split('.').last,
        'subscription': subscription.toString().split('.').last,
        'join_date': joinDate.toIso8601String(),
        'last_active': lastActive.toIso8601String(),
        'location': location,
        'industry': industry,
        'materials': materials,
        'created_at': createdAt.toIso8601String(),
        'plan': plan,
        'is_seller': isSeller,
        'seller_profile': sellerProfile?.toJson(),
      };

  factory AdminUser.fromJson(Map<String, dynamic> json) => AdminUser(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        role: UserRole.values
            .firstWhere((r) => r.toString().split('.').last == json['role']),
        status: UserStatus.values
            .firstWhere((s) => s.toString().split('.').last == json['status']),
        subscription: SubscriptionPlan.values.firstWhere(
            (s) => s.toString().split('.').last == json['subscription']),
        joinDate: DateTime.parse(json['join_date'] as String),
        lastActive: DateTime.parse(json['last_active'] as String),
        location: json['location'] as String,
        industry: json['industry'] as String,
        materials: List<String>.from(json['materials'] ?? []),
        createdAt: DateTime.parse(json['created_at'] as String),
        plan: json['plan'] as String,
        isSeller: json['is_seller'] as bool,
        sellerProfile: json['seller_profile'] != null
            ? SellerProfile.fromJson(json['seller_profile'])
            : null,
      );
}

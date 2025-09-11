import 'package:flutter/foundation.dart';

enum UserRole { buyer, seller, admin }
enum UserStatus { active, inactive, suspended, pending }
enum SubscriptionPlan { free, basic, premium, enterprise }

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
    );
  }
}

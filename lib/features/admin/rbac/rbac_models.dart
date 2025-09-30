import 'package:flutter/foundation.dart';

@immutable
class Role {
  final String name;
  final String description;
  final List<String> inheritedRoles; // optional inheritance

  const Role({
    required this.name,
    this.description = '',
    this.inheritedRoles = const <String>[],
  });
}

@immutable
class UserOverride {
  final String userId;
  final Set<String> grants; // extra permissions
  final Set<String> revokes; // removed from role
  final DateTime? expiresAt; // temporary permissions

  const UserOverride({
    required this.userId,
    this.grants = const <String>{},
    this.revokes = const <String>{},
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

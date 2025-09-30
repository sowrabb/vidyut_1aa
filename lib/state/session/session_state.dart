import 'package:firebase_auth/firebase_auth.dart';

import '../../features/auth/models/user_role_models.dart';

class SessionState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? userId;
  final String? email;
  final String? displayName;
  final bool isGuest;
  final bool isEmailVerified;
  final UserRole role;
  final AppUser? profile;
  final User? authUser;

  const SessionState({
    required this.isAuthenticated,
    required this.isLoading,
    this.error,
    this.userId,
    this.email,
    this.displayName,
    this.isGuest = false,
    this.isEmailVerified = false,
    this.role = UserRole.guest,
    this.profile,
    this.authUser,
  });

  factory SessionState.initial() => const SessionState(
        isAuthenticated: false,
        isLoading: false,
        role: UserRole.guest,
      );

  bool get isSeller =>
      role == UserRole.seller || (profile?.isActiveSeller ?? false);
  bool get isAdmin => role == UserRole.admin;
  bool get canBecomeSeller => profile?.canBecomeSeller ?? false;

  SessionState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? userId,
    String? email,
    String? displayName,
    bool? isGuest,
    bool? isEmailVerified,
    UserRole? role,
    AppUser? profile,
    User? authUser,
  }) {
    return SessionState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      isGuest: isGuest ?? this.isGuest,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      profile: profile ?? this.profile,
      authUser: authUser ?? this.authUser,
    );
  }
}

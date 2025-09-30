import 'package:firebase_auth/firebase_auth.dart';

enum AuthFlowStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final User? user;
  final AuthFlowStatus status;
  final bool isLoading;
  final String? message;

  const AuthState({
    required this.user,
    required this.status,
    this.isLoading = false,
    this.message,
  });

  factory AuthState.initial() =>
      const AuthState(user: null, status: AuthFlowStatus.unknown);

  bool get isAuthenticated => status == AuthFlowStatus.authenticated;
  bool get isGuest => user?.isAnonymous ?? false;
  bool get isEmailVerified => user?.emailVerified ?? false;
  String? get email => user?.email;
  String? get displayName => user?.displayName;
  String? get phoneNumber => user?.phoneNumber;
  String? get uid => user?.uid;

  AuthState copyWith({
    User? user,
    AuthFlowStatus? status,
    bool? isLoading,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

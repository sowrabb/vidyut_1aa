import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/models/user_role_models.dart';
import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../core/repository_providers.dart';
import 'session_state.dart';

final sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>(SessionController.new);

class SessionController extends StateNotifier<SessionState> {
  SessionController(this._ref) : super(SessionState.initial()) {
    _ref.listen<AuthState>(authControllerProvider, (previous, next) async {
      await _syncWithAuthState(next);
    });
    _syncWithAuthState(_ref.read(authControllerProvider));
  }

  final Ref _ref;

  Future<void> refresh() async {
    final auth = _ref.read(authControllerProvider);
    if (auth.user != null) {
      await _loadUserProfile(auth.user!);
    }
  }

  Future<void> _syncWithAuthState(AuthState authState) async {
    if (!authState.isAuthenticated || authState.user == null) {
      state = SessionState.initial();
      return;
    }

    final firebaseUser = authState.user!;
    state = state.copyWith(
      isAuthenticated: true,
      isLoading: true,
      clearError: true,
      authUser: firebaseUser,
      userId: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: firebaseUser.displayName,
      isEmailVerified: firebaseUser.emailVerified,
      isGuest: firebaseUser.isAnonymous,
      role: _inferRoleFromAuth(firebaseUser),
    );

    await _loadUserProfile(firebaseUser);
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    try {
      final roleService = _ref.read(userRoleServiceProvider);
      await roleService.initializeUser(firebaseUser.uid);
      final appUser = roleService.currentUser;

      if (appUser != null) {
        state = state.copyWith(
          profile: appUser,
          role: appUser.role,
          isEmailVerified: firebaseUser.emailVerified || appUser.isEmailVerified,
          isLoading: false,
          clearError: true,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user profile: ${e.toString()}',
      );
    }
  }

  UserRole _inferRoleFromAuth(User user) {
    if (user.email?.endsWith('@admin.vidyut.com') == true) {
      return UserRole.admin;
    }
    if (user.displayName?.toLowerCase().contains('seller') == true) {
      return UserRole.seller;
    }
    if (user.isAnonymous) {
      return UserRole.guest;
    }
    return UserRole.buyer;
  }
}

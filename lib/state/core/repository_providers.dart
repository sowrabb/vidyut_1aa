import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/cloud_functions_service.dart';
import '../../services/firestore_repository_service.dart';
import '../../services/notification_service.dart';
import '../../services/user_profile_service.dart';
import '../../services/user_role_service.dart';
import 'firebase_providers.dart';

/// High-level repositories exposing backend interactions. These providers
/// centralise dependency injection and make it trivial to override Firebase in
/// tests or preview builds.
final firestoreRepositoryServiceProvider =
    Provider<FirestoreRepositoryService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return FirestoreRepositoryService(firestore: firestore, auth: auth);
});

final cloudFunctionsServiceProvider = Provider<CloudFunctionsService>((ref) {
  final functions = ref.watch(firebaseFunctionsProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return CloudFunctionsService(functions: functions, auth: auth);
});

final userRoleServiceProvider =
    ChangeNotifierProvider<UserRoleService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return UserRoleService(firestore: firestore);
});

final userProfileServiceProvider =
    ChangeNotifierProvider<UserProfileService>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final storage = ref.watch(firebaseStorageProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return UserProfileService(
    firestore: firestore,
    storage: storage,
    auth: auth,
  );
});

final notificationServiceProvider =
    StateNotifierProvider<NotificationService, NotificationState>((ref) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  final auth = ref.watch(firebaseAuthProvider);
  return NotificationService(firestore: firestore, auth: auth);
});

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationServiceProvider).unreadCount;
});

final recentNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider.notifier);
  return service.recentNotifications;
});

final unreadNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final service = ref.watch(notificationServiceProvider.notifier);
  return service.unreadNotifications;
});

final notificationsByTypeProvider =
    Provider.family<List<AppNotification>, String>((ref, type) {
  final service = ref.watch(notificationServiceProvider.notifier);
  return service.getNotificationsByType(type);
});

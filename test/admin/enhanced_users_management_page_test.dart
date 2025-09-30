import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vidyut/features/admin/models/admin_user.dart';
import 'package:vidyut/features/admin/pages/enhanced_users_management_page.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('filters users by search query', (WidgetTester tester) async {
    final demoService = LightweightDemoDataService();
    await demoService.initializationFuture;

    final store = EnhancedAdminStore(
      apiService:
          EnhancedAdminApiService(environment: ApiEnvironment.development),
      demoDataService: demoService,
      useBackend: false,
    );

    addTearDown(store.dispose);

    await store.refreshUsers();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          enhancedAdminStoreProvider.overrideWith((ref) => store),
        ],
        child: MaterialApp(
          home: EnhancedUsersManagementPage(adminStore: store),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Admin User'), findsOneWidget);
    expect(find.text('Moderator User'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Moderator');
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Moderator User'), findsOneWidget);
    expect(find.text('Admin User'), findsNothing);
  });

  testWidgets('bulk suspend updates selected users',
      (WidgetTester tester) async {
    final demoService = LightweightDemoDataService();
    await demoService.initializationFuture;

    final store = EnhancedAdminStore(
      apiService:
          EnhancedAdminApiService(environment: ApiEnvironment.development),
      demoDataService: demoService,
      useBackend: false,
    );

    addTearDown(store.dispose);

    await store.refreshUsers();

    final targetUserId = store.users.first.id;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          enhancedAdminStoreProvider.overrideWith((ref) => store),
        ],
        child: MaterialApp(
          home: EnhancedUsersManagementPage(adminStore: store),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(store.selectedUserIds, contains(targetUserId));

    await tester.tap(find.widgetWithText(FilledButton, 'Suspend'));
    await tester.pump();
    await tester.pumpAndSettle();

    final updatedUser =
        store.users.firstWhere((user) => user.id == targetUserId);
    expect(updatedUser.status, UserStatus.suspended);
    expect(find.textContaining('Bulk update completed'), findsOneWidget);
  });
}

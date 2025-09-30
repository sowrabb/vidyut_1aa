import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vidyut/features/admin/admin_shell.dart';
import 'package:vidyut/features/admin/auth/admin_auth_service.dart';
import 'package:vidyut/features/admin/store/admin_store.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/app/provider_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AdminShell golden snapshot', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final demoService = LightweightDemoDataService();
    await demoService.initializationFuture;

    final enhancedStore = EnhancedAdminStore(
      apiService:
          EnhancedAdminApiService(environment: ApiEnvironment.development),
      demoDataService: demoService,
      useBackend: false,
    );
    final adminStore = AdminStore(demoService);
    final authService = AdminAuthService(enhancedStore, demoService);

    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.physicalSizeTestValue = const Size(1440, 900);

    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          demoDataServiceProvider.overrideWith((ref) => demoService),
          enhancedAdminStoreProvider.overrideWith((ref) => enhancedStore),
          adminStoreProvider.overrideWith((ref) => adminStore),
          adminAuthServiceProvider.overrideWith((ref) => authService),
        ],
        child: const MaterialApp(home: AdminShell()),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AdminShell),
      matchesGoldenFile('goldens/admin_shell_default.png'),
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';
import 'package:vidyut/features/admin/models/admin_user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Seller approve/suspend updates status and logs (demo)', () async {
    final demo = LightweightDemoDataService();
    await demo.initializationFuture;

    final store = EnhancedAdminStore(
      apiService: EnhancedAdminApiService(),
      demoDataService: demo,
      useBackend: false,
    );
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final pending = store.sellers.firstWhere(
        (u) => u.status == UserStatus.pending,
        orElse: () => store.sellers.first);
    await store.approveSeller(pending.id, comments: 'go');
    final updated = store.sellers.firstWhere((u) => u.id == pending.id);
    expect(updated.status, UserStatus.active);
    expect(
        store.sellerAuditLogs.any(
            (e) => e['sellerId'] == pending.id && e['action'] == 'approve'),
        true);

    await store.suspendSeller(updated.id, reason: 'test');
    final updated2 = store.sellers.firstWhere((u) => u.id == updated.id);
    expect(updated2.status, UserStatus.suspended);
    expect(
        store.sellerAuditLogs.any(
            (e) => e['sellerId'] == updated.id && e['action'] == 'suspend'),
        true);
  });
}

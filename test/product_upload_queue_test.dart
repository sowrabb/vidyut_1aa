import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';
import 'package:vidyut/services/enhanced_admin_api_service.dart';
import 'package:vidyut/features/admin/store/enhanced_admin_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Approve/reject upload mutates queue and products (demo)', () async {
    final demo = LightweightDemoDataService();
    await demo.initializationFuture;

    final store = EnhancedAdminStore(
      apiService: EnhancedAdminApiService(),
      demoDataService: demo,
      useBackend: false,
    );

    // Wait a tick for store init
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final initialQueue = store.productUploadQueue.length;
    expect(initialQueue > 0, true);
    final initialProducts = store.products.length;

    final firstId = store.productUploadQueue.first.id;
    await store.approveProductUpload(firstId, comments: 'ok');

    expect(store.productUploadQueue.length, initialQueue - 1);
    expect(store.productUploadHistory.any((e) => e.id == firstId), true);
    expect(store.products.length, initialProducts + 1);

    // Reject another if present
    if (store.productUploadQueue.isNotEmpty) {
      final rejectId = store.productUploadQueue.first.id;
      await store.rejectProductUpload(rejectId, reason: 'bad');
      expect(store.productUploadHistory.any((e) => e.id == rejectId), true);
    }
  });
}

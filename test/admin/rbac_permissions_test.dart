import 'package:flutter_test/flutter_test.dart';
import 'package:vidyut/services/lightweight_demo_data_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Demo RBAC roles can be mutated offline', () async {
    final demo = LightweightDemoDataService();
    await demo.initializationFuture;

    expect(demo.rolePermissions.containsKey('admin'), isTrue);
    expect(demo.roleHasPermission('admin', 'users.read'), isTrue);

    final created = demo.createRole('qa', permissions: {'tests.run'});
    expect(created, isTrue);
    expect(demo.rolePermissions['qa'], contains('tests.run'));

    demo.grantPermissionToRole('qa', 'tests.report');
    expect(demo.rolePermissions['qa'], contains('tests.report'));

    demo.revokePermissionFromRole('qa', 'tests.run');
    expect(demo.rolePermissions['qa'], isNot(contains('tests.run')));

    final removed = demo.removeRole('qa');
    expect(removed, isTrue);
    expect(demo.rolePermissions.containsKey('qa'), isFalse);
  });
}

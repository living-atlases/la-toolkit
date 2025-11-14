import 'package:la_toolkit/models/la_server.dart';

import 'package:test/test.dart';

void main() {
  test('Server creation', () {
    final LAServer vm1 =
        LAServer(name: 'vm1', gateways: <String>['vm2', 'vm3'], projectId: '1');
    final LAServer vm1b = LAServer(
        id: vm1.id, name: 'vm1', gateways: <String>['vm2', 'vm3'], projectId: '1');
    expect(vm1 == vm1b, equals(true));
    final LAServer vmPersisted = LAServer.fromJson(vm1.toJson());
    expect(vm1 == vmPersisted, equals(true));
  });
}

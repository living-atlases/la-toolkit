import 'package:la_toolkit/models/laServer.dart';
import 'package:test/test.dart';

void main() {
  test('Server creation', () {
    LAServer vm1 =
        LAServer(name: "vm1", gateways: ["vm2", "vm3"], projectId: "1");
    LAServer vm1b = LAServer(
        id: vm1.id, name: "vm1", gateways: ["vm2", "vm3"], projectId: "1");
    expect(vm1 == vm1b, equals(true));
    LAServer vmPersisted = LAServer.fromJson(vm1.toJson());
    expect(vm1 == vmPersisted, equals(true));
  });
}

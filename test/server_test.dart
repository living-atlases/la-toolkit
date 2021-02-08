import 'package:la_toolkit/models/laServer.dart';
import 'package:test/test.dart';

void main() {
  test('Server creation', () {
    LAServer vm1 = LAServer(name: "vm1", gateways: ["vm2", "vm3"]);
    LAServer vm1b = LAServer(name: "vm1", gateways: ["vm2", "vm3"]);
    expect(vm1 == vm1b, equals(true));
    LAServer vmPersisted = LAServer.fromJson(vm1.toJson());
    expect(vm1 == vmPersisted, equals(true));
  });
}

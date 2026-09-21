import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:objectid/objectid.dart';

/// What the toolkit POSTs/PATCHes for a project. toGeneratorJson() is what
/// materialises the defaulted variables onto the project, so it has to run
/// before toJson(): otherwise a freshly created project is persisted without
/// its defaults and they are re-created, with new ids, on the next save.
void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    dotenv.testLoad(
      fileInput: 'DEMO=false\nBACKEND=localhost:1337\nHTTPS=false',
    );
  });

  LAProject minimalPortal() {
    final LAProject p = LAProject(
      longName: 'Portal',
      shortName: 'portal',
      domain: 'l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
    );
    final LAServer server = LAServer(
      id: ObjectId().toString(),
      name: 'vm-1',
      ip: '10.0.0.1',
      projectId: p.id,
    );
    p.upsertServer(server);
    p.assign(server, <String>['collectory']);
    return p;
  }

  test('a freshly created project carries its defaulted variables', () {
    final LAProject p = minimalPortal();
    expect(p.variables, isEmpty, reason: 'nothing materialised yet');

    final Map<String, dynamic> body = Api.projectJsonWithGenConf(p);

    final List<dynamic> sent = body['variables'] as List<dynamic>;
    expect(sent, isNotEmpty);
    expect(sent, hasLength(p.variables.length),
        reason: 'the body is what the object now holds, not a stale snapshot');
    expect(body['genConf'], isA<Map<String, dynamic>>());
    expect(body['parent'], isNull);
  });

  test('the same ids are sent on the next save', () {
    final LAProject p = minimalPortal();
    final List<dynamic> first = Api.projectJsonWithGenConf(p)['variables'] as List<dynamic>;
    final List<dynamic> second = Api.projectJsonWithGenConf(p)['variables'] as List<dynamic>;
    List<String> ids(List<dynamic> l) =>
        l.map((dynamic v) => (v as Map<String, dynamic>)['id'] as String).toList()..sort();
    expect(ids(second), equals(ids(first)));
  });
}

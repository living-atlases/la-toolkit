import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/app_state.dart';
import 'package:la_toolkit/redux/app_actions.dart';
import 'package:la_toolkit/redux/app_state_middleware.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:redux/redux.dart';

import 'pump_app.dart';

/// The backend-less demo published at toolkit-demo.l-a.site (deploy-demo.sh).
void main() {
  group('demo env files', () {
    Map<String, String> envOf(String path) {
      final DotEnv env = DotEnv();
      env.testLoad(fileInput: File(path).readAsStringSync());
      return env.env;
    }

    test('deploy-demo.sh ships an env with DEMO=true', () {
      final String script = File('deploy-demo.sh').readAsStringSync();
      const String demoEnv = 'assets/env.production-demo.txt';
      expect(script, contains(demoEnv),
          reason: 'the script must copy a file that exists');
      expect(envOf(demoEnv)['DEMO'], 'true');
    });

    test('the bundled envs are not demo ones', () {
      for (final String path in <String>[
        'env.production.txt',
        'env.development.txt',
        'assets/env.production.txt',
        'assets/env.development.txt',
      ]) {
        expect(envOf(path)['DEMO'], isNot('true'), reason: path);
      }
    });
  });

  test('isDemo follows DEMO', () {
    dotenv.testLoad(fileInput: 'DEMO=false\nBACKEND=localhost:1337');
    expect(AppUtils.isDemo(), isFalse);
    dotenv.testLoad(fileInput: 'DEMO=true\nBACKEND=localhost:1337');
    expect(AppUtils.isDemo(), isTrue);
  });

  group('in demo mode', () {
    setUp(setUpDemoEnv);

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('updating a project returns it without a backend', () async {
      final LAProject p = LAProject(longName: 'Demo', shortName: 'demo');
      final List<dynamic> res = await Api.updateProject(project: p);
      expect(res, hasLength(1));
      expect((res.first as Map<String, dynamic>)['id'], p.id);
    });

    test('an edited project is saved in the store', () async {
      final Store<AppState> store = demoStore();
      final LAProject p = LAProject(
        longName: 'Demo portal',
        shortName: 'demo',
        domain: 'demo.org',
      );
      store.dispatch(OnDemoAddProjects(<LAProject>[p]));
      await settle();
      expect(store.state.projects.map((LAProject e) => e.id), contains(p.id));

      final LAProject edited = LAProject.fromJson(p.toJson())
        ..longName = 'Demo portal renamed';
      store.dispatch(UpdateProject(edited));
      await settle();

      expect(store.state.appSnackBarMessages, isEmpty);
      expect(
        store.state.projects.firstWhere((LAProject e) => e.id == p.id).longName,
        'Demo portal renamed',
      );
      expect(store.state.loading, isFalse);
    });
  });

  test('generator versions come from the GitHub tags', () {
    expect(
      demoGeneratorReleasesFromTags(<dynamic>[
        <String, dynamic>{'name': 'v1.9.11'},
        <String, dynamic>{'name': '1.9.10'},
        <String, dynamic>{'name': 'some-branch-tag'},
      ]),
      <String>['1.9.11', '1.9.10'],
    );
    expect(demoGeneratorReleasesFallback, isNotEmpty);
  });
}

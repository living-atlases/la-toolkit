import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_server.dart';
import 'package:objectid/objectid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Hub Generator JSON Inheritance Tests', () {
    test(
      'Hub should inherit service path variables from parent when not overridden',
      () {
        // Create parent project
        final LAProject parent = LAProject(
          longName: 'Parent Project',
          shortName: 'parent',
          domain: 'parent.org',
          alaInstallRelease: '1.0.0',
          generatorRelease: '1.0.0',
        );

        // Add a server to parent
        final LAServer parentServer = LAServer(
          id: ObjectId().toString(),
          name: 'parent-server',
          ip: '192.168.1.1',
          projectId: parent.id,
        );
        parent.upsertServer(parentServer);

        // Configure parent services
        parent.serviceInUse('collectory', true);
        parent.serviceInUse('ala_hub', true);
        parent.serviceInUse('biocache_service', true);

        parent.assign(parentServer, const <String>[
          'collectory',
          'ala_hub',
          'biocache_service',
        ]);

        // Set paths for parent services via iniPath
        parent.getService('collectory').iniPath = '/';
        parent.getService('ala_hub').iniPath = '/';
        parent.getService('biocache_service').iniPath = '/ws';

        // Generate parent JSON
        final Map<String, dynamic> parentJson = parent.toGeneratorJson();

        // Verify parent has the path variables
        expect(parentJson['LA_collectory_path'], equals('/'));
        expect(parentJson['LA_ala_hub_path'], equals('/'));
        expect(parentJson['LA_biocache_service_path'], equals('/ws'));

        // Create hub as child of parent
        final LAProject hub = LAProject(
          longName: 'Hub Project',
          shortName: 'hub',
          domain: 'hub.parent.org',
          alaInstallRelease: '1.0.0',
          generatorRelease: '1.0.0',
          isHub: true,
          parent: parent,
        );

        // Add a server to hub
        final LAServer hubServer = LAServer(
          id: ObjectId().toString(),
          name: 'hub-server',
          ip: '192.168.1.2',
          projectId: hub.id,
        );
        hub.upsertServer(hubServer);

        // Hub only uses ala_hub service (not collectory or biocache_service)
        hub.serviceInUse('ala_hub', true);
        hub.assign(hubServer, const <String>['ala_hub']);
        hub.getService('ala_hub').iniPath = '/hub';

        // Generate hub JSON
        final Map<String, dynamic> hubJson = hub.toGeneratorJson();

        // CRITICAL: Hub should inherit parent's collectory_path and biocache_service_path
        expect(
          hubJson['LA_collectory_path'],
          equals('/'),
          reason:
              'Hub should inherit LA_collectory_path from parent since it does not define collectory',
        );

        expect(
          hubJson['LA_biocache_service_path'],
          equals('/ws'),
          reason:
              'Hub should inherit LA_biocache_service_path from parent since it does not define biocache_service',
        );

        // Hub should override ala_hub_path with its own value
        expect(
          hubJson['LA_ala_hub_path'],
          equals('/hub'),
          reason: 'Hub should use its own LA_ala_hub_path value',
        );

        // Hub should also inherit URL variables
        expect(
          hubJson['LA_collectory_url'],
          isNotNull,
          reason: 'Hub should inherit LA_collectory_url from parent',
        );

        expect(
          hubJson['LA_biocache_service_url'],
          isNotNull,
          reason: 'Hub should inherit LA_biocache_service_url from parent',
        );
      },
    );

    test('Hub should inherit all service variables from parent', () {
      // Create parent with more services
      final LAProject parent = LAProject(
        longName: 'Full Parent',
        shortName: 'fullparent',
        domain: 'full.org',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      final LAServer parentServer = LAServer(
        id: ObjectId().toString(),
        name: 's1',
        ip: '10.0.0.1',
        projectId: parent.id,
      );
      parent.upsertServer(parentServer);

      // Enable many services in parent
      final List<String> parentServices = <String>[
        'collectory',
        'ala_hub',
        'biocache_service',
        'ala_bie',
        'bie_index',
        'images',
        'logger',
        'cas',
      ];

      for (final String service in parentServices) {
        parent.serviceInUse(service, true);
      }

      parent.assign(parentServer, parentServices);

      // Generate parent JSON
      final Map<String, dynamic> parentJson = parent.toGeneratorJson();

      // Create minimal hub
      final LAProject hub = LAProject(
        longName: 'Minimal Hub',
        shortName: 'minhub',
        domain: 'min.full.org',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
        isHub: true,
        parent: parent,
      );

      final LAServer hubServer = LAServer(
        id: ObjectId().toString(),
        name: 'h1',
        ip: '10.0.0.2',
        projectId: hub.id,
      );
      hub.upsertServer(hubServer);

      // Hub only uses ala_hub
      hub.serviceInUse('ala_hub', true);
      hub.assign(hubServer, const <String>['ala_hub']);

      // Generate hub JSON
      final Map<String, dynamic> hubJson = hub.toGeneratorJson();

      // Hub should have inherited all the path variables from parent
      for (final String service in parentServices) {
        final String pathKey = 'LA_${service}_path';
        expect(
          hubJson.containsKey(pathKey),
          isTrue,
          reason: 'Hub should have $pathKey inherited from parent',
        );
        expect(
          hubJson[pathKey],
          equals(parentJson[pathKey]),
          reason: '$pathKey should match parent value',
        );
      }

      // Hub should also have inherited URL and hostname variables
      expect(
        hubJson['LA_collectory_url'],
        equals(parentJson['LA_collectory_url']),
      );
      expect(hubJson['LA_logger_url'], equals(parentJson['LA_logger_url']));
    });

    test('Hub should inherit LA_use_* flags from parent', () {
      // Create parent with CAS enabled
      final LAProject parent = LAProject(
        longName: 'Parent with CAS',
        shortName: 'parentcas',
        domain: 'parent.org',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
      );

      final LAServer parentServer = LAServer(
        id: ObjectId().toString(),
        name: 's1',
        ip: '10.0.0.1',
        projectId: parent.id,
      );
      parent.upsertServer(parentServer);

      // Enable CAS in parent
      parent.serviceInUse('cas', true);
      parent.serviceInUse('collectory', true);
      parent.serviceInUse('ala_hub', true);

      parent.assign(parentServer, const <String>[
        'cas',
        'collectory',
        'ala_hub',
      ]);

      // Configure CAS paths
      parent.getService('cas').iniPath = '/';

      // Generate parent JSON
      final Map<String, dynamic> parentJson = parent.toGeneratorJson();

      // Verify parent has LA_use_CAS
      expect(parentJson['LA_use_CAS'], isTrue);
      expect(parentJson['LA_cas_path'], equals('/'));

      // Create hub that doesn't use CAS
      final LAProject hub = LAProject(
        longName: 'Hub Project',
        shortName: 'hub',
        domain: 'hub.parent.org',
        alaInstallRelease: '1.0.0',
        generatorRelease: '1.0.0',
        isHub: true,
        parent: parent,
      );

      final LAServer hubServer = LAServer(
        id: ObjectId().toString(),
        name: 'h1',
        ip: '10.0.0.2',
        projectId: hub.id,
      );
      hub.upsertServer(hubServer);

      // Hub only uses ala_hub (not CAS)
      hub.serviceInUse('ala_hub', true);
      hub.assign(hubServer, const <String>['ala_hub']);

      // Generate hub JSON
      final Map<String, dynamic> hubJson = hub.toGeneratorJson();

      // CRITICAL: Hub should inherit LA_use_CAS from parent
      expect(
        hubJson['LA_use_CAS'],
        equals(true),
        reason:
            'Hub should inherit LA_use_CAS from parent since it does not define CAS itself',
      );

      // Hub should also inherit CAS path variables
      expect(
        hubJson['LA_cas_path'],
        equals('/'),
        reason: 'Hub should inherit LA_cas_path from parent',
      );

      expect(
        hubJson['LA_cas_url'],
        isNotNull,
        reason: 'Hub should inherit LA_cas_url from parent',
      );
    });
    test(
      'Hub should inherit variables for services disabled in parent (use=false)',
      () {
        // This tests the real-world case where parent has biocache_backend
        // with use=false, but the template still needs LA_biocache_backend_hostname.
        // The parent generates hostname/url/path for ALL services (disabled or not).
        // The hub must inherit those variables too.
        final LAProject parent = LAProject(
          longName: 'Parent Project',
          shortName: 'parent',
          domain: 'parent.org',
          alaInstallRelease: '1.0.0',
          generatorRelease: '1.0.0',
        );

        final LAServer parentServer = LAServer(
          id: ObjectId().toString(),
          name: 'parent-server',
          ip: '192.168.1.1',
          projectId: parent.id,
        );
        parent.upsertServer(parentServer);

        // Enable ala_hub and collectory, but leave biocache_backend disabled
        parent.serviceInUse('ala_hub', true);
        parent.serviceInUse('collectory', true);
        parent.serviceInUse('biocache_backend', false); // explicitly disabled

        parent.assign(parentServer, const <String>['ala_hub', 'collectory']);

        // Verify parent conf contains biocache_backend_hostname even when use=false
        final Map<String, dynamic> parentJson = parent.toGeneratorJson();
        expect(
          parentJson.containsKey('LA_biocache_backend_hostname'),
          isTrue,
          reason:
              'Parent generates LA_biocache_backend_hostname for all services regardless of use',
        );

        // Create hub
        final LAProject hub = LAProject(
          longName: 'Hub Project',
          shortName: 'hub',
          domain: 'hub.parent.org',
          alaInstallRelease: '1.0.0',
          generatorRelease: '1.0.0',
          isHub: true,
          parent: parent,
        );

        final LAServer hubServer = LAServer(
          id: ObjectId().toString(),
          name: 'hub-server',
          ip: '192.168.1.2',
          projectId: hub.id,
        );
        hub.upsertServer(hubServer);
        hub.serviceInUse('ala_hub', true);
        hub.assign(hubServer, const <String>['ala_hub']);

        final Map<String, dynamic> hubJson = hub.toGeneratorJson();

        // Hub must inherit LA_biocache_backend_hostname even though parent has use=false
        expect(
          hubJson.containsKey('LA_biocache_backend_hostname'),
          isTrue,
          reason:
              'Hub should inherit LA_biocache_backend_hostname from parent even when parent use=false',
        );
      },
    );
  });
}

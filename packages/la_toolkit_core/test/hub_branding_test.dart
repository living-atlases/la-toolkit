import 'package:la_toolkit_core/models/deployment_type.dart';
import 'package:la_toolkit_core/models/la_cluster.dart';
import 'package:la_toolkit_core/models/la_project.dart';
import 'package:la_toolkit_core/models/la_server.dart';
import 'package:la_toolkit_core/models/la_service_desc.dart';
import 'package:la_toolkit_core/models/la_variable_desc.dart';
import 'package:objectid/objectid.dart';
import 'package:test/test.dart';

/// A data hub is a portal of its own and needs the same branding choice the portal
/// has: a git URL (built into its own image), a local path, or nothing at all,
/// which means "reuse the branding already served at my header_and_footer_baseurl".
void main() {
  LAProject buildComposePortal() {
    final LAProject portal = LAProject(
      longName: 'Portal',
      shortName: 'portal',
      domain: 'l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
    );
    final LAServer server = LAServer(
      id: ObjectId().toString(),
      name: 'la-mh-1',
      ip: '10.0.0.1',
      projectId: portal.id,
    );
    portal.upsertServer(server);
    portal.serviceInUse('docker_compose', true);
    portal.serviceInUse('ala_hub', true);
    portal.serviceInUse('branding', true);
    portal.assign(server, const <String>['docker_compose']);
    portal.assignByType(server.id, DeploymentType.dockerCompose, const <String>[
      'ala_hub',
      'branding',
    ]);
    portal.setVariable(
      LAVariableDesc.map['branding_source']!,
      '../portal-branding',
    );
    return portal;
  }

  LAProject attachHub(LAProject portal, {String? brandingSource}) {
    final LAProject hub = LAProject(
      longName: 'Hub',
      shortName: 'hub',
      domain: 'records-hub.l-a.site',
      alaInstallRelease: '1.0.0',
      generatorRelease: '1.0.0',
      isHub: true,
      parent: portal,
    );
    hub.serviceInUse('ala_hub', true);
    hub.serviceInUse('branding', true);
    hub.serviceInUse('ala_bie', false);
    hub.serviceInUse('regions', false);
    if (brandingSource != null) {
      hub.setVariable(LAVariableDesc.map['branding_source']!, brandingSource);
    }
    portal.hubs.add(hub);
    final LACluster cluster = portal.clusters.firstWhere(
      (LACluster c) => c.type == DeploymentType.dockerCompose,
    );
    hub.assignByType(cluster.id, DeploymentType.dockerCompose, const <String>[
      'ala_hub',
      'branding',
    ]);
    return hub;
  }

  group('hub branding', () {
    test(
      'the branding source is offered on a hub, unlike other compose vars',
      () {
        final LAProject portal = buildComposePortal();
        final LAProject hub = attachHub(portal);

        final LAVariableDesc brandingSource =
            LAVariableDesc.map['branding_source']!;
        // Tune page filter: a variable is dropped on a hub when the service it
        // depends on is not hub-capable. branding is; docker_compose is not.
        expect(
          LAServiceDesc.getE(brandingSource.depends!).hubCapable,
          isTrue,
          reason: 'else the field is invisible on every hub',
        );
        expect(brandingSource.isVisible!(hub), isTrue);
        // branding_as_home stays the portal's business: it claims the root domain.
        expect(
          LAServiceDesc.getE(
            LAVariableDesc.map['branding_as_home']!.depends!,
          ).hubCapable,
          isFalse,
        );
      },
    );

    test('a hub keeps its own branding source instead of the parent one', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(
        portal,
        brandingSource: 'https://github.com/living-atlases/base-branding',
      );

      final Map<String, dynamic> conf = hub.toGeneratorJson();
      expect(
        conf['LA_variable_branding_source'],
        equals('https://github.com/living-atlases/base-branding'),
      );
      expect(conf['LA_variable_branding_build_source'], equals('git'));
      expect(
        conf['LA_variable_branding_source'],
        isNot(equals(portal.toGeneratorJson()['LA_variable_branding_source'])),
      );
    });

    test('an empty branding source means "reuse the one already served"', () {
      final LAProject portal = buildComposePortal();
      final LAProject hub = attachHub(portal, brandingSource: '');

      final Map<String, dynamic> conf = hub.toGeneratorJson();
      // The generator turns a falsy value into la_hubs[].branding_source = null,
      // and la-compose then builds no image and creates no volume for this hub.
      expect(conf['LA_variable_branding_source'], equals(''));
    });

    test(
      'the default points at the hub own branding dir, not the portal one',
      () {
        final LAProject portal = buildComposePortal();
        final LAProject hub = attachHub(portal);

        expect(
          hub.getVariableValue('branding_source'),
          equals('../${hub.dirName}-branding'),
        );
      },
    );

    test(
      'the hub branding source reaches the generator payload of the portal',
      () {
        final LAProject portal = buildComposePortal();
        attachHub(
          portal,
          brandingSource: 'https://github.com/living-atlases/base-branding',
        );

        final List<dynamic> hubs =
            portal.toGeneratorJson()['LA_hubs'] as List<dynamic>;
        expect(hubs, hasLength(1));
        expect(
          (hubs.first as Map<String, dynamic>)['LA_variable_branding_source'],
          equals('https://github.com/living-atlases/base-branding'),
        );
      },
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:la_toolkit/models/la_project.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_name.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Service Dependency Visibility Tests', () {
    late LAProject project;

    setUp(() {
      project = LAProject(
        longName: 'Test Project',
        shortName: 'TP',
        domain: 'test.org',
      );
    });

    test('Gatus/Portainer should be hidden by default (no Docker)', () {
      expect(project.getServiceE(LAServiceName.docker_swarm).use, isFalse);
      expect(project.getServiceE(LAServiceName.docker_compose).use, isFalse);

      expect(
        project.isDependencySatisfied(LAServiceName.docker_swarm),
        isFalse,
      );
    });

    test('Gatus/Portainer should be visible when Docker Swarm is used', () {
      project.serviceInUse(dockerSwarm, true);
      expect(project.getServiceE(LAServiceName.docker_swarm).use, isTrue);

      expect(project.isDependencySatisfied(LAServiceName.docker_swarm), isTrue);
    });

    test('Gatus/Portainer should be visible when Docker Compose is used', () {
      project.serviceInUse(dockerCompose, true);
      expect(project.getServiceE(LAServiceName.docker_compose).use, isTrue);

      // Verification of the semantic alternative
      expect(project.isDependencySatisfied(LAServiceName.docker_swarm), isTrue);
    });

    test(
      'Other dependencies should work as expected (bie_index depends on ala_bie)',
      () {
        project.serviceInUse(bie, false);
        expect(project.isDependencySatisfied(LAServiceName.ala_bie), isFalse);

        project.serviceInUse(bie, true);
        expect(project.isDependencySatisfied(LAServiceName.ala_bie), isTrue);
      },
    );

    test('Hub project should check parent project dependencies', () {
      final LAProject hub = LAProject(isHub: true, parent: project);

      project.serviceInUse(dockerCompose, true);
      expect(hub.isDependencySatisfied(LAServiceName.docker_swarm), isTrue);

      project.serviceInUse(dockerCompose, false);
      expect(hub.isDependencySatisfied(LAServiceName.docker_swarm), isFalse);
    });
  });
}

import 'la_service_constants.dart';

class DockerComposeDependencies {
  static final Map<String, List<String>> _serviceDependencies = {
    // MySQL dependencies
    cas: [mysql],
    collectory: [mysql],
    speciesLists: [mysql],
    logger: [mysql],
    alerts: [mysql],

    // Postgres dependencies
    spatial: [postgres],
    images: [postgres, elasticsearch],
    doi: [postgres, elasticsearch],
    dataQuality: [postgres],

    // Mongo dependencies
    // cas is already listed above for mysql, we need to handle multi-values carefully in the getter
    ecodata: [mongo, elasticsearch],

    // Elasticsearch dependencies - handled in the lists above
    events: [elasticsearch],
  };

  /// Returns a set of implicit services required by the given list of services
  static Set<String> getImplicitServices(List<String> currentServices) {
    final Set<String> implicitServices = {};

    for (final service in currentServices) {
      // Special handling for CAS which needs both MySQL and Mongo
      if (service == cas) {
        implicitServices.add(mysql);
        implicitServices.add(mongo);
      } else if (_serviceDependencies.containsKey(service)) {
        implicitServices.addAll(_serviceDependencies[service]!);
      }
    }

    return implicitServices;
  }

  /// Returns a list of services from [currentServices] that depend on [dbService]
  static List<String> getDependentServices(
    String dbService,
    List<String> currentServices,
  ) {
    final List<String> dependentServices = [];

    for (final service in currentServices) {
      if (service == cas && (dbService == mysql || dbService == mongo)) {
        dependentServices.add(service);
      } else if (_serviceDependencies.containsKey(service)) {
        if (_serviceDependencies[service]!.contains(dbService)) {
          dependentServices.add(service);
        }
      }
    }
    return dependentServices;
  }
}

import 'la_service_constants.dart';

class DockerComposeDependencies {
  static final Map<String, List<String>> _serviceDependencies = <String, List<String>>{
    // MySQL dependencies
    cas: <String>[mysql],
    collectory: <String>[mysql],
    speciesLists: <String>[mysql],
    logger: <String>[mysql],
    alerts: <String>[mysql],

    // Postgres dependencies
    spatial: <String>[postgres],
    images: <String>[postgres, elasticsearch],
    doi: <String>[postgres, elasticsearch],
    dataQuality: <String>[postgres],

    // Mongo dependencies
    // cas is already listed above for mysql, we need to handle multi-values carefully in the getter
    ecodata: <String>[mongo, elasticsearch],

    // Elasticsearch dependencies - handled in the lists above
    events: <String>[elasticsearch],
  };

  /// Returns a set of implicit services required by the given list of services
  static Set<String> getImplicitServices(List<String> currentServices) {
    final Set<String> implicitServices = <String>{};

    for (final String service in currentServices) {
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
    final List<String> dependentServices = <String>[];

    for (final String service in currentServices) {
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

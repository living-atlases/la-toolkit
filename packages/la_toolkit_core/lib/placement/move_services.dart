// Moving services of an existing project to other servers, the way the
// servers page of the app does it: unassign from the old card, assign on the
// new one (LAProject.unAssignByType / assignByType), creating a compose
// cluster only as the app does (ticking docker_compose on the server). What
// this adds is the checks the UI does by only offering valid chips, turned
// into refusals, plus keeping the moved services' versions.
import 'package:collection/collection.dart';

import '../models/deployment_type.dart';
import '../models/la_cluster.dart';
import '../models/la_project.dart';
import '../models/la_releases.dart';
import '../models/la_server.dart';
import '../models/la_service.dart';
import '../models/la_service_constants.dart';
import '../models/la_service_deploy.dart';
import '../models/la_service_desc.dart';
import '../models/la_service_name.dart';

/// Where a service runs on a server: straight on it, or on the docker-compose
/// cluster it carries.
enum PlacementLeg { vm, docker }

/// A move refused. The message says why and what to pass instead.
class PlacementException implements Exception {
  PlacementException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One service to move to server [to]. [from] (a server name) is needed when
/// the service runs in more than one place; the legs only when a server could
/// mean either (a compose host that also runs VM services).
class ServiceMove {
  const ServiceMove({
    required this.service,
    required this.to,
    this.from,
    this.fromLeg,
    this.toLeg,
  });

  final String service;
  final String to;
  final String? from;
  final PlacementLeg? fromLeg;
  final PlacementLeg? toLeg;
}

/// A server, and on which leg of it.
class PlacementSlot {
  const PlacementSlot(this.server, this.leg, [this.cluster]);

  final LAServer server;
  final PlacementLeg leg;

  /// The compose cluster [server] carries, for [PlacementLeg.docker].
  final LACluster? cluster;

  String get id => cluster?.id ?? server.id;
  DeploymentType get type =>
      leg == PlacementLeg.vm ? DeploymentType.vm : DeploymentType.dockerCompose;

  @override
  String toString() =>
      leg == PlacementLeg.vm ? server.name : '${server.name} (docker-compose)';
}

/// What [moveServices] did for one move.
class MovedService {
  MovedService({
    required this.service,
    required this.carried,
    required this.from,
    required this.to,
    required this.versions,
  });

  final String service;

  /// The sub-services that went along (spatial takes spatial_service and
  /// geoserver).
  final List<String> carried;

  /// Null when the service was in use but assigned nowhere.
  final PlacementSlot? from;
  final PlacementSlot to;

  /// Software versions of the moved rows, kept from the source.
  final Map<String, String> versions;
}

class PlacementChange {
  PlacementChange(this.moves, this.clustersCreated);

  final List<MovedService> moves;

  /// Servers that got a docker-compose cluster for this change.
  final List<String> clustersCreated;
}

/// Services that say where things run rather than being a workload.
final Set<String> _infraServices = <String>{
  dockerCompose,
  dockerSwarm,
  dockerCommon,
};

/// The service [nameOrAlias] names: its internal name, or, when it points to
/// exactly one service, its inventory group or artifact (`spatial-hub`).
String resolveServiceName(String nameOrAlias) {
  if (LAServiceDesc.isLAService(nameOrAlias)) {
    return nameOrAlias;
  }
  final Set<String> hits = <String>{
    for (final LAServiceDesc d in LAServiceDesc.list(false))
      if (d.group == nameOrAlias || d.artifacts == nameOrAlias) d.nameInt,
  };
  if (hits.length == 1) {
    return hits.single;
  }
  throw PlacementException(
    hits.isEmpty
        ? 'No service "$nameOrAlias".'
        : '"$nameOrAlias" could be ${hits.join(', ')}: use one of those names.',
  );
}

/// Every place [nameInt] runs in [p]: its servers, and the compose clusters
/// it is placed on (a hub's are the portal's), by the server carrying them.
List<PlacementSlot> serviceLocations(LAProject p, String nameInt) {
  final List<PlacementSlot> slots = <PlacementSlot>[];
  for (final LAServer s in p.servers) {
    if (p.getServerServices(serverId: s.id).contains(nameInt)) {
      slots.add(PlacementSlot(s, PlacementLeg.vm));
    }
  }
  for (final LACluster c in p.placement.clusters) {
    if (!p.getClusterServices(clusterId: c.id).contains(nameInt)) {
      continue;
    }
    final LAServer? carrier = p.placement.carrierOf(c);
    if (carrier == null || c.type != DeploymentType.dockerCompose) {
      throw PlacementException(
        '$nameInt is on "${c.name}", which is not a docker-compose cluster '
        'carried by a server; move it in the toolkit UI.',
      );
    }
    slots.add(PlacementSlot(carrier, PlacementLeg.docker, c));
  }
  return slots;
}

/// Per server name, the services on each leg: `{vm: [...], docker: [...]}`.
/// Workloads only, sorted; servers with nothing left out.
Map<String, Map<String, List<String>>> servicesByServer(LAProject p) {
  final Map<String, Map<String, List<String>>> out =
      <String, Map<String, List<String>>>{};
  void add(String server, PlacementLeg leg, Iterable<String> names) {
    final List<String> w =
        names.where((String n) => !_infraServices.contains(n)).toList()..sort();
    if (w.isEmpty) {
      return;
    }
    (out[server] ??= <String, List<String>>{})[leg.name] = w;
  }

  for (final LAServer s in p.servers) {
    add(s.name, PlacementLeg.vm, p.getServerServices(serverId: s.id));
  }
  for (final LACluster c in p.placement.composeClusters) {
    final LAServer? carrier = p.placement.carrierOf(c);
    add(
      carrier?.name ?? c.name,
      PlacementLeg.docker,
      p.getClusterServices(clusterId: c.id),
    );
  }
  return out;
}

/// Applies [moves] to [p], one after the other. Throws [PlacementException]
/// on the first one the UI would not allow; [p] may then be half changed, so
/// work on a copy (a model freshly built from the stored JSON).
///
/// A docker target needs a compose cluster on that server: with
/// [createComposeClusters] one is created as the UI does, by assigning
/// docker_compose to the server; a hub never creates one. [laReleases] is
/// what the UI passes to seed versions (only for services assigned nowhere
/// before: moved ones keep theirs).
PlacementChange moveServices(
  LAProject p,
  List<ServiceMove> moves, {
  bool createComposeClusters = false,
  Map<String, LAReleases>? laReleases,
}) {
  final List<MovedService> done = <MovedService>[];
  final List<String> created = <String>[];
  for (final ServiceMove m in moves) {
    final String name = resolveServiceName(m.service);
    _checkMovable(p, name);
    final PlacementSlot? from = _source(p, name, m);
    final PlacementSlot to = _target(
      p,
      name,
      m,
      from,
      createComposeClusters: createComposeClusters,
      created: created,
    );

    // As the servers card does when a chip is removed: unassign, then assign
    // what is left (see ServerServicesEditCard.onDeleted).
    List<String> carried = <String>[name];
    final Map<String, Map<String, String>> versions =
        <String, Map<String, String>>{};
    if (from != null) {
      final List<String> before = List<String>.of(_servicesOf(p, from));
      for (final LAServiceDeploy sd in _rows(p, from)) {
        final String? n = _serviceName(p, sd.serviceId);
        if (n != null) {
          versions[n] = Map<String, String>.of(sd.softwareVersions);
        }
      }
      p.unAssignByType(from.id, from.type, name);
      final List<String> left = List<String>.of(_servicesOf(p, from));
      p.assignByType(from.id, from.type, left, null, laReleases);
      carried = before.where((String s) => !left.contains(s)).toList();
    }

    // The same eligibility the UI applies to the chips it offers.
    final List<String> assignable =
        (p.getServerServicesAssignable(to.type)[to.id] ?? <LAService>[])
            .map((LAService s) => s.nameInt)
            .toList();
    if (!assignable.contains(name)) {
      final bool noDocker =
          to.leg == PlacementLeg.docker &&
          !LAServiceDesc.listDockerCapableS.contains(name);
      throw PlacementException(
        noDocker
            ? '$name has no docker-compose support: it cannot go to $to.'
            : '$name cannot go to $to: the toolkit does not offer it there '
                  '(it allows one deploy only and runs elsewhere).',
      );
    }
    p.assignByType(
      to.id,
      to.type,
      <String>[..._servicesOf(p, to), name],
      null,
      laReleases,
    );

    // assignByType seeds a new row from the rows left elsewhere, or the
    // newest release when there are none: a move must not change versions.
    for (final LAServiceDeploy sd in _rows(p, to)) {
      final String? n = _serviceName(p, sd.serviceId);
      if (n != null && carried.contains(n) && versions.containsKey(n)) {
        sd.softwareVersions
          ..clear()
          ..addAll(versions[n]!);
      }
    }
    final Map<String, String> kept = <String, String>{};
    for (final LAServiceDeploy sd in _rows(p, to)) {
      final String? n = _serviceName(p, sd.serviceId);
      if (n != null && carried.contains(n)) {
        final String? v = sd.softwareVersions[n];
        if (v != null) {
          kept[n] = v;
        }
      }
    }
    done.add(
      MovedService(
        service: name,
        carried: carried.where((String s) => s != name).toList()..sort(),
        from: from,
        to: to,
        versions: kept,
      ),
    );
  }
  return PlacementChange(done, created);
}

void _checkMovable(LAProject p, String name) {
  if (_infraServices.contains(name)) {
    throw PlacementException(
      '$name is not a workload: it marks a server as a docker host. Ask for '
      'createComposeClusters on a move instead.',
    );
  }
  if (LAServiceDesc.subServices.contains(name)) {
    final String? parent = LAServiceDesc.get(name).parentService?.toS();
    throw PlacementException(
      '$name moves with ${parent ?? 'its parent service'}: move '
      '${parent ?? 'that'} instead.',
    );
  }
  if (!LAServiceDesc.list(
    p.isHub,
  ).any((LAServiceDesc d) => d.nameInt == name)) {
    throw PlacementException('$name is not a service a hub can run.');
  }
  final LAService? s = p.services.firstWhereOrNull(
    (LAService s) => s.nameInt == name,
  );
  if (s == null || !s.use) {
    throw PlacementException(
      '$name is not in use in ${p.shortName}: enable it in the toolkit first.',
    );
  }
}

PlacementSlot? _source(LAProject p, String name, ServiceMove m) {
  final List<PlacementSlot> all = serviceLocations(p, name);
  final List<PlacementSlot> on = all
      .where(
        (PlacementSlot s) =>
            (m.from == null || s.server.name == m.from) &&
            (m.fromLeg == null || s.leg == m.fromLeg),
      )
      .toList();
  if (on.length == 1) {
    return on.single;
  }
  if (on.isEmpty) {
    // In use but assigned nowhere: only assigned, as in the UI.
    if (all.isEmpty && m.from == null && m.fromLeg == null) {
      return null;
    }
    final String where = m.from == null ? '' : ' on ${m.from}';
    final String leg = m.fromLeg == null ? '' : ' (${m.fromLeg!.name})';
    throw PlacementException(
      '$name is not$where$leg; '
      '${all.isEmpty ? 'it is assigned nowhere' : 'it runs on ${all.join(', ')}'}.',
    );
  }
  throw PlacementException(
    m.from == null
        ? '$name runs on ${on.join(', ')}: say which one with `from`.'
        : '$name runs on ${m.from} both as a VM service and on its '
              'docker-compose cluster: pass fromLeg.',
  );
}

PlacementSlot _target(
  LAProject p,
  String name,
  ServiceMove m,
  PlacementSlot? from, {
  required bool createComposeClusters,
  required List<String> created,
}) {
  final LAServer? server = p.placement.servers.firstWhereOrNull(
    (LAServer s) => s.name == m.to,
  );
  if (server == null) {
    throw PlacementException(
      'No server "${m.to}" in ${p.shortName}. Servers: '
      '${p.placement.servers.map((LAServer s) => s.name).join(', ')}. '
      'Add a new one in the toolkit first.',
    );
  }
  LACluster? cluster() => p.placement.composeClusters.firstWhereOrNull(
    (LACluster c) => c.serverId == server.id,
  );
  final PlacementLeg? leg = m.toLeg ?? from?.leg;
  if (leg == null && cluster() != null) {
    throw PlacementException(
      '${m.to} carries a docker-compose cluster and can also run VM '
      'services: pass toLeg ("docker" or "vm") for $name.',
    );
  }
  if ((leg ?? PlacementLeg.vm) == PlacementLeg.vm) {
    if (!p.servers.contains(server)) {
      throw PlacementException(
        '${m.to} is a server of the portal: a hub can only use it through '
        'its docker-compose cluster (toLeg: "docker").',
      );
    }
    final PlacementSlot to = PlacementSlot(server, PlacementLeg.vm);
    _checkNotThere(p, name, to, from);
    return to;
  }
  if (cluster() == null) {
    if (p.isHub) {
      throw PlacementException(
        '${m.to} carries no docker-compose cluster, and a hub never creates '
        'one: add docker_compose to it in the portal first.',
      );
    }
    if (!createComposeClusters) {
      throw PlacementException(
        '${m.to} carries no docker-compose cluster yet. Pass '
        'createComposeClusters: true to add docker_compose to it (the '
        'cluster comes with it, as in the UI), or toLeg: "vm".',
      );
    }
    if (!p.getService(dockerCompose).use) {
      throw PlacementException(
        'docker_compose is not in use in ${p.shortName}: enable it in the '
        'toolkit first.',
      );
    }
    p.assignByType(server.id, DeploymentType.vm, <String>[
      ...p.getServerServices(serverId: server.id),
      dockerCompose,
    ]);
    created.add(server.name);
  }
  final PlacementSlot to = PlacementSlot(
    server,
    PlacementLeg.docker,
    cluster(),
  );
  _checkNotThere(p, name, to, from);
  return to;
}

/// A service twice on one machine (as VM service and in its cluster) breaks
/// the data integrity check; twice in the same slot is a no-op.
void _checkNotThere(
  LAProject p,
  String name,
  PlacementSlot to,
  PlacementSlot? from,
) {
  for (final PlacementSlot s in serviceLocations(p, name)) {
    if (s.server.id != to.server.id) {
      continue;
    }
    if (from != null && s.id == from.id) {
      if (s.leg == to.leg) {
        throw PlacementException('$name is already on $to.');
      }
      continue;
    }
    throw PlacementException('$name already runs on $s.');
  }
}

List<String> _servicesOf(LAProject p, PlacementSlot s) =>
    s.leg == PlacementLeg.vm
    ? p.getServerServices(serverId: s.server.id)
    : p.getClusterServices(clusterId: s.cluster!.id);

Iterable<LAServiceDeploy> _rows(LAProject p, PlacementSlot s) =>
    p.serviceDeploys.where(
      (LAServiceDeploy sd) =>
          sd.projectId == p.id &&
          sd.type == s.type &&
          (s.leg == PlacementLeg.vm
              ? sd.serverId == s.server.id && sd.clusterId == null
              : sd.clusterId == s.cluster!.id),
    );

String? _serviceName(LAProject p, String serviceId) =>
    p.services.firstWhereOrNull((LAService s) => s.id == serviceId)?.nameInt;

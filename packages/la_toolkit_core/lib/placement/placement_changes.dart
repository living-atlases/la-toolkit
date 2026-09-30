// Changing where the services of an existing project run, the way the
// servers page of the app does it: a chip removed from one card
// (LAProject.unAssignByType, then assignByType with what is left), a chip
// added on another (assignByType). docker_compose on a server is what creates
// its compose cluster, and removing it is the UI's cluster delete. What this
// adds is the checks the UI does by only offering valid chips, turned into
// refusals, plus keeping the versions of moved services.
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

/// [PlacementOp.move] takes a service off one place and onto another;
/// [PlacementOp.assign] adds a place (a second ala_hub, or docker_compose on
/// a server); [PlacementOp.unassign] removes one.
enum PlacementOp { move, assign, unassign }

/// A move refused. The message says why and what to pass instead.
class PlacementException implements Exception {
  PlacementException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// One change for [service]. [to] (a server name) is needed to move or
/// assign, [from] to unassign and, for a move, when the service runs in more
/// than one place; the legs only when a server could mean either (a compose
/// host that also runs VM services).
class ServiceMove {
  const ServiceMove({
    required this.service,
    this.op = PlacementOp.move,
    this.to,
    this.from,
    this.fromLeg,
    this.toLeg,
  });

  final String service;
  final PlacementOp op;
  final String? to;
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

/// What [changePlacement] did for one change.
class MovedService {
  MovedService({
    required this.op,
    required this.service,
    required this.carried,
    required this.from,
    required this.to,
    required this.versions,
  });

  final PlacementOp op;
  final String service;

  /// The sub-services that went along (spatial takes spatial_service and
  /// geoserver).
  final List<String> carried;

  /// Null for an assign, or a move of a service assigned nowhere.
  final PlacementSlot? from;

  /// Null for an unassign.
  final PlacementSlot? to;

  /// Software versions of the rows at [to] (a move keeps the source's).
  final Map<String, String> versions;
}

class PlacementChange {
  PlacementChange(this.moves, this.clustersCreated, this.clustersDeleted);

  final List<MovedService> moves;

  /// Servers that got a docker-compose cluster (docker_compose assigned).
  final List<String> clustersCreated;

  /// Servers whose (empty) docker-compose cluster went with docker_compose.
  final List<String> clustersDeleted;
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
/// work on a copy (a model freshly built from the stored JSON). [laReleases]
/// is what the UI passes to seed the versions of new rows (moved rows keep
/// theirs).
PlacementChange changePlacement(
  LAProject p,
  List<ServiceMove> moves, {
  Map<String, LAReleases>? laReleases,
}) {
  final List<MovedService> done = <MovedService>[];
  final List<String> created = <String>[];
  final List<String> deleted = <String>[];
  for (final ServiceMove m in moves) {
    final String name = resolveServiceName(m.service);
    if (name == dockerCompose && m.op != PlacementOp.move) {
      done.add(
        m.op == PlacementOp.assign
            ? _assignCompose(p, m, created)
            : _unassignCompose(p, m, deleted),
      );
      continue;
    }
    _checkMovable(p, name);
    if (m.op != PlacementOp.unassign && m.to == null) {
      throw PlacementException('To ${m.op.name} $name, say where: `to`.');
    }
    if (m.op == PlacementOp.unassign && m.to != null) {
      throw PlacementException(
        'unassign takes `from`, not `to` (use a move for $name).',
      );
    }
    final PlacementSlot? from = m.op == PlacementOp.assign
        ? null
        : _source(p, name, m);
    if (m.op == PlacementOp.unassign && from == null) {
      throw PlacementException('$name is assigned nowhere.');
    }
    final PlacementSlot? to = m.op == PlacementOp.unassign
        ? null
        : _target(p, name, m, from);

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
      // As the servers card does when a chip is removed: unassign, then
      // assign what is left (see ServerServicesEditCard.onDeleted).
      p.unAssignByType(from.id, from.type, name);
      final List<String> left = List<String>.of(_servicesOf(p, from));
      p.assignByType(from.id, from.type, left, null, laReleases);
      carried = before.where((String s) => !left.contains(s)).toList();
    }

    final Map<String, String> kept = <String, String>{};
    if (to != null) {
      _checkAssignable(p, name, to);
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
      for (final LAServiceDeploy sd in _rows(p, to)) {
        final String? n = _serviceName(p, sd.serviceId);
        final String? v = n == null ? null : sd.softwareVersions[n];
        if (v != null && (carried.contains(n) || n == name)) {
          kept[n!] = v;
        }
      }
    }
    done.add(
      MovedService(
        op: m.op,
        service: name,
        carried: carried.where((String s) => s != name).toList()..sort(),
        from: from,
        to: to,
        versions: kept,
      ),
    );
  }
  return PlacementChange(done, created, deleted);
}

/// The same eligibility the UI applies to the chips it offers.
void _checkAssignable(LAProject p, String name, PlacementSlot to) {
  final List<String> assignable =
      (p.getServerServicesAssignable(to.type)[to.id] ?? <LAService>[])
          .map((LAService s) => s.nameInt)
          .toList();
  if (assignable.contains(name)) {
    return;
  }
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

LAServer _server(LAProject p, String? name, {bool ownOnly = false}) {
  final List<LAServer> servers = ownOnly ? p.servers : p.placement.servers;
  final LAServer? s = servers.firstWhereOrNull((LAServer s) => s.name == name);
  if (s == null) {
    throw PlacementException(
      'No server "$name" in ${p.shortName}. Servers: '
      '${servers.map((LAServer s) => s.name).join(', ')}. '
      'Add it first (la_set_servers, or the toolkit UI).',
    );
  }
  return s;
}

LACluster? _composeClusterOn(LAProject p, LAServer s) => p
    .placement
    .composeClusters
    .firstWhereOrNull((LACluster c) => c.serverId == s.id);

/// Ticking docker_compose on a server's card: the server becomes a compose
/// host and its cluster is created with it.
MovedService _assignCompose(LAProject p, ServiceMove m, List<String> created) {
  if (p.isHub) {
    throw PlacementException(
      'A hub never creates docker-compose clusters: it places services on '
      "its portal's.",
    );
  }
  if (m.to == null) {
    throw PlacementException('To assign docker_compose, say where: `to`.');
  }
  final LAServer server = _server(p, m.to, ownOnly: true);
  if (!p.getService(dockerCompose).use) {
    throw PlacementException(
      'docker_compose is not in use in ${p.shortName}: enable it in the '
      'toolkit first.',
    );
  }
  if (p.getServerServices(serverId: server.id).contains(dockerCompose) ||
      _composeClusterOn(p, server) != null) {
    throw PlacementException(
      '${server.name} is already a docker-compose host.',
    );
  }
  p.assignByType(server.id, DeploymentType.vm, <String>[
    ...p.getServerServices(serverId: server.id),
    dockerCompose,
  ]);
  created.add(server.name);
  return MovedService(
    op: PlacementOp.assign,
    service: dockerCompose,
    carried: const <String>[],
    from: null,
    to: PlacementSlot(server, PlacementLeg.vm),
    versions: const <String, String>{},
  );
}

/// Unticking docker_compose, which is deleting the server's cluster: only
/// once nothing, of the portal or of a hub, runs on it any more.
MovedService _unassignCompose(
  LAProject p,
  ServiceMove m,
  List<String> deleted,
) {
  if (p.isHub) {
    throw PlacementException(
      "A hub has no docker-compose clusters of its own: the portal's are "
      'changed from the portal.',
    );
  }
  final LAServer server = _server(p, m.from ?? m.to, ownOnly: true);
  final LACluster? cluster = _composeClusterOn(p, server);
  if (cluster == null &&
      !p.getServerServices(serverId: server.id).contains(dockerCompose)) {
    throw PlacementException('${server.name} is not a docker-compose host.');
  }
  if (cluster != null) {
    final List<String> own = p.getClusterServices(clusterId: cluster.id);
    final List<String> hubs = <String>[
      for (final LAProject h in p.hubs)
        if (h.getClusterServices(clusterId: cluster.id).isNotEmpty) h.shortName,
    ];
    if (own.isNotEmpty || hubs.isNotEmpty) {
      throw PlacementException(
        'The docker-compose cluster on ${server.name} still runs '
        '${<String>[...own, ...hubs.map((String h) => 'services of hub $h')].join(', ')}: '
        'move them off first.',
      );
    }
  }
  // Unticking docker_compose on the server's card, which takes the server's
  // compose cluster with it. Not deleteCluster(): its last step also drops
  // every deploy row of the project that points at a cluster that no longer
  // exists, rows that still decide where names resolve (lademo had 32).
  p.unAssignByType(server.id, DeploymentType.vm, dockerCompose);
  deleted.add(server.name);
  return MovedService(
    op: PlacementOp.unassign,
    service: dockerCompose,
    carried: const <String>[],
    from: PlacementSlot(server, PlacementLeg.vm),
    to: null,
    versions: const <String, String>{},
  );
}

void _checkMovable(LAProject p, String name) {
  if (_infraServices.contains(name)) {
    throw PlacementException(
      '$name is not a workload${name == dockerCompose ? ': assign or unassign it (op) to make a server a docker-compose host or not' : ''}.',
    );
  }
  if (LAServiceDesc.subServices.contains(name)) {
    final String? parent = LAServiceDesc.get(name).parentService?.toS();
    throw PlacementException(
      '$name moves with ${parent ?? 'its parent service'}: change '
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
    // In use but assigned nowhere: a move only assigns it, as in the UI.
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
  PlacementSlot? from,
) {
  final LAServer server = _server(p, m.to);
  final LACluster? cluster = _composeClusterOn(p, server);
  final PlacementLeg? leg = m.toLeg ?? from?.leg;
  if (leg == null && cluster != null) {
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
  if (cluster == null) {
    throw PlacementException(
      p.isHub
          ? '${m.to} carries no docker-compose cluster, and a hub never '
                'creates one: make it a compose host in the portal first.'
          : '${m.to} carries no docker-compose cluster yet: assign '
                'docker_compose to it first (a change {op: "assign", service: '
                '"docker_compose", to: "${m.to}"} before this one), or toLeg: '
                '"vm".',
    );
  }
  final PlacementSlot to = PlacementSlot(server, PlacementLeg.docker, cluster);
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

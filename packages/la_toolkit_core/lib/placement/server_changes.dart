// Adding, editing and removing the servers of a project, as the servers page
// does (LAProject.upsertServer / deleteCluster / delete), with the checks its
// forms and dialogs leave to the user turned into refusals. Renaming is left
// out: a name is an ssh host alias, a gateway reference and sometimes a
// variable value (pipelines_master).
import 'package:collection/collection.dart';

import '../models/la_cluster.dart';
import '../models/la_project.dart';
import '../models/la_server.dart';
import '../models/la_service_constants.dart';
import '../models/ssh_key.dart';
import '../utils/regexp.dart';

/// A change refused. The message says why.
class ServerChangeException implements Exception {
  ServerChangeException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// A server to add, or the fields of one to change (null: unchanged).
/// [gateways] are names of other servers of the project (ssh jumps).
class ServerSpec {
  const ServerSpec({
    required this.name,
    this.ip,
    this.sshUser,
    this.sshPort,
    this.sshKey,
    this.aliases,
    this.gateways,
  });

  final String name;
  final String? ip;
  final String? sshUser;
  final int? sshPort;
  final SshKey? sshKey;
  final List<String>? aliases;
  final List<String>? gateways;
}

class ServerChange {
  final List<String> added = <String>[];

  /// Per server, the fields that changed.
  final Map<String, List<String>> updated = <String, List<String>>{};
  final List<String> removed = <String>[];

  /// Side effects worth telling (empty clusters deleted, gateways dropped).
  final List<String> notes = <String>[];
}

/// Adds [add], then applies [update], then removes [remove] (server names).
/// Throws [ServerChangeException] on the first change the toolkit should not
/// make; [p] may then be half changed, so work on a copy.
ServerChange changeServers(
  LAProject p, {
  List<ServerSpec> add = const <ServerSpec>[],
  List<ServerSpec> update = const <ServerSpec>[],
  List<String> remove = const <String>[],
}) {
  final ServerChange c = ServerChange();
  for (final ServerSpec s in add) {
    _checkName(s.name);
    if (p.placement.servers.any((LAServer x) => x.name == s.name)) {
      throw ServerChangeException(
        '${p.shortName} already has a server "${s.name}".',
      );
    }
    if (s.ip == null) {
      throw ServerChangeException('A new server needs an ip: ${s.name}.');
    }
    final LAServer server = LAServer(name: s.name, projectId: p.id);
    _apply(p, server, s);
    p.upsertServer(server);
    c.added.add(s.name);
  }
  for (final ServerSpec s in update) {
    final LAServer? server = p.servers.firstWhereOrNull(
      (LAServer x) => x.name == s.name,
    );
    if (server == null) {
      throw ServerChangeException(_unknown(p, s.name));
    }
    final List<String> fields = _apply(p, server, s);
    if (fields.isEmpty) {
      throw ServerChangeException('Nothing to change on ${s.name}.');
    }
    p.upsertServer(server);
    c.updated[s.name] = fields;
  }
  for (final String name in remove) {
    _remove(p, name, c);
  }
  return c;
}

void _checkName(String name) {
  if (!LARegExp.hostnameRegexp.hasMatch(name) || name.startsWith('-')) {
    throw ServerChangeException('"$name" is not a valid server name.');
  }
}

String _unknown(LAProject p, String name) =>
    'No server "$name" in ${p.shortName}. Servers: '
    '${p.servers.map((LAServer s) => s.name).join(', ')}.';

/// Sets the given fields on [server]; answers the names of those that
/// changed.
List<String> _apply(LAProject p, LAServer server, ServerSpec s) {
  final List<String> changed = <String>[];
  final String? ip = s.ip;
  if (ip != null) {
    if (!LARegExp.ipv4.hasMatch(ip) && !_isIpv6(ip)) {
      throw ServerChangeException('"$ip" is not an IP address (${s.name}).');
    }
    if (server.ip != ip) {
      server.ip = ip;
      changed.add('ip');
    }
  }
  final String? user = s.sshUser;
  if (user != null) {
    if (!RegExp(r'^[a-z_][a-z0-9_-]*$').hasMatch(user)) {
      throw ServerChangeException('"$user" is not an ssh user (${s.name}).');
    }
    if (server.sshUser != user) {
      server.sshUser = user;
      changed.add('sshUser');
    }
  }
  final int? port = s.sshPort;
  if (port != null) {
    if (port < 1 || port > 65535) {
      throw ServerChangeException('$port is not a port (${s.name}).');
    }
    if (server.sshPort != port) {
      server.sshPort = port;
      changed.add('sshPort');
    }
  }
  final SshKey? key = s.sshKey;
  if (key != null && server.sshKey?.name != key.name) {
    server.sshKey = key;
    changed.add('sshKey');
  }
  final List<String>? aliases = s.aliases;
  if (aliases != null) {
    for (final String a in aliases) {
      if (!LARegExp.hostnameRegexp.hasMatch(a) || a.startsWith('-')) {
        throw ServerChangeException('"$a" is not a host name (${s.name}).');
      }
    }
    if (!const ListEquality<String>().equals(server.aliases, aliases)) {
      server.aliases = List<String>.of(aliases);
      changed.add('aliases');
    }
  }
  final List<String>? gateways = s.gateways;
  if (gateways != null) {
    final List<String> ids = <String>[
      for (final String g in gateways)
        if (g == s.name)
          throw ServerChangeException('${s.name} cannot be its own gateway.')
        else
          p.servers.firstWhereOrNull((LAServer x) => x.name == g)?.id ??
              (throw ServerChangeException(
                'Gateway "$g" of ${s.name} is not a server of ${p.shortName}.',
              )),
    ];
    if (!const ListEquality<String>().equals(server.gateways, ids)) {
      server.gateways = ids;
      changed.add('gateways');
    }
  }
  return changed;
}

bool _isIpv6(String ip) => ip.contains(':') && LARegExp.ipv6.hasMatch(ip);

/// Removing a server that still runs something would drop those services
/// without a word (and the UI's plain delete leaves its cluster behind): only
/// empty servers go, their empty cluster first, as two clicks in the UI would.
void _remove(LAProject p, String name, ServerChange c) {
  final LAServer? server = p.servers.firstWhereOrNull(
    (LAServer x) => x.name == name,
  );
  if (server == null) {
    throw ServerChangeException(_unknown(p, name));
  }
  final List<String> vm = p
      .getServerServices(serverId: server.id)
      .where(
        (String s) =>
            s != dockerCompose && s != dockerSwarm && s != dockerCommon,
      )
      .toList();
  final List<String> busy = <String>[
    ...vm,
    for (final LACluster cl in p.clusters.where(
      (LACluster cl) => cl.serverId == server.id,
    )) ...<String>[
      ...p.getClusterServices(clusterId: cl.id),
      for (final LAProject h in p.hubs)
        if (h.getClusterServices(clusterId: cl.id).isNotEmpty)
          'services of hub ${h.shortName}',
    ],
  ];
  if (busy.isNotEmpty) {
    throw ServerChangeException(
      '$name still runs ${busy.join(', ')}: move them off first '
      '(la_set_placement).',
    );
  }
  if (p.getVariableOrNull('pipelines_master')?.value == name) {
    throw ServerChangeException(
      '$name is the pipelines master (pipelines_master): change it first.',
    );
  }
  for (final LACluster cl
      in p.clusters
          .where((LACluster cl) => cl.serverId == server.id)
          .toList()) {
    p.deleteCluster(cl);
    c.notes.add('The empty ${cl.name} goes with $name.');
  }
  for (final LAServer other in p.servers) {
    if (other.gateways.contains(server.id)) {
      c.notes.add('$name is no longer the ssh gateway of ${other.name}.');
    }
  }
  p.delete(server);
  c.removed.add(name);
}

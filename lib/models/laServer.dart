import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/sshKey.dart';
import 'package:objectid/objectid.dart';

import 'isJsonSerializable.dart';
import 'laService.dart';

part 'laServer.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServer implements IsJsonSerializable<LAServer> {
  // Basic
  String id;
  String name;
  List<String> aliases;

  // Connectivity
  String ip;
  int sshPort;
  String? sshUser;
  SshKey? sshKey;
  // List of proxy jumps (assh allows multi proxyjumps)
  List<String> gateways;

  // Status
  ServiceStatus reachable;
  ServiceStatus sshReachable;
  ServiceStatus sudoEnabled;

  // Facts
  String osName;
  String osVersion;

  // Relations
  String projectId;

  LAServer(
      {String? id,
      required this.name,
      String? ip,
      this.sshPort: 22,
      this.sshUser,
      List<String>? aliases,
      List<String>? gateways,
      this.sshKey,
      this.reachable: ServiceStatus.unknown,
      this.sshReachable: ServiceStatus.unknown,
      this.sudoEnabled: ServiceStatus.unknown,
      this.osName = "",
      this.osVersion = "",
      required this.projectId})
      : id = id ?? new ObjectId().toString(),
        this.aliases = aliases ?? [],
        this.gateways = gateways ?? [],
        this.ip = ip ?? "";

  factory LAServer.fromJson(Map<String, dynamic> json) =>
      _$LAServerFromJson(json);
  Map<String, dynamic> toJson() => _$LAServerToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LAServer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id &&
          ip == other.ip &&
          sshPort == other.sshPort &&
          sshUser == other.sshUser &&
          sshKey == other.sshKey &&
          listEquals(aliases, other.aliases) &&
          listEquals(gateways, other.gateways) &&
          osName == other.osName &&
          osVersion == other.osVersion &&
          reachable == other.reachable &&
          sshReachable == other.sshReachable &&
          projectId == other.projectId &&
          sudoEnabled == other.sudoEnabled;

  @override
  int get hashCode =>
      name.hashCode ^
      id.hashCode ^
      ip.hashCode ^
      sshPort.hashCode ^
      sshUser.hashCode ^
      sshKey.hashCode ^
      DeepCollectionEquality.unordered().hash(aliases) ^
      DeepCollectionEquality.unordered().hash(gateways) ^
      osName.hashCode ^
      osVersion.hashCode ^
      reachable.hashCode ^
      sshReachable.hashCode ^
      projectId.hashCode ^
      sudoEnabled.hashCode;

  bool isReady() {
    return this.reachable == ServiceStatus.success &&
        this.sshReachable == ServiceStatus.success &&
        this.sudoEnabled == ServiceStatus.success;
  }

  bool isSshReady() {
    return this.sshReachable == ServiceStatus.success;
  }

  @override
  String toString() {
    return '''$name (${id.substring(0, 8)}...)${ip.length > 0 ? ', ' + ip : ''} isReady: ${isReady()}${osName != '' ? ' osName: ' : ''}$osName${osVersion != '' ? ' osVersion: ' : ''}$osVersion ${aliases.length > 0 ? ' ' + aliases.join(' ') : ''}''';
  }

  static List<LAServer> upsertById(List<LAServer> servers, LAServer laServer) {
    if (servers.map((s) => s.id).toList().contains(laServer.id)) {
      servers = servers
          .map((current) => current.id == laServer.id ? laServer : current)
          .toList();
    } else {
      servers.add(laServer);
    }
    return servers;
  }

  static List<LAServer> upsertByName(
      List<LAServer> servers, LAServer laServer) {
    if (servers.map((s) => s.name).toList().contains(laServer.name)) {
      servers = servers.map((current) {
        if (current.name == laServer.name) {
          // set the same previous id;
          laServer.id = current.id;
          return laServer;
        } else
          return current;
      }).toList();
    } else {
      servers.add(laServer);
    }
    return servers;
  }

  @override
  LAServer fromJson(Map<String, dynamic> json) => LAServer.fromJson(json);
}

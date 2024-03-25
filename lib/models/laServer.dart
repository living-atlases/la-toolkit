import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

import '../utils/regexp.dart';
import 'isJsonSerializable.dart';
import 'la_service.dart';
import 'sshKey.dart';

part 'laServer.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LAServer implements IsJsonSerializable<LAServer> {

  LAServer(
      {String? id,
      required this.name,
      String? ip,
      this.sshPort = 22,
      this.sshUser,
      List<String>? aliases,
      List<String>? gateways,
      this.sshKey,
      this.reachable = ServiceStatus.unknown,
      this.sshReachable = ServiceStatus.unknown,
      this.sudoEnabled = ServiceStatus.unknown,
      this.osName = '',
      this.osVersion = '',
      required this.projectId})
      : id = id ?? ObjectId().toString(),
        aliases = aliases ?? <String>[],
        gateways = gateways ?? <String>[],
        ip = ip ?? '' {
    assert(LARegExp.hostnameRegexp.hasMatch(name),
        "'$name' is a invalid server name");
  }

  factory LAServer.fromJson(Map<String, dynamic> json) =>
      _$LAServerFromJson(json);
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

  @override
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
      const DeepCollectionEquality.unordered().hash(aliases) ^
      const DeepCollectionEquality.unordered().hash(gateways) ^
      osName.hashCode ^
      osVersion.hashCode ^
      reachable.hashCode ^
      sshReachable.hashCode ^
      projectId.hashCode ^
      sudoEnabled.hashCode;

  bool isReady() {
    return // this.reachable == ServiceStatus.success &&
        sshReachable == ServiceStatus.success &&
            sudoEnabled == ServiceStatus.success;
  }

  bool isSshReady() {
    return sshReachable == ServiceStatus.success;
  }

  @override
  String toString() {
    return '''$name ($id)${ip.isNotEmpty ? ', $ip' : ''} gws: ${gateways.length} isReady: ${isReady()}${osName != '' ? ' osName: ' : ''}$osName${osVersion != '' ? ' osVersion: ' : ''}$osVersion ${aliases.isNotEmpty ? ' ${aliases.join(' ')}' : ''}''';
  }

  static List<LAServer> upsertById(List<LAServer> servers, LAServer laServer) {
    if (servers.map((LAServer s) => s.id).toList().contains(laServer.id)) {
      servers = servers
          .map((LAServer current) => current.id == laServer.id ? laServer : current)
          .toList();
    } else {
      servers.add(laServer);
    }
    return servers;
  }

  static List<LAServer> upsertByName(
      List<LAServer> servers, LAServer laServer) {
    if (servers.map((LAServer s) => s.name).toList().contains(laServer.name)) {
      servers = servers.map((LAServer current) {
        if (current.name == laServer.name) {
          // set the same previous id;
          laServer.id = current.id;
          return laServer;
        } else {
          return current;
        }
      }).toList();
    } else {
      servers.add(laServer);
    }
    return servers;
  }

  @override
  LAServer fromJson(Map<String, dynamic> json) => LAServer.fromJson(json);
}

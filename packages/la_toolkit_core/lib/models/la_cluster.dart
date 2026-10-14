import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

import 'deployment_type.dart';
import 'is_json_serializable.dart';

part 'la_cluster.g.dart';

/// Whether a docker-compose cluster already serves production traffic.
///
/// A hybrid portal migrates service by service, so for a while it has compose
/// hosts with real data (production) next to compose hosts whose services are
/// still empty or being tried (staging). A production host must never resolve a
/// name only staging serves: it keeps reaching the VM that still holds the data.
enum ClusterStage { production, staging }

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LACluster implements IsJsonSerializable<LACluster> {
  LACluster({
    String? id,
    this.name = 'Docker Swarm Cluster',
    this.type = DeploymentType.dockerSwarm,
    required this.projectId,
    this.serverId,
    this.stage = ClusterStage.production,
  }) : id = id ?? ObjectId().toString();

  factory LACluster.fromJson(Map<String, dynamic> json) =>
      _$LAClusterFromJson(json);

  // Basic
  String id;
  String name;

  // Facts
  DeploymentType type;
  @JsonKey(unknownEnumValue: ClusterStage.production)
  ClusterStage stage;

  // Relations
  String projectId;
  String? serverId;

  @override
  Map<String, dynamic> toJson() => _$LAClusterToJson(this);

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LACluster &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id &&
          type == other.type &&
          projectId == other.projectId &&
          serverId == other.serverId &&
          stage == other.stage;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode =>
      name.hashCode ^
      id.hashCode ^
      type.hashCode ^
      projectId.hashCode ^
      serverId.hashCode ^
      stage.hashCode;

  @override
  String toString() {
    return '$name ($id) $type';
  }

  static List<LACluster> upsertById(
    List<LACluster> clusters,
    LACluster cluster,
  ) {
    if (clusters.map((LACluster s) => s.id).toList().contains(cluster.id)) {
      clusters = clusters
          .map(
            (LACluster current) => current.id == cluster.id ? cluster : current,
          )
          .toList();
    } else {
      clusters.add(cluster);
    }
    return clusters;
  }

  static List<LACluster> upsertByName(
    List<LACluster> clusters,
    LACluster cluster,
  ) {
    if (clusters.map((LACluster s) => s.name).toList().contains(cluster.name)) {
      clusters = clusters.map((LACluster current) {
        if (current.name == cluster.name) {
          // set the same previous id;
          cluster.id = current.id;
          return cluster;
        } else {
          return current;
        }
      }).toList();
    } else {
      clusters.add(cluster);
    }
    return clusters;
  }

  @override
  LACluster fromJson(Map<String, dynamic> json) => LACluster.fromJson(json);
}

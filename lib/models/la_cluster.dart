import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

import 'deployment_type.dart';
import 'is_json_serializable.dart';

part 'la_cluster.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class LACluster implements IsJsonSerializable<LACluster> {
  LACluster({
    String? id,
    this.name = 'Docker Swarm Cluster',
    this.type = DeploymentType.dockerSwarm,
    required this.projectId,
  }) : id = id ?? ObjectId().toString();

  factory LACluster.fromJson(Map<String, dynamic> json) =>
      _$LAClusterFromJson(json);

  // Basic
  String id;
  String name;

  // Facts
  DeploymentType type;

  // Relations
  String projectId;

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
          projectId == other.projectId;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode =>
      name.hashCode ^ id.hashCode ^ type.hashCode ^ projectId.hashCode;

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

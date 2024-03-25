// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laCluster.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAClusterCWProxy {
  LACluster id(String? id);

  LACluster name(String name);

  LACluster type(DeploymentType type);

  LACluster projectId(String projectId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LACluster(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LACluster(...).copyWith(id: 12, name: "My name")
  /// ````
  LACluster call({
    String? id,
    String? name,
    DeploymentType? type,
    String? projectId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLACluster.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLACluster.copyWith.fieldName(...)`
class _$LAClusterCWProxyImpl implements _$LAClusterCWProxy {
  const _$LAClusterCWProxyImpl(this._value);

  final LACluster _value;

  @override
  LACluster id(String? id) => this(id: id);

  @override
  LACluster name(String name) => this(name: name);

  @override
  LACluster type(DeploymentType type) => this(type: type);

  @override
  LACluster projectId(String projectId) => this(projectId: projectId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LACluster(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LACluster(...).copyWith(id: 12, name: "My name")
  /// ````
  LACluster call({
    Object? id = const $CopyWithPlaceholder(),
    Object? name = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? projectId = const $CopyWithPlaceholder(),
  }) {
    return LACluster(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      name: name == const $CopyWithPlaceholder() || name == null
          ? _value.name
          // ignore: cast_nullable_to_non_nullable
          : name as String,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as DeploymentType,
      projectId: projectId == const $CopyWithPlaceholder() || projectId == null
          ? _value.projectId
          // ignore: cast_nullable_to_non_nullable
          : projectId as String,
    );
  }
}

extension $LAClusterCopyWith on LACluster {
  /// Returns a callable class that can be used as follows: `instanceOfLACluster.copyWith(...)` or like so:`instanceOfLACluster.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LAClusterCWProxy get copyWith => _$LAClusterCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LACluster _$LAClusterFromJson(Map<String, dynamic> json) => LACluster(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Docker Swarm Cluster',
      type: $enumDecodeNullable(_$DeploymentTypeEnumMap, json['type']) ??
          DeploymentType.dockerSwarm,
      projectId: json['projectId'] as String,
    );

Map<String, dynamic> _$LAClusterToJson(LACluster instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': _$DeploymentTypeEnumMap[instance.type]!,
      'projectId': instance.projectId,
    };

const _$DeploymentTypeEnumMap = {
  DeploymentType.vm: 'vm',
  DeploymentType.dockerSwarm: 'dockerSwarm',
  DeploymentType.k8s: 'k8s',
};

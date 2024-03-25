// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laVariable.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAVariableCWProxy {
  LAVariable id(String? id);

  LAVariable nameInt(String nameInt);

  LAVariable service(LAServiceName service);

  LAVariable value(Object? value);

  LAVariable projectId(String projectId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAVariable(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAVariable(...).copyWith(id: 12, name: "My name")
  /// ````
  LAVariable call({
    String? id,
    String? nameInt,
    LAServiceName? service,
    Object? value,
    String? projectId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAVariable.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLAVariable.copyWith.fieldName(...)`
class _$LAVariableCWProxyImpl implements _$LAVariableCWProxy {
  const _$LAVariableCWProxyImpl(this._value);

  final LAVariable _value;

  @override
  LAVariable id(String? id) => this(id: id);

  @override
  LAVariable nameInt(String nameInt) => this(nameInt: nameInt);

  @override
  LAVariable service(LAServiceName service) => this(service: service);

  @override
  LAVariable value(Object? value) => this(value: value);

  @override
  LAVariable projectId(String projectId) => this(projectId: projectId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAVariable(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAVariable(...).copyWith(id: 12, name: "My name")
  /// ````
  LAVariable call({
    Object? id = const $CopyWithPlaceholder(),
    Object? nameInt = const $CopyWithPlaceholder(),
    Object? service = const $CopyWithPlaceholder(),
    Object? value = const $CopyWithPlaceholder(),
    Object? projectId = const $CopyWithPlaceholder(),
  }) {
    return LAVariable(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      nameInt: nameInt == const $CopyWithPlaceholder() || nameInt == null
          ? _value.nameInt
          // ignore: cast_nullable_to_non_nullable
          : nameInt as String,
      service: service == const $CopyWithPlaceholder() || service == null
          ? _value.service
          // ignore: cast_nullable_to_non_nullable
          : service as LAServiceName,
      value: value == const $CopyWithPlaceholder()
          ? _value.value
          // ignore: cast_nullable_to_non_nullable
          : value,
      projectId: projectId == const $CopyWithPlaceholder() || projectId == null
          ? _value.projectId
          // ignore: cast_nullable_to_non_nullable
          : projectId as String,
    );
  }
}

extension $LAVariableCopyWith on LAVariable {
  /// Returns a callable class that can be used as follows: `instanceOfLAVariable.copyWith(...)` or like so:`instanceOfLAVariable.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LAVariableCWProxy get copyWith => _$LAVariableCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAVariable _$LAVariableFromJson(Map<String, dynamic> json) => LAVariable(
      id: json['id'] as String?,
      nameInt: json['nameInt'] as String,
      service: $enumDecode(_$LAServiceNameEnumMap, json['service']),
      value: json['value'],
      projectId: json['projectId'] as String,
    )..status = $enumDecode(_$LAVariableStatusEnumMap, json['status']);

Map<String, dynamic> _$LAVariableToJson(LAVariable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameInt': instance.nameInt,
      'service': _$LAServiceNameEnumMap[instance.service],
      'value': instance.value,
      'projectId': instance.projectId,
      'status': _$LAVariableStatusEnumMap[instance.status],
    };

const _$LAServiceNameEnumMap = {
  LAServiceName.all: 'all',
  LAServiceName.collectory: 'collectory',
  LAServiceName.ala_hub: 'ala_hub',
  LAServiceName.biocache_service: 'biocache_service',
  LAServiceName.ala_bie: 'ala_bie',
  LAServiceName.bie_index: 'bie_index',
  LAServiceName.images: 'images',
  LAServiceName.species_lists: 'species_lists',
  LAServiceName.regions: 'regions',
  LAServiceName.logger: 'logger',
  LAServiceName.solr: 'solr',
  LAServiceName.solrcloud: 'solrcloud',
  LAServiceName.zookeeper: 'zookeeper',
  LAServiceName.cas: 'cas',
  LAServiceName.userdetails: 'userdetails',
  LAServiceName.cas_management: 'cas_management',
  LAServiceName.apikey: 'apikey',
  LAServiceName.spatial: 'spatial',
  LAServiceName.spatial_service: 'spatial_service',
  LAServiceName.geoserver: 'geoserver',
  LAServiceName.webapi: 'webapi',
  LAServiceName.dashboard: 'dashboard',
  LAServiceName.sds: 'sds',
  LAServiceName.alerts: 'alerts',
  LAServiceName.doi: 'doi',
  LAServiceName.biocache_backend: 'biocache_backend',
  LAServiceName.branding: 'branding',
  LAServiceName.biocache_cli: 'biocache_cli',
  LAServiceName.nameindexer: 'nameindexer',
  LAServiceName.namematching_service: 'namematching_service',
  LAServiceName.sensitive_data_service: 'sensitive_data_service',
  LAServiceName.data_quality: 'data_quality',
  LAServiceName.pipelines: 'pipelines',
  LAServiceName.spark: 'spark',
  LAServiceName.hadoop: 'hadoop',
  LAServiceName.pipelinesJenkins: 'pipelinesJenkins',
  LAServiceName.biocollect: 'biocollect',
  LAServiceName.pdfgen: 'pdfgen',
  LAServiceName.ecodata: 'ecodata',
  LAServiceName.ecodata_reporting: 'ecodata_reporting',
  LAServiceName.events: 'events',
  LAServiceName.events_elasticsearch: 'events_elasticsearch',
  LAServiceName.docker_swarm: 'docker_swarm',
  LAServiceName.gatus: 'gatus',
  LAServiceName.portainer: 'portainer',
  LAServiceName.cassandra: 'cassandra',
};

const _$LAVariableStatusEnumMap = {
  LAVariableStatus.deployed: 'deployed',
  LAVariableStatus.undeployed: 'undeployed',
};

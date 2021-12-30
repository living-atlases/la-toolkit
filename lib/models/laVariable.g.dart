// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laVariable.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAVariable.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfLAVariable.copyWith.fieldName(...)`
class _LAVariableCWProxy {
  final LAVariable _value;

  const _LAVariableCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `LAVariable(...).copyWithNull(...)` to set certain fields to `null`. Prefer `LAVariable(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAVariable(...).copyWith(id: 12, name: "My name")
  /// ````
  LAVariable call({
    String? id,
    String? nameInt,
    String? projectId,
    LAServiceName? service,
    Object? value,
  }) {
    return LAVariable(
      id: id ?? _value.id,
      nameInt: nameInt ?? _value.nameInt,
      projectId: projectId ?? _value.projectId,
      service: service ?? _value.service,
      value: value ?? _value.value,
    );
  }

  LAVariable id(String? id) =>
      id == null ? _value._copyWithNull(id: true) : this(id: id);

  LAVariable value(Object? value) =>
      value == null ? _value._copyWithNull(value: true) : this(value: value);

  LAVariable nameInt(String nameInt) => this(nameInt: nameInt);

  LAVariable projectId(String projectId) => this(projectId: projectId);

  LAVariable service(LAServiceName service) => this(service: service);
}

extension LAVariableCopyWith on LAVariable {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass LAVariable implements IsJsonSerializable<LAVariable>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass LAVariable implements IsJsonSerializable<LAVariable>.name.copyWith.fieldName(...)`
  _LAVariableCWProxy get copyWith => _LAVariableCWProxy(this);

  LAVariable _copyWithNull({
    bool id = false,
    bool value = false,
  }) {
    return LAVariable(
      id: id == true ? null : this.id,
      nameInt: nameInt,
      projectId: projectId,
      service: service,
      value: value == true ? null : this.value,
    );
  }
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
  LAServiceName.data_quality: 'data_quality',
  LAServiceName.pipelines: 'pipelines',
  LAServiceName.spark: 'spark',
  LAServiceName.hadoop: 'hadoop',
  LAServiceName.pipelinesJenkins: 'pipelinesJenkins',
};

const _$LAVariableStatusEnumMap = {
  LAVariableStatus.deployed: 'deployed',
  LAVariableStatus.undeployed: 'undeployed',
};

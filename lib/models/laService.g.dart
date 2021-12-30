// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laService.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAService.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfLAService.copyWith.fieldName(...)`
class _LAServiceCWProxy {
  final LAService _value;

  const _LAServiceCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `LAService(...).copyWithNull(...)` to set certain fields to `null`. Prefer `LAService(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAService(...).copyWith(id: 12, name: "My name")
  /// ````
  LAService call({
    String? id,
    String? iniPath,
    String? nameInt,
    String? projectId,
    ServiceStatus? status,
    String? suburl,
    bool? use,
    bool? usesSubdomain,
  }) {
    return LAService(
      id: id ?? _value.id,
      iniPath: iniPath ?? _value.iniPath,
      nameInt: nameInt ?? _value.nameInt,
      projectId: projectId ?? _value.projectId,
      status: status ?? _value.status,
      suburl: suburl ?? _value.suburl,
      use: use ?? _value.use,
      usesSubdomain: usesSubdomain ?? _value.usesSubdomain,
    );
  }

  LAService id(String? id) =>
      id == null ? _value._copyWithNull(id: true) : this(id: id);

  LAService status(ServiceStatus? status) => status == null
      ? _value._copyWithNull(status: true)
      : this(status: status);

  LAService iniPath(String iniPath) => this(iniPath: iniPath);

  LAService nameInt(String nameInt) => this(nameInt: nameInt);

  LAService projectId(String projectId) => this(projectId: projectId);

  LAService suburl(String suburl) => this(suburl: suburl);

  LAService use(bool use) => this(use: use);

  LAService usesSubdomain(bool usesSubdomain) =>
      this(usesSubdomain: usesSubdomain);
}

extension LAServiceCopyWith on LAService {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass LAService implements IsJsonSerializable<LAService>.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass LAService implements IsJsonSerializable<LAService>.name.copyWith.fieldName(...)`
  _LAServiceCWProxy get copyWith => _LAServiceCWProxy(this);

  LAService _copyWithNull({
    bool id = false,
    bool status = false,
  }) {
    return LAService(
      id: id == true ? null : this.id,
      iniPath: iniPath,
      nameInt: nameInt,
      projectId: projectId,
      status: status == true ? null : this.status,
      suburl: suburl,
      use: use,
      usesSubdomain: usesSubdomain,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAService _$LAServiceFromJson(Map<String, dynamic> json) => LAService(
      id: json['id'] as String?,
      nameInt: json['nameInt'] as String,
      iniPath: json['iniPath'] as String,
      use: json['use'] as bool,
      usesSubdomain: json['usesSubdomain'] as bool,
      status: $enumDecodeNullable(_$ServiceStatusEnumMap, json['status']),
      suburl: json['suburl'] as String,
      projectId: json['projectId'] as String,
    );

Map<String, dynamic> _$LAServiceToJson(LAService instance) => <String, dynamic>{
      'id': instance.id,
      'nameInt': instance.nameInt,
      'use': instance.use,
      'usesSubdomain': instance.usesSubdomain,
      'iniPath': instance.iniPath,
      'suburl': instance.suburl,
      'status': _$ServiceStatusEnumMap[instance.status],
      'projectId': instance.projectId,
    };

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};

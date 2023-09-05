// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laService.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$LAServiceCWProxy {
  LAService id(String? id);

  LAService nameInt(String nameInt);

  LAService iniPath(String iniPath);

  LAService use(bool use);

  LAService usesSubdomain(bool usesSubdomain);

  LAService status(ServiceStatus? status);

  LAService suburl(String suburl);

  LAService projectId(String projectId);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAService(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAService(...).copyWith(id: 12, name: "My name")
  /// ````
  LAService call({
    String? id,
    String? nameInt,
    String? iniPath,
    bool? use,
    bool? usesSubdomain,
    ServiceStatus? status,
    String? suburl,
    String? projectId,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfLAService.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfLAService.copyWith.fieldName(...)`
class _$LAServiceCWProxyImpl implements _$LAServiceCWProxy {
  const _$LAServiceCWProxyImpl(this._value);

  final LAService _value;

  @override
  LAService id(String? id) => this(id: id);

  @override
  LAService nameInt(String nameInt) => this(nameInt: nameInt);

  @override
  LAService iniPath(String iniPath) => this(iniPath: iniPath);

  @override
  LAService use(bool use) => this(use: use);

  @override
  LAService usesSubdomain(bool usesSubdomain) =>
      this(usesSubdomain: usesSubdomain);

  @override
  LAService status(ServiceStatus? status) => this(status: status);

  @override
  LAService suburl(String suburl) => this(suburl: suburl);

  @override
  LAService projectId(String projectId) => this(projectId: projectId);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `LAService(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// LAService(...).copyWith(id: 12, name: "My name")
  /// ````
  LAService call({
    Object? id = const $CopyWithPlaceholder(),
    Object? nameInt = const $CopyWithPlaceholder(),
    Object? iniPath = const $CopyWithPlaceholder(),
    Object? use = const $CopyWithPlaceholder(),
    Object? usesSubdomain = const $CopyWithPlaceholder(),
    Object? status = const $CopyWithPlaceholder(),
    Object? suburl = const $CopyWithPlaceholder(),
    Object? projectId = const $CopyWithPlaceholder(),
  }) {
    return LAService(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      nameInt: nameInt == const $CopyWithPlaceholder() || nameInt == null
          ? _value.nameInt
          // ignore: cast_nullable_to_non_nullable
          : nameInt as String,
      iniPath: iniPath == const $CopyWithPlaceholder() || iniPath == null
          ? _value.iniPath
          // ignore: cast_nullable_to_non_nullable
          : iniPath as String,
      use: use == const $CopyWithPlaceholder() || use == null
          ? _value.use
          // ignore: cast_nullable_to_non_nullable
          : use as bool,
      usesSubdomain:
          usesSubdomain == const $CopyWithPlaceholder() || usesSubdomain == null
              ? _value.usesSubdomain
              // ignore: cast_nullable_to_non_nullable
              : usesSubdomain as bool,
      status: status == const $CopyWithPlaceholder()
          ? _value.status
          // ignore: cast_nullable_to_non_nullable
          : status as ServiceStatus?,
      suburl: suburl == const $CopyWithPlaceholder() || suburl == null
          ? _value.suburl
          // ignore: cast_nullable_to_non_nullable
          : suburl as String,
      projectId: projectId == const $CopyWithPlaceholder() || projectId == null
          ? _value.projectId
          // ignore: cast_nullable_to_non_nullable
          : projectId as String,
    );
  }
}

extension $LAServiceCopyWith on LAService {
  /// Returns a callable class that can be used as follows: `instanceOfLAService.copyWith(...)` or like so:`instanceOfLAService.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$LAServiceCWProxy get copyWith => _$LAServiceCWProxyImpl(this);
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
      'status': _$ServiceStatusEnumMap[instance.status]!,
      'projectId': instance.projectId,
    };

const _$ServiceStatusEnumMap = {
  ServiceStatus.unknown: 'unknown',
  ServiceStatus.success: 'success',
  ServiceStatus.failed: 'failed',
};

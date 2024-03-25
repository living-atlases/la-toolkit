// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$CmdCWProxy {
  Cmd id(String? id);

  Cmd type(CmdType type);

  Cmd properties(Map<String, dynamic> properties);

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Cmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Cmd(...).copyWith(id: 12, name: "My name")
  /// ````
  Cmd call({
    String? id,
    CmdType? type,
    Map<String, dynamic>? properties,
  });
}

/// Proxy class for `copyWith` functionality. This is a callable class and can be used as follows: `instanceOfCmd.copyWith(...)`. Additionally contains functions for specific fields e.g. `instanceOfCmd.copyWith.fieldName(...)`
class _$CmdCWProxyImpl implements _$CmdCWProxy {
  const _$CmdCWProxyImpl(this._value);

  final Cmd _value;

  @override
  Cmd id(String? id) => this(id: id);

  @override
  Cmd type(CmdType type) => this(type: type);

  @override
  Cmd properties(Map<String, dynamic> properties) =>
      this(properties: properties);

  @override

  /// This function **does support** nullification of nullable fields. All `null` values passed to `non-nullable` fields will be ignored. You can also use `Cmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Cmd(...).copyWith(id: 12, name: "My name")
  /// ````
  Cmd call({
    Object? id = const $CopyWithPlaceholder(),
    Object? type = const $CopyWithPlaceholder(),
    Object? properties = const $CopyWithPlaceholder(),
  }) {
    return Cmd(
      id: id == const $CopyWithPlaceholder()
          ? _value.id
          // ignore: cast_nullable_to_non_nullable
          : id as String?,
      type: type == const $CopyWithPlaceholder() || type == null
          ? _value.type
          // ignore: cast_nullable_to_non_nullable
          : type as CmdType,
      properties:
          properties == const $CopyWithPlaceholder() || properties == null
              ? _value.properties
              // ignore: cast_nullable_to_non_nullable
              : properties as Map<String, dynamic>,
    );
  }
}

extension $CmdCopyWith on Cmd {
  /// Returns a callable class that can be used as follows: `instanceOfCmd.copyWith(...)` or like so:`instanceOfCmd.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$CmdCWProxy get copyWith => _$CmdCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cmd _$CmdFromJson(Map<String, dynamic> json) => Cmd(
      id: json['id'] as String?,
      type: $enumDecode(_$CmdTypeEnumMap, json['type']),
      properties: json['properties'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$CmdToJson(Cmd instance) => <String, dynamic>{
      'id': instance.id,
      'type': _$CmdTypeEnumMap[instance.type],
      'properties': instance.properties,
    };

const Map<CmdType, String> _$CmdTypeEnumMap = <CmdType, String>{
  CmdType.brandingDeploy: 'brandingDeploy',
  CmdType.deploy: 'deploy',
  CmdType.preDeploy: 'preDeploy',
  CmdType.postDeploy: 'postDeploy',
  CmdType.laPipelines: 'laPipelines',
  CmdType.bash: 'bash',
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cmd.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

/// Proxy class for `CopyWith` functionality. This is a callable class and can be used as follows: `instanceOfCmd.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfCmd.copyWith.fieldName(...)`
class _CmdCWProxy {
  final Cmd _value;

  const _CmdCWProxy(this._value);

  /// This function does not support nullification of optional types, all `null` values passed to this function will be ignored. For nullification, use `Cmd(...).copyWithNull(...)` to set certain fields to `null`. Prefer `Cmd(...).copyWith.fieldName(...)` to override fields one at a time with nullification support.
  ///
  /// Usage
  /// ```dart
  /// Cmd(...).copyWith(id: 12, name: "My name")
  /// ````
  Cmd call({
    String? id,
    Map<String, dynamic>? properties,
    CmdType? type,
  }) {
    return Cmd(
      id: id ?? _value.id,
      properties: properties ?? _value.properties,
      type: type ?? _value.type,
    );
  }

  Cmd id(String? id) =>
      id == null ? _value._copyWithNull(id: true) : this(id: id);

  Cmd properties(Map<String, dynamic> properties) =>
      this(properties: properties);

  Cmd type(CmdType type) => this(type: type);
}

extension CmdCopyWith on Cmd {
  /// CopyWith feature provided by `copy_with_extension_gen` library. Returns a callable class and can be used as follows: `instanceOfclass Cmd.name.copyWith(...)`. Be aware that this kind of usage does not support nullification and all passed `null` values will be ignored. Prefer to copy the instance with a specific field change that handles nullification of fields correctly, e.g. like this:`instanceOfclass Cmd.name.copyWith.fieldName(...)`
  _CmdCWProxy get copyWith => _CmdCWProxy(this);

  Cmd _copyWithNull({
    bool id = false,
  }) {
    return Cmd(
      id: id == true ? null : this.id,
      properties: properties,
      type: type,
    );
  }
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

const _$CmdTypeEnumMap = {
  CmdType.brandingDeploy: 'brandingDeploy',
  CmdType.deploy: 'deploy',
  CmdType.preDeploy: 'preDeploy',
  CmdType.postDeploy: 'postDeploy',
  CmdType.laPipelines: 'laPipelines',
  CmdType.bash: 'bash',
};

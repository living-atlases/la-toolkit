// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laService.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServiceCopyWith on LAService {
  LAService copyWith({
    String iniPath,
    String name,
    dynamic servers,
    String suburl,
    bool usesSubdomain,
  }) {
    return LAService(
      iniPath: iniPath ?? this.iniPath,
      name: name ?? this.name,
      servers: servers ?? this.servers,
      suburl: suburl ?? this.suburl,
      usesSubdomain: usesSubdomain ?? this.usesSubdomain,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAService _$LAServiceFromJson(Map<String, dynamic> json) {
  return LAService(
    name: json['name'] as String,
    iniPath: json['iniPath'] as String,
    usesSubdomain: json['usesSubdomain'] as bool,
    servers: json['servers'],
    suburl: json['suburl'] as String,
  );
}

Map<String, dynamic> _$LAServiceToJson(LAService instance) => <String, dynamic>{
      'name': instance.name,
      'iniPath': instance.iniPath,
      'usesSubdomain': instance.usesSubdomain,
      'servers': instance.servers,
      'suburl': instance.suburl,
    };

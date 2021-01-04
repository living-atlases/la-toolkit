// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laService.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAServiceCopyWith on LAService {
  LAService copyWith({
    String iniPath,
    String name,
    List<LAServer> servers,
    String suburl,
    bool use,
    bool usesSubdomain,
  }) {
    return LAService(
      iniPath: iniPath ?? this.iniPath,
      name: name ?? this.name,
      servers: servers ?? this.servers,
      suburl: suburl ?? this.suburl,
      use: use ?? this.use,
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
    use: json['use'] as bool,
    usesSubdomain: json['usesSubdomain'] as bool,
    servers: (json['servers'] as List)
        ?.map((e) =>
            e == null ? null : LAServer.fromJson(e as Map<String, dynamic>))
        ?.toList(),
    suburl: json['suburl'] as String,
  );
}

Map<String, dynamic> _$LAServiceToJson(LAService instance) => <String, dynamic>{
      'name': instance.name,
      'iniPath': instance.iniPath,
      'use': instance.use,
      'usesSubdomain': instance.usesSubdomain,
      'servers': instance.servers?.map((e) => e?.toJson())?.toList(),
      'suburl': instance.suburl,
    };

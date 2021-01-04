// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'laProject.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension LAProjectCopyWith on LAProject {
  LAProject copyWith({
    String domain,
    String longName,
    List<LAServer> servers,
    List<LAService> services,
    String shortName,
    bool useSSL,
    dynamic uuid,
  }) {
    return LAProject(
      domain: domain ?? this.domain,
      longName: longName ?? this.longName,
      servers: servers ?? this.servers,
      services: services ?? this.services,
      shortName: shortName ?? this.shortName,
      useSSL: useSSL ?? this.useSSL,
      uuid: uuid ?? this.uuid,
    );
  }
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LAProject _$LAProjectFromJson(Map<String, dynamic> json) {
  return LAProject(
    uuid: json['uuid'],
    longName: json['longName'] as String,
    shortName: json['shortName'] as String,
    domain: json['domain'] as String,
    useSSL: json['useSSL'] as bool,
    servers: (json['servers'] as List)
        .map((e) => LAServer.fromJson(e as Map<String, dynamic>))
        .toList(),
    services: (json['services'] as List)
        .map((e) => LAService.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$LAProjectToJson(LAProject instance) => <String, dynamic>{
      'uuid': instance.uuid,
      'longName': instance.longName,
      'shortName': instance.shortName,
      'domain': instance.domain,
      'useSSL': instance.useSSL,
      'servers': instance.servers,
      'services': instance.services,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hostServicesChecks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostsServicesChecks _$HostsServicesChecksFromJson(Map<String, dynamic> json) {
  return HostsServicesChecks()
    ..map = (json['map'] as Map<String, dynamic>).map(
      (k, e) =>
          MapEntry(k, HostServicesChecks.fromJson(e as Map<String, dynamic>)),
    );
}

Map<String, dynamic> _$HostsServicesChecksToJson(
        HostsServicesChecks instance) =>
    <String, dynamic>{
      'map': instance.map.map((k, e) => MapEntry(k, e.toJson())),
    };

HostServicesChecks _$HostServicesChecksFromJson(Map<String, dynamic> json) {
  return HostServicesChecks();
}

Map<String, dynamic> _$HostServicesChecksToJson(HostServicesChecks instance) =>
    <String, dynamic>{};

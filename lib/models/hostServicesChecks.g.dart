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
    )
    ..checks = (json['checks'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          k,
          (e as List<dynamic>)
              .map((e) => HostServiceCheck.fromJson(e as Map<String, dynamic>))
              .toList()),
    );
}

Map<String, dynamic> _$HostsServicesChecksToJson(
        HostsServicesChecks instance) =>
    <String, dynamic>{
      'map': instance.map.map((k, e) => MapEntry(k, e.toJson())),
      'checks': instance.checks
          .map((k, e) => MapEntry(k, e.map((e) => e.toJson()).toList())),
    };

HostServicesChecks _$HostServicesChecksFromJson(Map<String, dynamic> json) {
  return HostServicesChecks();
}

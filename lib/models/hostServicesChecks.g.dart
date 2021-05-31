// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hostServicesChecks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostsServicesChecks _$HostsServicesChecksFromJson(Map<String, dynamic> json) {
  return HostsServicesChecks()
    ..checks = (json['checks'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(
          k,
          (e as Map<String, dynamic>).map(
            (k, e) => MapEntry(
                k, HostServiceCheck.fromJson(e as Map<String, dynamic>)),
          )),
    );
}

Map<String, dynamic> _$HostsServicesChecksToJson(
        HostsServicesChecks instance) =>
    <String, dynamic>{
      'checks': instance.checks
          .map((k, e) => MapEntry(k, e.map((k, e) => MapEntry(k, e.toJson())))),
    };

HostServicesChecks _$HostServicesChecksFromJson(Map<String, dynamic> json) {
  return HostServicesChecks();
}

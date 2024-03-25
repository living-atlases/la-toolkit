// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hostServicesChecks.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HostsServicesChecks _$HostsServicesChecksFromJson(Map<String, dynamic> json) =>
    HostsServicesChecks()
      ..checks = (json['checks'] as Map<String, dynamic>).map(
        (String k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (String k, e) => MapEntry(
                  k, HostServiceCheck.fromJson(e as Map<String, dynamic>)),
            )),
      );

Map<String, dynamic> _$HostsServicesChecksToJson(
        HostsServicesChecks instance) =>
    <String, dynamic>{
      'checks': instance.checks
          .map((String k, Map<String, HostServiceCheck> e) => MapEntry(k, e.map((String k, HostServiceCheck e) => MapEntry(k, e.toJson())))),
    };

HostServicesChecks _$HostServicesChecksFromJson(Map<String, dynamic> json) =>
    HostServicesChecks();

import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

part 'host_service_check.g.dart';

enum ServiceCheckType { tcp, udp, url, other }

extension ServiceCheckTypeToString on ServiceCheckType {
  String toS() {
    return toString().split('.').last;
  }
}

@JsonSerializable(explicitToJson: true)
class HostServiceCheck {
  HostServiceCheck(
      {String? id,
      required this.name,
      required this.type,
      this.host = 'localhost',
      HashSet<String>? serviceDeploys,
      HashSet<String>? services,
      this.args = ''})
      : id = id ?? ObjectId().toString(),
        serviceDeploys = serviceDeploys ?? HashSet<String>(),
        services = services ?? HashSet<String>();

  factory HostServiceCheck.fromJson(Map<String, dynamic> json) =>
      _$HostServiceCheckFromJson(json);
  String id;
  String name;
  ServiceCheckType type;
  String host; // localhost or other
  String args;

  // Ids
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  HashSet<String> serviceDeploys;
  @JsonKey(fromJson: _fromJson, toJson: _toJson)
  HashSet<String> services;

  static HashSet<String> _fromJson(List<dynamic>? json) {
    return json == null
        ? HashSet<String>()
        : HashSet<String>.from(json.map((dynamic e) => e as String));
  }

  static List<String> _toJson(HashSet<String> set) {
    return set.toList();
  }

  Map<String, dynamic> toJson() => _$HostServiceCheckToJson(this);
}

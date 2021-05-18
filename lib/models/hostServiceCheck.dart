import 'dart:collection';

import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

part 'hostServiceCheck.g.dart';

enum ServiceCheckType { tcp, udp, url, other }

extension ServiceCheckTypeToString on ServiceCheckType {
  String toS() {
    return this.toString().split('.').last;
  }
}

@JsonSerializable(explicitToJson: true)
class HostServiceCheck {
  String id;
  ServiceCheckType type;
  String host; // localhost or other
  String args;
  // Ids
  HashSet<String> serviceDeploys;
  HashSet<String> services;

  HostServiceCheck(
      {String? id,
      required this.type,
      this.host: "localhost",
      serviceDeploys,
      services,
      this.args: ""})
      : id = id ?? ObjectId().toString(),
        serviceDeploys = serviceDeploys ?? HashSet<String>(),
        services = services ?? HashSet<String>();

  Map<String, dynamic> toJson() => _$HostServiceCheckToJson(this);

  factory HostServiceCheck.fromJson(Map<String, dynamic> json) =>
      _$HostServiceCheckFromJson(json);
}

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectid/objectid.dart';

import '../utils/StringUtils.dart';

part 'cmd.g.dart';

// Base cmd

enum CmdType {
  brandingDeploy,
  deploy,
  preDeploy,
  postDeploy,
  laPipelines,
  bash
}

extension ParseToString on CmdType {
  String toS() {
    return toString().split('.').last;
  }

  bool get isAnsibleDeploy =>
      this == CmdType.deploy ||
      this == CmdType.preDeploy ||
      this == CmdType.postDeploy;
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class Cmd {

  Cmd({String? id, required this.type, required this.properties})
      : id = id ?? ObjectId().toString();

  factory Cmd.fromJson(Map<String, dynamic> json) => _$CmdFromJson(json);
  final String id;
  final CmdType type;
  final Map<String, dynamic> properties;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cmd &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          properties == other.properties;

  @override
  int get hashCode => id.hashCode ^ type.hashCode ^ properties.hashCode;

  String getTitle() => '${StringUtils.capitalize(type.toS())} Results';
  Map<String, dynamic> toJson() => _$CmdToJson(this);
}

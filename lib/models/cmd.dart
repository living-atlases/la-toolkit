import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

part 'cmd.g.dart';

// Base cmd

enum CmdType { ansible, deploy, preDeploy, postDeploy, laPipelines, bash }

extension ParseToString on CmdType {
  String toS() {
    return this.toString().split('.').last;
  }

  bool get isDeploy =>
      this == CmdType.deploy ||
      this == CmdType.preDeploy ||
      this == CmdType.postDeploy;
}

@JsonSerializable(explicitToJson: true)
@CopyWith()
class Cmd {
  // @JsonKey(name: 'type')
  final CmdType type;
  // @JsonKey(name: 'properties')
  final Map<String, dynamic> properties;

  Cmd({required this.type, required this.properties});

  String getTitle() => "${StringUtils.capitalize(type.toS())} Results";

  factory Cmd.fromJson(Map<String, dynamic> json) => _$CmdFromJson(json);
  Map<String, dynamic> toJson() => _$CmdToJson(this);
}

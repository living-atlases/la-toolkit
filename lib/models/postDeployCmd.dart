import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'deployCmd.dart';

part 'postDeployCmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PostDeployCmd extends DeployCmd {
  bool configurePostfix;

  PostDeployCmd(
      {this.configurePostfix = false,
      limitToServers,
      skipTags,
      tags,
      advanced = false,
      continueEvenIfFails = false,
      debug = false,
      dryRun = false})
      : super(
            deployServices: ['all'],
            limitToServers: limitToServers,
            skipTags: skipTags,
            tags: tags,
            advanced: advanced,
            onlyProperties: false,
            continueEvenIfFails: continueEvenIfFails,
            debug: debug,
            dryRun: dryRun);

  factory PostDeployCmd.fromJson(Map<String, dynamic> json) =>
      _$PostDeployCmdFromJson(json);
  Map<String, dynamic> toJson() => _$PostDeployCmdToJson(this);
}

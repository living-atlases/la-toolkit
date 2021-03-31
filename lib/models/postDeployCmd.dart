import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'deployCmd.dart';

part 'postDeployCmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PostDeployCmd extends DeployCmd {
  bool configurePostfix;

  static const List<String> postDeployVariables = [
    "email_sender",
    "email_sender_password",
    "email_sender_server",
    "email_sender_server_port",
    "email_sender_server_tls"
  ];

  PostDeployCmd(
      {this.configurePostfix = true,
      List<String>? limitToServers,
      List<String>? skipTags,
      List<String>? tags,
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

  @override
  String toString() {
    List<String> tasks = [];
    if (configurePostfix) tasks.add('configure Postfix');
    return 'Post-deploy tasks (${tasks.join(', ')}${toStringServers()})';
  }

  List<String> get postTags {
    List<String> tags = [];
    if (configurePostfix) tags.add("post-task-postfix");
    return tags;
  }

  @override
  String getTitle() => "Post-Deployment Results";
}

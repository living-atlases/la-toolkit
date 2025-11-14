import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/string_utils.dart';
import 'deployCmd.dart';

part 'post_deploy_cmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PostDeployCmd extends DeployCmd {
  PostDeployCmd(
      {this.configurePostfix = true,
      super.limitToServers,
      super.skipTags,
      super.tags,
      super.advanced,
      super.continueEvenIfFails,
      super.debug,
      super.dryRun})
      : super(deployServices: <String>['all'], onlyProperties: false);

  factory PostDeployCmd.fromJson(Map<String, dynamic> json) =>
      _$PostDeployCmdFromJson(json);
  bool configurePostfix;

  static const List<String> postDeployVariables = <String>[
    'email_sender',
    'email_sender_password',
    'email_sender_server',
    'email_sender_server_port',
    'email_sender_server_tls'
  ];

  @override
  Map<String, dynamic> toJson() => _$PostDeployCmdToJson(this);

  @override
  String get desc {
    final List<String> tasks = <String>[];
    if (configurePostfix) tasks.add('configure postfix');
    final String result =
        'Post-deploy tasks (${tasks.join(', ')}${toStringServers()})';
    return dryRun ? 'Dry run $result' : StringUtils.capitalize(result);
  }

  @override
  List<String> get tags {
    final List<String> tags = <String>[];
    if (configurePostfix) {
      tags.add('post-task-postfix');
    }
    return tags;
  }

  @override
  String getTitle() => 'Post-Deployment Results';
}

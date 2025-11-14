import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/string_utils.dart';
import 'deployCmd.dart';

part 'pre_deploy_cmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PreDeployCmd extends DeployCmd {
  PreDeployCmd(
      {this.addAnsibleUser = false,
      this.addSshKeys = false,
      this.giveSudo = false,
      this.etcHosts = true,
      this.solrLimits = true,
      this.addAdditionalDeps = true,
      bool? rootBecome,
      super.limitToServers,
      super.skipTags,
      super.tags,
      super.advanced,
      super.continueEvenIfFails,
      super.debug,
      super.dryRun})
      : rootBecome = rootBecome ?? false,
        super(deployServices: <String>['all'], onlyProperties: false);

  factory PreDeployCmd.fromJson(Map<String, dynamic> json) =>
      _$PreDeployCmdFromJson(json);
  bool addAnsibleUser;
  bool addSshKeys;
  bool giveSudo;
  bool etcHosts;
  bool solrLimits;
  bool addAdditionalDeps;
  bool rootBecome;

  @override
  Map<String, dynamic> toJson() => _$PreDeployCmdToJson(this);

  @override
  List<String> get tags {
    final List<String> tags = <String>[];
    if (addAnsibleUser) tags.add('pre-task-def-user');
    if (addSshKeys) tags.add('pre-task-ssh-keys');
    if (giveSudo) tags.add('pre-task-sudo');
    if (etcHosts) tags.add('pre-task-etc-hosts');
    if (solrLimits) tags.add('pre-task-solr-limits');
    if (addAdditionalDeps) tags.add('pre-task-deps');
    return tags;
  }

  @override
  String get desc {
    final List<String> tasks = <String>[];
    if (addAnsibleUser) {
      tasks.add('add default user');
    }
    if (addSshKeys) {
      tasks.add('add ssh keys');
    }
    if (giveSudo) {
      tasks.add('add sudo permissions');
    }
    if (etcHosts) {
      tasks.add("setup '/etc/hosts'");
    }
    if (solrLimits) {
      tasks.add('setup solr limits');
    }
    if (addAdditionalDeps) {
      tasks.add('additional deps install');
    }
    if (rootBecome) {
      tasks.add('as root');
    }
    final String result =
        'pre-deploy tasks (${tasks.join(', ')}${toStringServers()})';
    return dryRun ? 'Dry run $result' : StringUtils.capitalize(result);
  }

  @override
  String getTitle() => 'Pre-Deployment Results';
}

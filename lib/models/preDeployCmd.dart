import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'deployCmd.dart';

part 'preDeployCmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PreDeployCmd extends DeployCmd {
  bool addAnsibleUser;
  bool addSshKeys;
  bool giveSudo;
  bool etcHosts;
  bool solrLimits;
  bool addAdditionalDeps;

  PreDeployCmd(
      {this.addAnsibleUser = false,
      this.addSshKeys = false,
      this.giveSudo = false,
      this.etcHosts = true,
      this.solrLimits = true,
      this.addAdditionalDeps = true,
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

  factory PreDeployCmd.fromJson(Map<String, dynamic> json) =>
      _$PreDeployCmdFromJson(json);
  Map<String, dynamic> toJson() => _$PreDeployCmdToJson(this);

  List<String> get preTags {
    List<String> tags = [];
    if (addAnsibleUser) tags.add("pre-task-def-user");
    if (addSshKeys) tags.add("pre-task-ssh-keys");
    if (giveSudo) tags.add("pre-task-sudo");
    if (etcHosts) tags.add("pre-task-etc-hosts");
    if (solrLimits) tags.add("pre-task-solr-limits");
    if (addAdditionalDeps) tags.add("pre-task-deps");
    return tags;
  }

  @override
  String toString() {
    List<String> tasks = [];
    if (addAnsibleUser) tasks.add('add default user');
    if (addSshKeys) tasks.add('add ssh keys');
    if (giveSudo) tasks.add('add sudo permissions');
    if (etcHosts) tasks.add("setup '/etc/hosts'");
    if (solrLimits) tasks.add('setup solr limits');
    if (addAdditionalDeps) tasks.add('additional deps install');
    return 'Pre-deploy tasks (${tasks.join(', ')}${toStringServers()})';
  }

  @override
  String getTitle() => "Pre-Deployment Results";
}

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import 'deployCmd.dart';

part 'preDeployCmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class PreDeployCmd extends DeployCmd {
  bool addUbuntuUser;
  bool giveSudo;
  bool etcHost;
  bool solrLimits;

  PreDeployCmd(
      {this.addUbuntuUser = true,
      this.giveSudo = true,
      this.etcHost = true,
      this.solrLimits = true,
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

  factory PreDeployCmd.fromJson(Map<String, dynamic> json) =>
      _$PreDeployCmdFromJson(json);
  Map<String, dynamic> toJson() => _$PreDeployCmdToJson(this);

  @override
  String toString() {
    List<String> tasks = [];
    if (addUbuntuUser) tasks.add('add default user');
    if (giveSudo) tasks.add('add sudo permissions');
    if (etcHost) tasks.add("setup '/etc/hosts'");
    if (solrLimits) tasks.add('setup solrs limits');
    return 'Pre-deploy tasks (${tasks.join(', ')}${toStringServers()})';
  }
}

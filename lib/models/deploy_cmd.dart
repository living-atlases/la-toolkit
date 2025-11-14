import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/string_utils.dart';
import './common_cmd.dart';
import './la_service_constants.dart';
import './la_service_desc.dart';

part 'deploy_cmd.g.dart';

// Typical ansible cmd

@JsonSerializable(explicitToJson: true)
@CopyWith()
class DeployCmd extends CommonCmd {
  DeployCmd({
    List<String>? deployServices,
    List<String>? limitToServers,
    List<String>? skipTags,
    List<String>? tags,
    this.advanced = false,
    this.onlyProperties = false,
    this.continueEvenIfFails = false,
    this.debug = false,
    this.dryRun = false,
  })  : deployServices = deployServices ?? <String>[],
        limitToServers = limitToServers ?? <String>[],
        skipTags = skipTags ?? <String>[],
        tags = tags ??
            <String>[] /* super(type: CmdType.deploy, properties: {} )*/;

  factory DeployCmd.fromJson(Map<String, dynamic> json) =>
      _$DeployCmdFromJson(json);
  List<String> deployServices;
  List<String> limitToServers;
  List<String> skipTags;
  List<String> tags;
  bool advanced;
  bool onlyProperties;
  bool continueEvenIfFails;
  bool debug;
  bool dryRun;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeployCmd &&
          runtimeType == other.runtimeType &&
          const ListEquality().equals(deployServices, other.deployServices) &&
          const ListEquality().equals(limitToServers, other.limitToServers) &&
          const ListEquality().equals(skipTags, other.skipTags) &&
          const ListEquality().equals(tags, other.tags) &&
          advanced == other.advanced &&
          onlyProperties == other.onlyProperties &&
          continueEvenIfFails == other.continueEvenIfFails &&
          debug == other.debug &&
          dryRun == other.dryRun;

  @override
  int get hashCode =>
      const ListEquality().hash(deployServices) ^
      const ListEquality().hash(limitToServers) ^
      const ListEquality().hash(skipTags) ^
      const ListEquality().hash(tags) ^
      advanced.hashCode ^
      onlyProperties.hashCode ^
      continueEvenIfFails.hashCode ^
      debug.hashCode ^
      dryRun.hashCode;

  @override
  String toString() {
    return 'DeployCmd{deployServices: $deployServices, limitToServers: $limitToServers, skipTags: $skipTags, tags: $tags, advanced: $advanced, onlyProperties: $onlyProperties, continueEvenIfFails: $continueEvenIfFails, debug: $debug, dryRun: $dryRun}';
  }

  String get desc {
    final bool isAll =
        const ListEquality().equals(deployServices, <String>['all']);
    String services = 'deploy of';

    final int serviceLength = deployServices.length;
    if (isAll) {
      services = 'full deploy';
    } else if (serviceLength <= 5) {
      final List<String> servicesForHuman = deployServices
          .map((String serviceName) => serviceName == 'lists'
              ? LAServiceDesc.get(speciesLists).name
              : LAServiceDesc.get(serviceName).name)
          .toList();
      servicesForHuman
          .asMap()
          .forEach((int i, String value) => services += i == 0
              ? ' $value'
              : i < serviceLength - 1
                  ? ', $value'
                  : ' and $value');
      services += ' service${serviceLength > 1 ? 's' : ''}';
    } else {
      services += ' some services';
    }

    final String servers = toStringServers();
    String prefix = '';
    final List<String> lTags = List<String>.from(tags);
    if (onlyProperties) {
      lTags.add('properties');
    }
    if (lTags.isNotEmpty && lTags.length <= 3) {
      prefix += ' (tags: ${lTags.join(', ')})';
    } else if (lTags.length > 3) {
      prefix = ' (only some tasks)';
    }
    String result = '$services$servers$prefix';
    result = dryRun ? 'Dry run $result' : StringUtils.capitalize(result);
    return result;
  }

  String toStringServers() {
    String servers = '';
    if (limitToServers.isEmpty) {
      servers = '';
    } else if (limitToServers.length <= 3) {
      servers += ' in ${limitToServers.join(', ')}';
    } else {
      servers = ' in some servers';
    }
    return servers;
  }

  bool get isFullDeploy => deployServices.contains('all');

  Map<String, dynamic> toJson() => _$DeployCmdToJson(this);

  String getTitle() => 'Deployment Results';
}

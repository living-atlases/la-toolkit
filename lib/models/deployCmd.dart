import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/commonCmd.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';

part 'deployCmd.g.dart';

// Typical ansible cmd

@JsonSerializable(explicitToJson: true)
@CopyWith()
class DeployCmd extends CommonCmd {
  List<String> deployServices;
  List<String> limitToServers;
  List<String> skipTags;
  List<String> tags;
  bool advanced;
  bool onlyProperties;
  bool continueEvenIfFails;
  bool debug;
  bool dryRun;

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
  })  : deployServices = deployServices ?? [],
        limitToServers = limitToServers ?? [],
        skipTags = skipTags ?? [],
        tags = tags ?? [] /* super(type: CmdType.deploy, properties: {} )*/;

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
    bool isAll = const ListEquality().equals(deployServices, ['all']);
    String services = 'deploy of';

    var serviceLength = deployServices.length;
    if (isAll) {
      services = 'full deploy';
    } else if (serviceLength <= 5) {
      List<String> servicesForHuman = deployServices
          .map((serviceName) => serviceName == "lists"
              ? LAServiceDesc.get(speciesLists).name
              : LAServiceDesc.get(serviceName).name)
          .toList();
      servicesForHuman.asMap().forEach((i, value) => services += i == 0
          ? ' $value'
          : i < serviceLength - 1
              ? ', $value'
              : ' and $value');
      services += ' service${serviceLength > 1 ? 's' : ''}';
    } else {
      services += ' some services';
    }

    String servers = toStringServers();
    String prefix = '';
    List<String> lTags = List<String>.from(tags);
    if (onlyProperties) lTags.add('properties');
    if (lTags.isNotEmpty && lTags.length <= 3) {
      prefix += ' (tags: ${lTags.join(', ')})';
    } else if (lTags.length > 3) {
      prefix = ' (only some tasks)';
    }
    String result = "$services$servers$prefix";
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

  factory DeployCmd.fromJson(Map<String, dynamic> json) =>
      _$DeployCmdFromJson(json);

  Map<String, dynamic> toJson() => _$DeployCmdToJson(this);

  String getTitle() => "Deployment Results";
}

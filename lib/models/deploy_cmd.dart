import 'package:collection/collection.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:json_annotation/json_annotation.dart';

import '../utils/string_utils.dart';
import './common_cmd.dart';
import './la_service_constants.dart';
import './la_service_desc.dart';

part 'deploy_cmd.g.dart';

@JsonSerializable(explicitToJson: true)
@CopyWith()
class DeployCmd extends CommonCmd {
  DeployCmd({
    List<String>? deployServices,
    List<String>? limitToServers,
    List<String>? skipTags,
    List<String>? tags,
    List<String>? skipServices,
    this.advanced = false,
    this.onlyProperties = false,
    this.continueEvenIfFails = false,
    this.debug = false,
    this.dryRun = false,
    this.dockerCompose = false,
  }) : deployServices = deployServices ?? <String>[],
       limitToServers = limitToServers ?? <String>[],
       skipTags = skipTags ?? <String>[],
       tags = tags ?? <String>[],
       skipServices = skipServices ?? <String>[];

  factory DeployCmd.fromJson(Map<String, dynamic> json) =>
      _$DeployCmdFromJson(json);
  // deployServices, skipServices, onlyProperties and dockerCompose are hardcoded
  // (or not exposed) in the PreDeployCmd/PostDeployCmd constructors, so
  // json_serializable sets them via cascade with a non-nullable cast. defaultValue
  // keeps that generated cast null-safe for old history entries that predate these
  // fields (e.g. entries stored before skipServices/dockerCompose existed).
  @JsonKey(defaultValue: <String>[])
  List<String> deployServices;
  List<String> limitToServers;
  List<String> skipTags;
  List<String> tags;

  // Docker-compose deploys are monolithic (site.yml against the docker_compose
  // group). Granularity is expressed as a deny-list of inventory groups passed
  // to the la-compose role as `skip_services`, not as an allow-list of services.
  @JsonKey(defaultValue: <String>[])
  List<String> skipServices;
  bool advanced;
  @JsonKey(defaultValue: false)
  bool onlyProperties;
  bool continueEvenIfFails;
  bool debug;
  bool dryRun;

  // When true the backend targets la-docker-compose (--ladocker + site.yml,
  // auto_deploy=true) instead of the per-service ala-install playbooks.
  @JsonKey(defaultValue: false)
  bool dockerCompose;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeployCmd &&
          runtimeType == other.runtimeType &&
          const ListEquality<String>().equals(
            deployServices,
            other.deployServices,
          ) &&
          const ListEquality<String>().equals(
            limitToServers,
            other.limitToServers,
          ) &&
          const ListEquality<String>().equals(skipTags, other.skipTags) &&
          const ListEquality<String>().equals(tags, other.tags) &&
          const ListEquality<String>().equals(
            skipServices,
            other.skipServices,
          ) &&
          advanced == other.advanced &&
          onlyProperties == other.onlyProperties &&
          continueEvenIfFails == other.continueEvenIfFails &&
          debug == other.debug &&
          dryRun == other.dryRun &&
          dockerCompose == other.dockerCompose;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode =>
      const ListEquality<String>().hash(deployServices) ^
      const ListEquality<String>().hash(limitToServers) ^
      const ListEquality<String>().hash(skipTags) ^
      const ListEquality<String>().hash(tags) ^
      const ListEquality<String>().hash(skipServices) ^
      advanced.hashCode ^
      onlyProperties.hashCode ^
      continueEvenIfFails.hashCode ^
      debug.hashCode ^
      dryRun.hashCode ^
      dockerCompose.hashCode;

  @override
  String toString() {
    return 'DeployCmd{deployServices: $deployServices, limitToServers: $limitToServers, skipTags: $skipTags, tags: $tags, skipServices: $skipServices, advanced: $advanced, onlyProperties: $onlyProperties, continueEvenIfFails: $continueEvenIfFails, debug: $debug, dryRun: $dryRun, dockerCompose: $dockerCompose}';
  }

  String get desc {
    final bool isAll = const ListEquality<String>().equals(
      deployServices,
      <String>['all'],
    );
    String services = 'deploy of';

    final int serviceLength = deployServices.length;
    if (isAll) {
      services = 'full deploy';
    } else if (serviceLength <= 5) {
      final List<String> servicesForHuman = deployServices
          .map(
            (String serviceName) => serviceName == 'lists'
                ? LAServiceDesc.get(speciesLists).name
                : LAServiceDesc.get(serviceName).name,
          )
          .toList();
      servicesForHuman.asMap().forEach(
        (int i, String value) => services += i == 0
            ? ' $value'
            : i < serviceLength - 1
            ? ', $value'
            : ' and $value',
      );
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

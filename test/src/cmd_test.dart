import 'package:la_toolkit/models/cmd.dart';
import 'package:la_toolkit/models/cmd_history_entry.dart';
import 'package:la_toolkit/models/deploy_cmd.dart';
import 'package:la_toolkit/models/la_service_constants.dart';
import 'package:la_toolkit/models/la_service_name.dart';
import 'package:la_toolkit/models/pipelines_cmd.dart';
import 'package:la_toolkit/models/post_deploy_cmd.dart';
import 'package:la_toolkit/models/pre_deploy_cmd.dart';

import 'package:test/test.dart';

void main() {
  test('Test cmd to String', () {
    final DeployCmd cmd = DeployCmd();
    final String all = LAServiceName.all.toS();

    cmd.deployServices = <String>[all];
    expect(cmd.desc, equals('Full deploy'));
    cmd.deployServices = <String>[collectory];
    expect(cmd.desc, equals('Deploy of collections service'));
    cmd.deployServices = <String>[collectory, bie];
    expect(cmd.desc, equals('Deploy of collections and species services'));
    cmd.limitToServers = <String>['vm1'];
    expect(
        cmd.desc, equals('Deploy of collections and species services in vm1'));
    cmd.tags = <String>['tomcat'];
    expect(
        cmd.desc,
        equals(
            'Deploy of collections and species services in vm1 (tags: tomcat)'));
    cmd.tags = <String>['tomcat', 'properties', 'nginx'];
    cmd.deployServices = <String>[collectory, bie, spatial, solr];
    expect(
        cmd.desc,
        equals(
            'Deploy of collections, species, spatial and solr services in vm1 (tags: tomcat, properties, nginx)'));
    cmd.deployServices = <String>[
      collectory,
      bie,
      spatial,
      solr,
      biocacheService,
      alaHub
    ];
    expect(
        cmd.desc,
        equals(
            'Deploy of some services in vm1 (tags: tomcat, properties, nginx)'));
    cmd.onlyProperties = true;
    cmd.tags = <String>[];
    expect(
        cmd.desc, equals('Deploy of some services in vm1 (tags: properties)'));
    cmd.tags = <String>['tomcat', 'properties', 'nginx', 'java'];
    cmd.deployServices = <String>[collectory, bie];
    expect(
        cmd.desc,
        equals(
            'Deploy of collections and species services in vm1 (only some tasks)'));
    cmd.dryRun = true;
    cmd.onlyProperties = false;
    cmd.tags = <String>[];
    expect(cmd.desc,
        equals('Dry run deploy of collections and species services in vm1'));
  });

  test('Test pre-cmd to String', () {
    final PreDeployCmd cmd = PreDeployCmd();
    cmd.addAnsibleUser = true;
    cmd.giveSudo = true;
    cmd.addSshKeys = true;
    expect(
        cmd.desc,
        equals(
            "Pre-deploy tasks (add default user, add ssh keys, add sudo permissions, setup '/etc/hosts', setup solr limits, additional deps install)"));
    cmd.dryRun = true;
    expect(
        cmd.desc,
        equals(
            "Dry run pre-deploy tasks (add default user, add ssh keys, add sudo permissions, setup '/etc/hosts', setup solr limits, additional deps install)"));
  });

  test('Test post-cmd to String', () {
    final PostDeployCmd cmd = PostDeployCmd();
    cmd.configurePostfix = true;
    expect(cmd.desc, equals('Post-deploy tasks (configure postfix)'));
  });

  test('cmdEntry server retrieve', () {
    final Map<String, dynamic> cmdEntryJ = <String, Object>{
      'createdAt': 1617609595413,
      'updatedAt': 1617609595413,
      'id': '6084263ae185829aa740c3ad',
      'logsPrefix': 'la-test',
      'logsSuffix': '2021-04-05_09:58:53',
      'invDir': 'la-test/la-test-pre-deploy/',
      'rawCmd':
          'ansible-playbook -i ../la-test-inventories/la-test-inventory.ini -i inventory.yml pre-deploy.yml --tags pre-task-solr-limits,pre-task-deps',
      'result': 'success',
      'projectId': '6084263ae185829aa740c368',
      'cmd': <String, Object>{
        'createdAt': 1617609595413,
        'updatedAt': 1617609595413,
        'id': '6084263ae185829aa740c3ae',
        'type': 'preDeploy',
        'properties': <String, Object>{
          'deployServices': <String>['all'],
          'limitToServers': <String>['ala-install-test-1'],
          'skipTags': <String>[],
          'tags': <String>[],
          'advanced': false,
          'onlyProperties': false,
          'continueEvenIfFails': false,
          'debug': false,
          'dryRun': false,
          'addAnsibleUser': false,
          'addSshKeys': false,
          'giveSudo': false,
          'etcHosts': false,
          'solrLimits': true,
          'addAdditionalDeps': true
        },
        'cmdHistoryEntryId': '6084263ae185829aa740c3ad'
      }
    };
    final CmdHistoryEntry cmdEntry = CmdHistoryEntry.fromJson(cmdEntryJ);
    expect(cmdEntry.cmd.type, equals(CmdType.preDeploy));
    expect(
        cmdEntry.deployCmd!.desc,
        equals(
            'Pre-deploy tasks (setup solr limits, additional deps install in ala-install-test-1)'));
  });

  test('Test pipeline cmd to String', () {
    final PipelinesCmd cmd = PipelinesCmd(master: 'test');
    cmd.allDrs = true;
    expect(cmd.desc, equals('Pipelines data processing of all drs'));
    cmd.steps = <String>{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
    expect(
        cmd.desc, equals('Pipelines data processing of all drs (some steps)'));
    cmd.steps = <String>{'interpret', 'validate', 'dwca-export'};
    expect(
        cmd.desc,
        equals(
            'Pipelines data processing of all drs (interpret, validate and dwca-export steps)'));
    cmd.steps = <String>{'interpret', 'validate'};
    expect(
        cmd.desc,
        equals(
            'Pipelines data processing of all drs (interpret and validate steps)'));
    cmd.steps = const <String>{'interpret'};
    expect(cmd.desc,
        equals('Pipelines data processing of all drs (interpret step)'));
    cmd.dryRun = true;
    cmd.steps = <String>{};
    expect(cmd.desc, equals('Dry run of Pipelines data processing of all drs'));
    cmd.dryRun = true;
    cmd.steps = <String>{};
    cmd.allSteps = true;
    expect(cmd.desc, equals('Dry run of Pipelines data processing of all drs'));
  });
}

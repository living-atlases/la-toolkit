import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/cmd.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/pipelinesCmd.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:test/test.dart';

void main() {
  test('Test cmd to String', () {
    DeployCmd cmd = DeployCmd();
    final all = LAServiceName.all.toS();

    cmd.deployServices = [all];
    expect(cmd.desc, equals("Full deploy"));
    cmd.deployServices = [collectory];
    expect(cmd.desc, equals("Deploy of collections service"));
    cmd.deployServices = [collectory, bie];
    expect(cmd.desc, equals("Deploy of collections and species services"));
    cmd.limitToServers = ['vm1'];
    expect(
        cmd.desc, equals("Deploy of collections and species services in vm1"));
    cmd.tags = ['tomcat'];
    expect(
        cmd.desc,
        equals(
            "Deploy of collections and species services in vm1 (tags: tomcat)"));
    cmd.tags = ['tomcat', 'properties', 'nginx'];
    cmd.deployServices = [collectory, bie, spatial, solr];
    expect(
        cmd.desc,
        equals(
            "Deploy of collections, species, spatial and index services in vm1 (tags: tomcat, properties, nginx)"));
    cmd.deployServices = [
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
            "Deploy of some services in vm1 (tags: tomcat, properties, nginx)"));
    cmd.onlyProperties = true;
    cmd.tags = [];
    expect(
        cmd.desc, equals("Deploy of some services in vm1 (tags: properties)"));
    cmd.tags = ['tomcat', 'properties', 'nginx', 'java'];
    cmd.deployServices = [collectory, bie];
    expect(
        cmd.desc,
        equals(
            "Deploy of collections and species services in vm1 (only some tasks)"));
    cmd.dryRun = true;
    cmd.onlyProperties = false;
    cmd.tags = [];
    expect(cmd.desc,
        equals("Dry run deploy of collections and species services in vm1"));
  });

  test('Test pre-cmd to String', () {
    PreDeployCmd cmd = PreDeployCmd();
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
    PostDeployCmd cmd = PostDeployCmd();
    cmd.configurePostfix = true;
    expect(cmd.desc, equals("Post-deploy tasks (configure postfix)"));
  });

  test('cmdEntry server retrieve', () {
    Map<String, dynamic> cmdEntryJ = {
      "createdAt": 1617609595413,
      "updatedAt": 1617609595413,
      "id": "6084263ae185829aa740c3ad",
      "logsPrefix": "la-test",
      "logsSuffix": "2021-04-05_09:58:53",
      "invDir": "la-test/la-test-pre-deploy/",
      "rawCmd":
          "ansible-playbook -i ../la-test-inventories/la-test-inventory.ini -i inventory.yml pre-deploy.yml --tags pre-task-solr-limits,pre-task-deps",
      "result": "success",
      "projectId": "6084263ae185829aa740c368",
      "cmd": {
        "createdAt": 1617609595413,
        "updatedAt": 1617609595413,
        "id": "6084263ae185829aa740c3ae",
        "type": "preDeploy",
        "properties": {
          "deployServices": ["all"],
          "limitToServers": ["ala-install-test-1"],
          "skipTags": [],
          "tags": [],
          "advanced": false,
          "onlyProperties": false,
          "continueEvenIfFails": false,
          "debug": false,
          "dryRun": false,
          "addAnsibleUser": false,
          "addSshKeys": false,
          "giveSudo": false,
          "etcHosts": false,
          "solrLimits": true,
          "addAdditionalDeps": true
        },
        "cmdHistoryEntryId": "6084263ae185829aa740c3ad"
      }
    };
    CmdHistoryEntry cmdEntry = CmdHistoryEntry.fromJson(cmdEntryJ);
    expect(cmdEntry.cmd.type, equals(CmdType.preDeploy));
    expect(
        cmdEntry.deployCmd!.desc,
        equals(
            "Pre-deploy tasks (setup solr limits, additional deps install in ala-install-test-1)"));
  });

  test('Test pipeline cmd to String', () {
    PipelinesCmd cmd = PipelinesCmd();
    cmd.allDrs = true;
    expect(cmd.desc, equals("Pipelines data processing of all drs"));
    cmd.steps = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
    expect(
        cmd.desc, equals("Pipelines data processing of all drs (some steps)"));
    cmd.steps = {'interpret', 'validate', 'dwca-export'};
    expect(
        cmd.desc,
        equals(
            "Pipelines data processing of all drs (interpret, validate and dwca-export steps)"));
    cmd.steps = {'interpret', 'validate'};
    expect(
        cmd.desc,
        equals(
            "Pipelines data processing of all drs (interpret and validate steps)"));
    cmd.steps = const {'interpret'};
    expect(cmd.desc,
        equals("Pipelines data processing of all drs (interpret step)"));
    cmd.dryRun = true;
    cmd.steps = {};
    expect(cmd.desc, equals("Dry run of Pipelines data processing of all drs"));
  });
}

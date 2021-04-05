import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/models/preDeployCmd.dart';
import 'package:test/test.dart';

void main() {
  final collectory = LAServiceName.collectory.toS();
  final bie = LAServiceName.ala_bie.toS();
  final alaHub = LAServiceName.ala_hub.toS();
  final biocacheService = LAServiceName.biocache_service.toS();
  final solr = LAServiceName.solr.toS();
  final spatial = LAServiceName.spatial.toS();
  final all = LAServiceName.all.toS();

  test('Test cmd to String', () {
    DeployCmd cmd = DeployCmd();
    cmd.deployServices = [all];
    expect(cmd.toString(), equals("Full deploy"));
    cmd.deployServices = [collectory];
    expect(cmd.toString(), equals("Deploy of collections service"));
    cmd.deployServices = [collectory, bie];
    expect(
        cmd.toString(), equals("Deploy of collections and species services"));
    cmd.limitToServers = ['vm1'];
    expect(cmd.toString(),
        equals("Deploy of collections and species services in vm1"));
    cmd.tags = ['tomcat'];
    expect(
        cmd.toString(),
        equals(
            "Deploy of collections and species services in vm1 (tags: tomcat)"));
    cmd.tags = ['tomcat', 'properties', 'nginx'];
    cmd.deployServices = [collectory, bie, spatial, solr];
    expect(
        cmd.toString(),
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
        cmd.toString(),
        equals(
            "Deploy of some services in vm1 (tags: tomcat, properties, nginx)"));
    cmd.onlyProperties = true;
    cmd.tags = [];
    expect(cmd.toString(),
        equals("Deploy of some services in vm1 (tags: properties)"));
    cmd.tags = ['tomcat', 'properties', 'nginx', 'java'];
    cmd.deployServices = [collectory, bie];
    expect(
        cmd.toString(),
        equals(
            "Deploy of collections and species services in vm1 (only some tasks)"));
    cmd.dryRun = true;
    cmd.onlyProperties = false;
    cmd.tags = [];
    expect(cmd.toString(),
        equals("Dry run deploy of collections and species services in vm1"));
  });

  test('Test pre-cmd to String', () {
    PreDeployCmd cmd = PreDeployCmd();
    cmd.addAnsibleUser = true;
    cmd.giveSudo = true;
    cmd.addSshKeys = true;
    expect(
        cmd.toString(),
        equals(
            "Pre-deploy tasks (add default user, add ssh keys, add sudo permissions, setup '/etc/hosts', setup solr limits, additional deps install)"));
    cmd.dryRun = true;
    expect(
        cmd.toString(),
        equals(
            "Dry run pre-deploy tasks (add default user, add ssh keys, add sudo permissions, setup '/etc/hosts', setup solr limits, additional deps install)"));
  });

  test('Test post-cmd to String', () {
    PostDeployCmd cmd = PostDeployCmd();
    cmd.configurePostfix = true;
    expect(cmd.toString(), equals("Post-deploy tasks (configure Postfix)"));
  });
}

import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDeploy.dart';
import 'package:la_toolkit/models/laVariable.dart';

import 'entityApi.dart';

// While waiting to https://github.com/flutterdata/flutter_data
// is more stable and null-safety ready :
class EntityApis {
  static EntityApi<LAProject> projectApi = EntityApi<LAProject>('project');
  static EntityApi<LAService> serviceApi = EntityApi<LAService>('service');
  static EntityApi<LAServer> serverApi = EntityApi<LAServer>('server');
  static EntityApi<LAServiceDeploy> serviceDeployApi =
      EntityApi<LAServiceDeploy>('serviceDeploy');
  static EntityApi<LAVariable> variableApi = EntityApi<LAVariable>('variable');
  static EntityApi<CmdHistoryEntry> cmdHistoryEntryApi =
      EntityApi<CmdHistoryEntry>('cmdHistoryEntry');
}

import '../models/cmd_history_entry.dart';
import '../models/la_server.dart';
import '../models/la_service_deploy.dart';
import '../models/la_variable.dart';
import '../models/la_project.dart';
import '../models/la_service.dart';
import 'entity_api.dart';

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

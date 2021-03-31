import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/components/termDialog.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/models/postDeployCmd.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../laTheme.dart';
import '../models/preDeployCmd.dart';
import '../routes.dart';

/*
class ListUtils {
  static bool notNull(Object? o) => o != null;

// What is the best way to optionally include a widget in a list of children
// https://github.com/flutter/flutter/issues/3783
  static List<Widget> listWithoutNulls(List<Widget?> children) =>
      children.where(notNull).toList();
}
*/
class AppUtils {
  static bool isDev() {
    return !kReleaseMode;
  }

  static bool isDemo() {
    return (env['DEMO'] ?? "false").parseBool();
  }

  static String proxyImg(imgUrl) {
    return "http://${env['BACKEND']}/api/v1/image-proxy/${Uri.encodeFull(imgUrl)}";
  }
}

class AssetsUtils {
  // https://github.com/flutter/flutter/issues/67655
  static String pathWorkaround(String asset) {
    return '${!AppUtils.isDev() ? 'assets/' : ''}$asset';
  }
}

class UiUtils {
  static showAlertDialog(BuildContext context, VoidCallback onConfirm) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("CANCEL"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget continueButton = TextButton(
        child: Text("CONFIRM"),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          onConfirm();
        });
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Please Confirm"),
      content: Text("Are you sure?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static showSnackBarError(BuildContext context, String e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e),
      duration: Duration(days: 365),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    ));
  }

  static void termErrorAlert(context, error) {
    Alert(
        context: context,
        closeIcon: Icon(Icons.close),
        image:
            Icon(Icons.error_outline, size: 60, color: LAColorTheme.inactive),
        title: "ERROR",
        style: AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(children: <Widget>[
          Text(
            "We had some problem ($error)",
          ),
          SizedBox(
            height: 20,
          ),
          // Text(error),
        ]),
        buttons: [
          DialogButton(
            width: 500,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}

class DeployUtils {
  static const TextStyle subtitleStyle =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 18);

  static const TextStyle cmdTitleStyle = TextStyle(
    fontSize: 28,
    // fontWeight: FontWeight.bold,
  );
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static doDeploy(
      {required BuildContext context,
      required var store,
      required LAProject project,
      required DeployCmd deployCmd}) {
    context.showLoaderOverlay();
    store.dispatch(PrepareDeployProject(
        project: project,
        onReady: () {
          context.hideLoaderOverlay();
          if (deployCmd is PreDeployCmd) {
            BeamerCond.of(context, PreDeployLocation());
          } else if (deployCmd is PostDeployCmd) {
            BeamerCond.of(context, PostDeployLocation());
          } else {
            BeamerCond.of(context, DeployLocation());
          }
        },
        deployCmd: deployCmd,
        onError: (e) {
          context.hideLoaderOverlay();
          UiUtils.showSnackBarError(context, e);
        }));
  }

  static deployActionDispatch(
      {required BuildContext context,
      var store,
      required LAProject project,
      required DeployCmd cmd}) {
    context.showLoaderOverlay();
    if (cmd.runtimeType == PostDeployCmd) {
      // We generate again the inventories with the smtp values
      store.dispatch(PrepareDeployProject(
          project: project,
          onReady: () {},
          deployCmd: cmd,
          onError: (e) {
            context.hideLoaderOverlay();
            UiUtils.showSnackBarError(context, e);
          }));
    }
    store.dispatch(DeployProject(
        project: project,
        cmd: cmd,
        onStart: (ansibleCmd, logsPrefix, logsSuffix, invDir) {
          context.hideLoaderOverlay();
          TermDialog.show(context, title: "Ansible console", onClose: () async {
            if (!cmd.dryRun) {
              // Show the results
              CmdHistoryEntry cmdHistory = CmdHistoryEntry(
                  cmd: ansibleCmd,
                  deployCmd: cmd,
                  preDeployCmd: cmd is PreDeployCmd ? cmd : null,
                  postDeployCmd: cmd is PostDeployCmd ? cmd : null,
                  logsPrefix: logsPrefix,
                  logsSuffix: logsSuffix,
                  invDir: invDir);
              store.dispatch(
                  DeployUtils.getCmdResults(context, cmdHistory, true));
            }
            // context.hideLoaderOverlay();
          });
        },
        onError: (error) {
          context.hideLoaderOverlay();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
              content: Text(
                  'Oooopss, some problem have arisen trying to start the deploy: $error')));
        }));
  }

  static AppActions getCmdResults(
      BuildContext context, CmdHistoryEntry cmdHistory, bool fstRetrieved) {
    context.showLoaderOverlay();
    return GetDeployProjectResults(
        cmdHistoryEntry: cmdHistory,
        fstRetrieved: fstRetrieved,
        onReady: () {
          context.hideLoaderOverlay();
          BeamerCond.of(context, DeployResultsLocation());
        },
        onFailed: () {
          context.hideLoaderOverlay();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('There was some problem retrieving the results'),
            duration: Duration(days: 365),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ));
        });
  }
}

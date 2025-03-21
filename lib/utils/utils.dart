import 'package:duration/duration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:redux/redux.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:simple_moment/simple_moment.dart';

import '../components/LoadingTextOverlay.dart';
import '../components/term_dialog.dart';
import '../laTheme.dart';
import '../models/appState.dart';
import '../models/brandingDeployCmd.dart';
import '../models/cmdHistoryEntry.dart';
import '../models/commonCmd.dart';
import '../models/deployCmd.dart';
import '../models/la_project.dart';
import '../models/pipelinesCmd.dart';
import '../models/postDeployCmd.dart';
import '../models/preDeployCmd.dart';
import '../redux/app_actions.dart';
import '../routes.dart';
import 'StringUtils.dart';

class AppUtils {
  static bool isDev() {
    return !kReleaseMode;
  }

  static bool isDemo() {
    return (dotenv.env['DEMO'] ?? 'false').parseBool();
  }

  static bool https = (dotenv.env['HTTPS'] ?? 'false').parseBool();

  static Uri uri(String a, String p, [Map<String, String>? query]) =>
      https ? Uri.https(a, p, query) : Uri.http(a, p, query);
  static String scheme =
      (dotenv.env['HTTPS'] ?? 'false').parseBool() ? 'https' : 'http';

  static String proxyImg(String imgUrl) {
    return "$scheme://${dotenv.env['BACKEND']}/api/v1/image-proxy/${Uri.encodeFull(imgUrl)}";
  }
}

class AssetsUtils {
  // https://github.com/flutter/flutter/issues/67655
  static String pathWorkaround(String asset) {
    return '${!AppUtils.isDev() ? 'assets/' : ''}$asset';
  }
}

class UiUtils {
  static const TextStyle cmdTitleStyle = TextStyle(
    fontSize: 28,
    // fontWeight: FontWeight.bold,
  );
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle subtitleStyle =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 18);
  static const TextStyle dateStyle = TextStyle(
      color: LAColorTheme.inactive,
      fontWeight: FontWeight.w400,
      fontSize: 18,
      fontStyle: FontStyle.italic);

  static void showAlertDialog(
      BuildContext context, VoidCallback onConfirm, VoidCallback onCancel,
      {String title = 'Please Confirm',
      String subtitle = 'Are you sure?',
      String confirmBtn = 'CONFIRM',
      String cancelBtn = 'CANCEL'}) {
    // set up the buttons
    final Widget cancelButton = TextButton(
      child: Text(cancelBtn),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
        onCancel();
      },
    );
    final Widget continueButton = TextButton(
        child: Text(confirmBtn),
        onPressed: () {
          Navigator.of(context, rootNavigator: true).pop();
          onConfirm();
        });
    // set up the AlertDialog
    final AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(subtitle),
      actions: <Widget>[
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

  static void showSnackBarError(BuildContext context, String e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(e),
      duration: const Duration(days: 365),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ),
    ));
  }

  static void termErrorAlert(BuildContext context, String error) {
    Alert(
        context: context,
        closeIcon: const Icon(Icons.close),
        image: const Icon(Icons.error_outline,
            size: 60, color: LAColorTheme.inactive),
        title: 'ERROR',
        style: const AlertStyle(
            constraints: BoxConstraints.expand(height: 600, width: 600)),
        content: Column(children: <Widget>[
          Text(
            'We had some problem ($error)',
          ),
          const SizedBox(
            height: 20,
          ),
          // Text(error),
        ]),
        buttons: <DialogButton>[
          DialogButton(
            width: 450,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  static bool isSmallScreen(BuildContext context) =>
      MediaQuery.of(context).size.width < 750;
}

class DeployUtils {
  static dynamic doDeploy(
      {required BuildContext context,
      required Store<AppState> store,
      required LAProject project,
      required CommonCmd commonCmd}) {
    context.loaderOverlay
        .show(widgetBuilder: (dynamic progress) => const LoadingTextOverlay());
    store.dispatch(PrepareDeployProject(
        project: project,
        onReady: () {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          if (commonCmd is PreDeployCmd) {
            BeamerCond.of(context, PreDeployLocation());
          } else if (commonCmd is PostDeployCmd) {
            BeamerCond.of(context, PostDeployLocation());
          } else if (commonCmd is BrandingDeployCmd) {
            BeamerCond.of(context, BrandingDeployLocation());
          } else if (commonCmd is PipelinesCmd) {
            BeamerCond.of(context, PipelinesLocation());
          } else {
            BeamerCond.of(context, DeployLocation());
          }
        },
        deployCmd: commonCmd,
        onError: (String e) {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          UiUtils.showSnackBarError(context, e);
        }));
  }

  static void deployActionLaunch(
      {required BuildContext context,
      required Store<AppState> store,
      required LAProject project,
      required DeployCmd deployCmd}) {
    context.loaderOverlay.show();
    if (deployCmd.runtimeType == PostDeployCmd) {
      // We generate again the inventories with the smtp values
      store.dispatch(PrepareDeployProject(
          project: project,
          onReady: () {},
          deployCmd: deployCmd,
          onError: (String e) {
            if (context.mounted) {
              context.loaderOverlay.hide();
            }
            UiUtils.showSnackBarError(context, e);
          }));
    }
    store.dispatch(DeployProject(
        project: project,
        cmd: deployCmd,
        onStart: (CmdHistoryEntry cmdEntry, int port, int ttydPid) {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          /* Not used right now, maybe in the future
          context.beamToNamed('/term/$port/$ttydPid'); */
          TermDialog.show(context,
              port: port,
              pid: ttydPid,
              notify: true,
              title: 'Ansible console', onClose: () async {
            if (!deployCmd.dryRun) {
              // Show the results
              store
                  .dispatch(DeployUtils.getCmdResults(context, cmdEntry, true));
            }
            //  if (context.mounted) {
            // context.loaderOverlay.hide();
//}
          });
        },
        onError: (int error) {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
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

  static void brandingDeployActionLaunch(
      {required BuildContext context,
      required Store<AppState> store,
      required LAProject project,
      required BrandingDeployCmd deployCmd}) {
    context.loaderOverlay.show();
    store.dispatch(BrandingDeploy(
        project: project,
        cmd: deployCmd,
        onStart: (CmdHistoryEntry cmdEntry, int port, int ttydPid) {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          /* Not used right now, maybe in the future
          context.beamToNamed('/term/$port/$ttydPid'); */
          TermDialog.show(context,
              port: port,
              pid: ttydPid,
              // title: 'Console',
              notify: false, onClose: () async {
            // Show the results
            store.dispatch(DeployUtils.getCmdResults(context, cmdEntry, true));
          });
        },
        onError: (int error) {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
              content: Text(
                  'Oooopss, some problem have arisen trying to deploy the branding: $error')));
        }));
  }

  static void pipelinesRun(
      {required BuildContext context,
      required Store<AppState> store,
      required LAProject project,
      required PipelinesCmd cmd}) {
    context.loaderOverlay.show();
    store.dispatch(PipelinesRun(
        project: project,
        cmd: cmd,
        onStart: (CmdHistoryEntry cmdEntry, int port, int ttydPid) {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          /* Not used right now, maybe in the future
          context.beamToNamed('/term/$port/$ttydPid'); */
          TermDialog.show(context,
              port: port,
              pid: ttydPid,
              // title: 'Console',
              notify: true, onClose: () async {
            // Show the results
            store.dispatch(DeployUtils.getCmdResults(context, cmdEntry, true));
          });
        },
        onError: (int error) {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
              content: Text(
                  'Oooopss, some problem have arisen trying to run pipelines: $error')));
        }));
  }

  static AppActions getCmdResults(
      BuildContext context, CmdHistoryEntry cmdHistory, bool fstRetrieved) {
    context.loaderOverlay.show();
    return GetCmdResults(
        cmdHistoryEntry: cmdHistory,
        fstRetrieved: fstRetrieved,
        onReady: () {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          BeamerCond.of(context, CmdResultsLocation());
        },
        onFailed: () {
          if (context.mounted) {
            context.loaderOverlay.hide();
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                const Text('There was some problem retrieving the results'),
            duration: const Duration(days: 365),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ));
        });
  }
}

class LADateUtils {
/*  static Future<String> now() async {
    final DateTime now = DateTime.now();
    String locale = await findSystemLocale();
    final DateFormat formatter = DateFormat.yMd(locale).add_jm();
    // DateFormat('yyyy-MM-dd H:mm:ss a', locale);
    return formatter.format(now);
  }*/
  static String formatDuration(double duration) => prettyDuration(
        Duration(milliseconds: duration.toInt()),
        // abbreviated: false
      );

  static String formatDate(DateTime date) => Moment.now().from(date);
}

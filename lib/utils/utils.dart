import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/deployCmd.dart';
import 'package:la_toolkit/models/laProject.dart';
import 'package:la_toolkit/redux/appActions.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:xterm/theme/terminal_color.dart';
import 'package:xterm/theme/terminal_theme.dart';

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
}

class DeployUtils {
  static doDeploy(
      {required BuildContext context,
      required var store,
      required LAProject project,
      required DeployCmd repeatCmd}) {
    context.showLoaderOverlay();
    store.dispatch(PrepareDeployProject(
        project: project,
        onReady: () {
          context.hideLoaderOverlay();
          Beamer.of(context).beamTo(DeployLocation());
        },
        repeatCmd: repeatCmd,
        onError: (e) {
          context.hideLoaderOverlay();
          UiUtils.showSnackBarError(context, e);
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
          Beamer.of(context).beamTo(DeployResultsLocation());
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

  static const TextStyle titleStyle =
      TextStyle(fontWeight: FontWeight.w400, fontSize: 18);

  static const laTerminalTheme = TerminalTheme(
    cursor: TerminalColor(0xffaeafad),
    selection: TerminalColor(0xffffff40),
    foreground: TerminalColor(0xffcccccc),
    background: TerminalColor(0xff29322e),
    black: TerminalColor(0xff000000),
    red: TerminalColor(0xffcd3131),
    green: TerminalColor(0xff0dbc79),
    yellow: TerminalColor(0xffe5e510),
    blue: TerminalColor(0xff2472c8),
    magenta: TerminalColor(0xffbc3fbc),
    cyan: TerminalColor(0xff11a8cd),
    white: TerminalColor(0xffe5e5e5),
    brightBlack: TerminalColor(0xff666666),
    brightRed: TerminalColor(0xfff14c4c),
    brightGreen: TerminalColor(0xff23d18b),
    brightYellow: TerminalColor(0xfff5f543),
    brightBlue: TerminalColor(0xff3b8eea),
    brightMagenta: TerminalColor(0xffd670d6),
    brightCyan: TerminalColor(0xff29b8db),
    brightWhite: TerminalColor(0xffffffff),
  );
}

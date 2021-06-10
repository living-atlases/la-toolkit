import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:mdi/mdi.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:web_browser/web_browser.dart';

import '../laTheme.dart';
import '../notInDemo.dart';

class TermDialog {
  static show(context,
      {title: 'Console',
      required int port,
      required int pid,
      VoidCallback? onClose}) async {
    print("${getInitialUrl(port)}");
    await showFloatingModalBottomSheet(
        // This can be added to the custom modal
        // expand: false,
        context: context,
        // isDismissible: true,
        // useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Material(
              child: Scaffold(
                appBar: AppBar(
                  leading: Icon(
                    Mdi.console,
                    color: Colors.white,
                  ),
                  title: Text(
                    title,
                    style: TextStyle(color: Colors.white),
                  ),
                  actions: [
                    Tooltip(
                      message: "Close the console",
                      child: TextButton(
                          child: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.of(context).pop();
                          }),
                    ),
                  ],
                ),
                body: termArea(port),
              ),
            ));
    Api.termClose(port: port, pid: pid);
    if (onClose != null) {
      onClose();
    }
  }

  static String getInitialUrl(int port) =>
      (env['TERM_PROXY'] ?? "false").parseBool()
          ? '${AppUtils.scheme}://${env['BACKEND']!.split(":")[0]}/ttyd$port'
          : '${AppUtils.scheme}://${env['BACKEND']!.split(":")[0]}:$port/';

  static SafeArea termArea(int port) {
    return SafeArea(
        bottom: false,
        child: Container(
          color: LAColorTheme.laPalette,
          padding: EdgeInsets.fromLTRB(3, 0, 8, 0),
          child: !AppUtils.isDemo()
              ? WebBrowser(
                  initialUrl: getInitialUrl(port),
                  interactionSettings: WebBrowserInteractionSettings(
                      topBar: null, bottomBar: null),
                  javascriptEnabled: true,
                )
              : NotInTheDemoPanel(),
        ));
  }

  static Future<T> showFloatingModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
  }) async {
    final result = await showCustomModalBottomSheet(
        context: context,
        builder: builder,
        containerWidget: (_, animation, child) => FloatingModal(
              child: child,
            ),
        expand: false);

    return result;
  }

  static ListTile drawerItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Mdi.console),
      title: Text('Console'),
      onTap: () {
        openTerm(context);
      },
    );
  }

  // Opens a bash or a ssh on server
  static void openTerm(BuildContext context,
      [String? projectId, String? server]) {
    // context.loaderOverlay.show();
    context.loaderOverlay.show();
    Api.term(
        onStart: (cmd, port, ttydPid) {
          context.loaderOverlay.hide();
          TermDialog.show(context, port: port, pid: ttydPid);
        },
        onError: (error) {
          context.loaderOverlay.hide();
          UiUtils.termErrorAlert(context, error);
        },
        projectId: projectId,
        server: server);
  }
}

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({Key? key, required this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(100, 100, 100, 0),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}

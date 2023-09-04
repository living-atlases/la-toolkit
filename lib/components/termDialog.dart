import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'embedWebView.dart';

class TermDialog {
  static show(context,
      {title = 'Console',
      required int port,
      required int pid,
      required bool notify,
      VoidCallback? onClose}) async {
    // print("${getInitialUrl(port)}");
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
                    MdiIcons.console,
                    color: Colors.white,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  actions: [
                    Tooltip(
                        message: "Close the console",
                        child: TextButton(
                            child: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            })),
                  ],
                ),
                body: termArea(port, notify),
              ),
            ));
    Api.termClose(port: port, pid: pid);
    if (onClose != null) {
      onClose();
    }
  }

  static String getInitialUrl(int port) => (dotenv.env['TERM_PROXY'] ?? "false")
          .parseBool()
      ? '${AppUtils.scheme}://${dotenv.env['BACKEND']!.split(":")[0]}/ttyd$port'
      : '${AppUtils.scheme}://${dotenv.env['BACKEND']!.split(":")[0]}:$port/';

  static Widget termArea(int port, bool notify) {
    return InteractiveViewer(
        child: Container(
            alignment: Alignment.center,
            child: EmbedWebView(src: getInitialUrl(port), notify: notify)));
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
      leading: Icon(MdiIcons.console),
      title: const Text('Console'),
      onTap: () {
        openTerm(context, false);
      },
    );
  }

  // Opens a bash or a ssh on server
  static void openTerm(BuildContext context, bool notify,
      [String? projectId, String? server]) {
    // context.loaderOverlay.show();
    context.loaderOverlay.show();
    Api.term(
        onStart: (String cmd, int port, int ttydPid) {
          context.loaderOverlay.hide();
          TermDialog.show(context, port: port, pid: ttydPid, notify: notify);
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
    bool small = UiUtils.isSmallScreen(context);
    double pad = small ? 10.0 : 100.0;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, pad, pad, 0),
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

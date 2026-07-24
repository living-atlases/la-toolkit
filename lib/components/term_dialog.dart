import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../utils/api.dart';

import '../utils/string_utils.dart';
import '../utils/utils.dart';
import 'embed_web_view.dart';

class TermDialog {
  static Future<void> show(
    BuildContext context, {
    String title = 'Console',
    required int port,
    required int pid,
    required bool notify,
    VoidCallback? onClose,
    // When set, the console shows a "Cancel deploy" action. Closing the console
    // only stops the viewer (the deploy runs detached and survives); this is the
    // explicit way to abort the running deploy.
    String? cancelPrefix,
    String? cancelSuffix,
  }) async {
    final bool cancellable = cancelPrefix != null && cancelSuffix != null;
    // debugPrint("${getInitialUrl(port)}");
    await showFloatingModalBottomSheet(
      // This can be added to the custom modal
      // expand: false,
      context: context,
      // isDismissible: true,
      // useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => Material(
        child: Scaffold(
          appBar: AppBar(
            leading: Icon(
              MdiIcons.console,
              // color: Colors.white,
            ),
            title: Text(
              title,
              // style: const TextStyle(color: Colors.white),
            ),
            actions: <Widget>[
              if (cancellable)
                Tooltip(
                  message: 'Cancel the running deploy',
                  child: TextButton.icon(
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Cancel deploy'),
                    onPressed: () async {
                      final bool confirmed = await _confirmCancel(context);
                      if (!confirmed) {
                        return;
                      }
                      await Api.deployCancel(
                        logsPrefix: cancelPrefix,
                        logsSuffix: cancelSuffix,
                      );
                    },
                  ),
                ),
              Tooltip(
                message: 'Close the console (the deploy keeps running)',
                child: TextButton(
                  child: const Icon(Icons.close),
                  //, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          body: termArea(port, notify),
        ),
      ),
    );
    Api.termClose(port: port, pid: pid);
    if (onClose != null) {
      onClose();
    }
  }

  static Future<bool> _confirmCancel(BuildContext context) async {
    // Wrap in PointerInterceptor: the console is a ttyd <iframe> (HtmlElementView),
    // which on web captures pointer events over its area, so a plain dialog drawn
    // on top of it is not clickable. The interceptor inserts a transparent HTML
    // layer that lets the dialog receive clicks.
    final bool? res = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => PointerInterceptor(
        child: AlertDialog(
          title: const Text('Cancel deploy?'),
          content: const Text(
            'This stops the running deploy on the server and leaves it '
            'incomplete. Closing the console instead keeps it running. '
            'Are you sure you want to cancel?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Keep running'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cancel deploy'),
            ),
          ],
        ),
      ),
    );
    return res ?? false;
  }

  static String getInitialUrl(int port) =>
      (dotenv.env['TERM_PROXY'] ?? 'false').parseBool()
      ? '${AppUtils.scheme}://${dotenv.env['BACKEND']!.split(":")[0]}/ttyd$port'
      : '${AppUtils.scheme}://${dotenv.env['BACKEND']!.split(":")[0]}:$port/';

  static Widget termArea(int port, bool notify) {
    return InteractiveViewer(
      child: Container(
        alignment: Alignment.center,
        child: EmbedWebView(src: getInitialUrl(port), notify: notify),
      ),
    );
  }

  static Future<T?> showFloatingModalBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
  }) async {
    final T? result = await showCustomModalBottomSheet(
      context: context,
      builder: builder,
      containerWidget: (_, Animation<double> animation, Widget child) =>
          FloatingModal(child: child),
    );

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
  static void openTerm(
    BuildContext context,
    bool notify, [
    String? projectId,
    String? server,
  ]) {
    // context.loaderOverlay.show();
    context.loaderOverlay.show();
    Api.term(
      onStart: (String cmd, int port, int ttydPid) {
        if (context.mounted) {
          context.loaderOverlay.hide();
        }
        TermDialog.show(context, port: port, pid: ttydPid, notify: notify);
      },
      onError: (int error) {
        if (context.mounted) {
          context.loaderOverlay.hide();
        }
        UiUtils.termErrorAlert(context, error.toString());
      },
      projectId: projectId,
      server: server,
    );
  }
}

class FloatingModal extends StatelessWidget {
  const FloatingModal({super.key, required this.child, this.backgroundColor});

  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final bool small = UiUtils.isSmallScreen(context);
    final double pad = small ? 10.0 : 100.0;
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

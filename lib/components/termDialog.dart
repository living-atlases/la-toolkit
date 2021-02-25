import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:web_browser/web_browser.dart';

import '../laTheme.dart';

class TermDialog {
  static show(context) {
    showFloatingModalBottomSheet(
        // This can be addedd to the custom modal
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
                    'Console',
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
                body: SafeArea(
                    bottom: false,
                    child: Container(
                      color: LAColorTheme.laPalette,
                      padding: EdgeInsets.fromLTRB(3, 0, 8, 0),
                      child: !AppUtils.isDemo()
                          ? WebBrowser(
                              initialUrl: 'http://localhost:8081/',
                              interactionSettings:
                                  WebBrowserInteractionSettings(
                                      topBar: null, bottomBar: null),
                              javascriptEnabled: true,
                            )
                          : Center(
                              child: Text(
                                "This does not work in the demo",
                                textAlign: TextAlign.center,
                              ),
                            ),
                    )),
              ),
            ));
  }

  static Future<T> showFloatingModalBottomSheet<T>({
    @required BuildContext context,
    @required WidgetBuilder builder,
    Color backgroundColor,
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
}

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const FloatingModal({Key key, @required this.child, this.backgroundColor})
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

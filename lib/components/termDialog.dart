import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/utils/api.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:mdi/mdi.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:web_browser/web_browser.dart';

import '../laTheme.dart';

class TermDialog {
  static show(context, {title: 'Console', VoidCallback onClose}) {
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
                body: SafeArea(
                    bottom: false,
                    child: Container(
                      color: LAColorTheme.laPalette,
                      padding: EdgeInsets.fromLTRB(3, 0, 8, 0),
                      child: !AppUtils.isDemo()
                          ? WebBrowser(
                              initialUrl: 'http://localhost:2011/',
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
            )).then((_) => onClose());
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

  static ListTile drawerItem(context) {
    return ListTile(
      leading: const Icon(Mdi.console),
      title: Text('Console'),
      onTap: () {
        Api.term(onStart: () {
          TermDialog.show(context);
        }, onError: (error) {
          Alert(
              context: context,
              closeIcon: Icon(Icons.close),
              image: Icon(Icons.error_outline,
                  size: 60, color: LAColorTheme.inactive),
              title: "ERROR",
              style: AlertStyle(
                  constraints: BoxConstraints.expand(height: 600, width: 600)),
              content: Column(children: <Widget>[
                Text(
                  "We had some problem",
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
        });
      },
    );
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

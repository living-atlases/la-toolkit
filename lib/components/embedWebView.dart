import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/utils/utils.dart';
// https://github.com/flutter/flutter/issues/41563#issuecomment-794384561
// ignore: implementation_imports
import 'package:pointer_interceptor/src/shim/dart_ui.dart' as ui;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:universal_html/html.dart';
import 'package:universal_html/html.dart' as html;

import '../notInDemo.dart';

class EmbedWebView extends StatefulWidget {
  final String src;
  final double? height, width;
  final bool notify;
  const EmbedWebView(
      {Key? key,
      required this.src,
      this.height,
      this.width,
      required this.notify})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EmbedWebViewState();
  }
}

class EmbedWebViewState extends State<EmbedWebView>
    with AutomaticKeepAliveClientMixin {
  late io.Socket _socket;
  @override
  void initState() {
    super.initState();
    final IFrameElement _iframeElement = IFrameElement()
      ..height = '100%'
      ..width = '100%'
      ..src = widget.src
      ..style.border = 'none'
      ..style.overflow = "hidden"
      ..allow = "autoplay"
/*      ..onChange.listen((event) {
        print("ON IFRAME change");
        print(event.currentTarget);
      })
      ..onLoad.listen((Event event) {
        print("ON IFRAME LOAD");
      })
      ..onReset.listen((Event event) {
        print("ON RESET");
      })
      ..onAbort.listen((Event event) {
        print("ON ABORT");
      }).onDone(() => {print("ON DONE")})
      ..onLoadedData.listen((Event event) {
        print("ON LOADED DATA");
      })
      ..onEnded.listen((Event event) {
        print("ON ENDED");
      }) */
      ..allowFullscreen = true;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      widget.src,
      (int viewId) => _iframeElement,
    );
    if (!AppUtils.isDemo() && widget.notify) {
      _socket = io.io(
        widget.src, // {"autoConnect": false}
      );
      _socket.on('disconnect', (_) => print('ON socket disconnect'));
      _socket.onError((e) {
        _socket.disconnect();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!AppUtils.isDemo() && widget.notify) _socket.disconnect();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    if (!AppUtils.isDemo() && widget.notify) {
      super.build(context);
      // Does not works, so let's comment for now
      //
      // _socket.onConnectError((e) => onWebsocketEnd());
    }
    return SafeArea(
        bottom: false,
        child: Container(
            color: LAColorTheme.laPalette,
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            child: !AppUtils.isDemo()
                ? Center(
                    child: SizedBox(
                      width: widget.width,
                      height: widget.height,
                      child: HtmlElementView(
                        // key: UniqueKey(),
                        viewType: widget.src,
                      ),
                    ),
                  )
                : const NotInTheDemoPanel()));
  }

  void onWebsocketEnd() {
    _socket.disconnect();
    String? perm = html.Notification.permission;
    if (perm == "granted") {
      html.Notification("LA Toolkit: Command finished",
          icon:
              "https://raw.githubusercontent.com/living-atlases/artwork/master/icon-white.png");
    }
  }
}

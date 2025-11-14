// ignore: implementation_imports
import 'dart:ui_web' as ui; // used on web for platformViewRegistry

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../la_theme.dart';
import '../not_in_demo.dart';
import '../utils/utils.dart'; // https://github.com/flutter/flutter/issues/41563#issuecomment-794384561

class EmbedWebView extends StatefulWidget {
  const EmbedWebView(
      {super.key,
      required this.src,
      this.height,
      this.width,
      required this.notify});

  final String src;
  final double? height, width;
  final bool notify;

  @override
  State<StatefulWidget> createState() {
    return EmbedWebViewState();
  }
}

class EmbedWebViewState extends State<EmbedWebView>
    with AutomaticKeepAliveClientMixin {
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    final IFrameElement iframeElement = IFrameElement()
      ..height = '100%'
      ..width = '100%'
      ..src = widget.src
      ..style.border = 'none'
      ..style.overflow = 'hidden'
      ..allow = 'autoplay'
      ..allowFullscreen = true;
    // ignore: undefined_prefixed_name

    if (kIsWeb) {
      ui.platformViewRegistry.registerViewFactory(
        widget.src,
        (int viewId) => iframeElement,
      );
    }
    if (!AppUtils.isDemo() && widget.notify) {
      final Uri uri = Uri.parse(widget.src.replaceAll('http', 'ws'));
      _channel = WebSocketChannel.connect(uri);

      ///
      /// Start listening to new notifications / messages
      ///
      _channel.stream.listen(
        (dynamic message) {
          // debugPrint('message $message');
        },
        onDone: () {
          // debugPrint('ws channel closed');
          onWebsocketEnd();
        },
        onError: (Object error) {
          // debugPrint('ws error $error');
        },
      );
    }
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
    final String? perm = html.Notification.permission;
    if (perm == 'granted') {
      html.Notification('LA Toolkit: Command finished',
          icon:
              'https://raw.githubusercontent.com/living-atlases/artwork/master/icon-white.png');
    }
  }
}

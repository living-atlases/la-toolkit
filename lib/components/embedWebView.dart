import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/utils/utils.dart';

import '../notInDemo.dart';

class EmbedWebView extends StatefulWidget {
  final String src;
  final double? height, width;
  EmbedWebView({Key? key, required this.src, this.height, this.width})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EmbedWebViewState();
  }
}

class EmbedWebViewState extends State<EmbedWebView>
    with AutomaticKeepAliveClientMixin {
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
      ..allowFullscreen = true;
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      widget.src,
      (int viewId) => _iframeElement,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
        bottom: false,
        child: Container(
            color: LAColorTheme.laPalette,
            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
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
                : NotInTheDemoPanel()));
  }
}

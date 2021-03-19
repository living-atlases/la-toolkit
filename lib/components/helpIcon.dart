import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpIcon extends StatelessWidget {
  final String url;
  final String? tooltip;

  HelpIcon({required String wikipage, String? tooltip})
      : url =
            "https://github.com/AtlasOfLivingAustralia/documentation/wiki/${wikipage.replaceAll(' ', '-')}",
        this.tooltip = tooltip == null ? "Read more in our Wiki" : null;

  HelpIcon.url({required this.url, this.tooltip});

  @override
  Widget build(BuildContext context) {
    Widget icon = _createIcon(url);
    return tooltip != null ? Tooltip(message: tooltip!, child: icon) : icon;
  }

  Widget _createIcon(url) {
    return IconButton(
        onPressed: () async {
          // print("Opening help page: $url");
          await launch(url);
        },
        icon: Icon(Icons.help_outline),
        /*size: 24,*/ color: Colors.blueGrey);
  }
}

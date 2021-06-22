import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpIcon extends StatelessWidget {
  final String url;
  final String? tooltip;

  HelpIcon({Key? key, required String wikipage, String? tooltip})
      : url =
            "https://github.com/AtlasOfLivingAustralia/documentation/wiki/${wikipage.replaceAll(' ', '-')}",
        tooltip = tooltip == null ? "Read more in our Wiki" : null,
        super(key: key);

  const HelpIcon.url({Key? key, required this.url, this.tooltip})
      : super(key: key);

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
        icon: const Icon(Icons.help_outline),
        /*size: 24,*/ color: Colors.blueGrey);
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpIcon extends StatelessWidget {
  HelpIcon({super.key, required String wikipage, String? tooltip})
      : url =
            "https://github.com/AtlasOfLivingAustralia/documentation/wiki/${wikipage.replaceAll(' ', '-')}",
        tooltip = tooltip == null ? 'Read more in our Wiki' : null;

  HelpIcon.from(String wikipageOrUrl, [Key? key, String? tooltip])
      : url = wikipageOrUrl.startsWith('http')
            ? wikipageOrUrl
            : "https://github.com/AtlasOfLivingAustralia/documentation/wiki/${wikipageOrUrl.replaceAll(' ', '-')}",
        // ignore: prefer_if_null_operators
        tooltip = tooltip != null
            ? tooltip
            : !wikipageOrUrl.startsWith('http')
                ? 'Read more in our Wiki'
                : null,
        super(key: key);

  const HelpIcon.url({super.key, required this.url, this.tooltip});

  final String url;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final Widget icon = _createIcon(url);
    return tooltip != null ? Tooltip(message: tooltip, child: icon) : icon;
  }

  Widget _createIcon(String url) {
    return IconButton(
        onPressed: () async {
          // debugPrint("Opening help page: $url");
          await launchUrl(Uri.parse(url));
        },
        icon: const Icon(Icons.help_outline),
        /*size: 24,*/ color: Colors.blueGrey);
  }
}

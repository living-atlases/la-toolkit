import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'def_divider.dart';
import 'la_icon.dart';

class ListTileLink extends StatelessWidget {

  const ListTileLink(
      {super.key,
      this.icon,
      required this.title,
      this.tooltip,
      required this.url,
      this.trailingIcon,
      this.additionalTrailingIcon});
  final Widget? icon;
  final String title;
  final String? tooltip;
  final String url;
  final Widget? trailingIcon;
  final Widget? additionalTrailingIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: tooltip != null
          ? Tooltip(message: tooltip, child: Text(title))
          : Text(title),
      onTap: () async {
        // debugPrint(url);
        await launchUrl(Uri.parse(url));
      },
      trailing: Wrap(
        children: <Widget>[
          if (additionalTrailingIcon != null) additionalTrailingIcon!,
          if (trailingIcon != null) trailingIcon!
        ],
      ),
    );
  }

  static List<Widget> drawerBottomLinks(
      BuildContext context, bool enableFeedback) {
    return <Widget>[
      const ListTileLink(
          icon: Icon(Icons.bug_report),
          title: 'Report an issue',
          url: 'https://github.com/living-atlases/la-toolkit/issues'),
      if (enableFeedback)
        ListTile(
          leading: const Icon(Icons.feedback),
          title: const Text('Feedback'),
          onTap: () {
            /* BetterFeedback.of(context).show(
              (
                String feedbackText,
                Uint8List? feedbackScreenshot,
              ) async {
                // upload to server, share whatever
                // for example purposes just show it to the user
                alertFeedbackFunction(
                    context, feedbackText, feedbackScreenshot);
              },
            ); */
          },
        ),
      // TODO:
      // - Verify environment
      // - ssh-keys
      // - check for updates

      /*
              Screenshots does not work yet:
              https://github.com/ueman/feedback/issues/13
              ListTile(
                leading: const Icon(Icons.feedback),
                title: Text('Feedback (WIP)'),
                // selected: currentRoute == SandboxPage.routeName,
                onTap: () {
                  BetterFeedback.of(context).show();
                },
              ),*/

      const DefDivider(),
      const ListTileLink(
          icon: Icon(LAIcon.la),
          title: 'Living Atlases Community',
          url: 'https://living-atlases.gbif.org'),
      const ListTileLink(
          icon: ImageIcon(AssetImage('assets/images/ala-icon.png')),
          /* NetworkImage(
                          "https://www.ala.org.au/app/uploads/2019/01/cropped-favicon-32x32.png")), */
          title: 'Atlas of Living Australia',
          url: 'https://ala.org.au'),
      const DefDivider(),
      ListTileLink(
          icon: Icon(MdiIcons.github),
          title: 'This software on GitHub',
          url: 'https://github.com/living-atlases/la-toolkit/')
    ];
  }
}

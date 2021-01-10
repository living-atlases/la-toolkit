import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher.dart';

import 'defDivider.dart';
import 'laIcon.dart';

class ListTileLink extends StatelessWidget {
  final Widget icon;
  final String title;
  final String tooltip;
  final String url;
  final Widget trailingIcon;
  final Widget additionalTrailingIcon;

  ListTileLink(
      {this.icon,
      this.title,
      this.tooltip,
      this.url,
      this.trailingIcon,
      this.additionalTrailingIcon});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: tooltip != null
          ? Tooltip(message: tooltip, child: Text(title))
          : Text(title),
      onTap: () async {
        print(url);
        await launch(url);
      },
      trailing: Wrap(
        spacing: 0, // space between two icons
        children: <Widget>[
          if (additionalTrailingIcon != null) additionalTrailingIcon,
          if (trailingIcon != null) trailingIcon
        ],
      ),
    );
  }

  static final List<Widget> drawerBottomLinks = [
    ListTileLink(
        icon: Icon(Icons.bug_report),
        title: 'Report an issue',
        url: "https://github.com/living-atlases/la-toolkit/issues"),

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
    ListTileLink(
        icon: Icon(LAIcon.la),
        title: 'Living Atlases Community',
        url: "https://living-atlases.gbif.org"),
    ListTileLink(
        icon: ImageIcon(AssetImage("assets/images/ala-icon.png")),
        /* NetworkImage(
                          "https://www.ala.org.au/app/uploads/2019/01/cropped-favicon-32x32.png")), */
        title: 'Atlas of Living Australia',
        url: "https://ala.org.au"),
    const DefDivider(),
    ListTileLink(
        icon: Icon(Mdi.github),
        title: 'This software on GitHub',
        url: "https://github.com/living-atlases/la-toolkit/")
  ];
}

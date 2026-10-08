import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// The fast deploy of a pure docker-compose portal, below the regular Deploy
/// button: what it does, when to use it instead of Deploy, and the button.
/// [onTap] null means the deploy options rule it out, and the card says why.
class FastDeployCard extends StatelessWidget {
  const FastDeployCard({super.key, required this.onTap});

  final VoidCallback? onTap;

  static const String title = 'Fast deploy';
  static const String summary =
      'Redeploys the whole portal in minutes, without Ansible.';
  static const String useIt =
      'Use it to redeploy a portal that has been deployed once with Deploy, '
      'for instance after changing versions, variables or branding.';
  static const String useDeploy =
      'Use Deploy instead for the first deploy, to add a service or to change '
      'a password.';
  static const String how =
      'It prepares the configuration of every server on this toolkit (again '
      'only when something changed since the last time) and applies it to all '
      'the servers at once.';
  static const String unavailable =
      'Not available with the advanced options above (Deploy to servers, Tags, '
      'Skip tags, only properties or dry run): fast deploy always deploys the '
      'whole portal.';

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final Color muted = Theme.of(context).hintColor;
    Widget line(IconData icon, String s, {Color? color}) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: color ?? muted),
          const SizedBox(width: 8),
          Expanded(child: Text(s, style: text.bodyMedium)),
        ],
      ),
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Card(
          margin: const EdgeInsets.only(top: 40),
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(MdiIcons.flash, size: 26),
                    const SizedBox(width: 8),
                    Text(title, style: text.titleLarge),
                  ],
                ),
                const SizedBox(height: 4),
                Text(summary, style: text.bodyLarge),
                line(Icons.check_circle_outline, useIt, color: Colors.green),
                line(Icons.rocket_launch_outlined, useDeploy),
                line(Icons.info_outline, how),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: Icon(MdiIcons.flash, size: 26),
                    label: const Text(title, style: TextStyle(fontSize: 18)),
                  ),
                ),
                if (onTap == null)
                  line(Icons.block, unavailable, color: Colors.orange),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

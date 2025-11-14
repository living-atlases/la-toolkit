import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminIconButton extends StatelessWidget {
  const AdminIconButton(
      {super.key,
      required this.url,
      this.tooltip,
      this.alaAdmin = false,
      this.min = false,
      this.color,
      this.size});

  static IconData alaAdminIcon = Icons.admin_panel_settings_outlined;
  static IconData adminIcon = Icons.admin_panel_settings_rounded;

  final bool alaAdmin;
  final String url;
  final String? tooltip;
  final Color? color;
  final double? size;
  final bool min;

  @override
  Widget build(BuildContext context) {
    final Icon icon =
        Icon(alaAdmin ? alaAdminIcon : adminIcon, color: color, size: size);
    final StatelessWidget btn = min
        ? InkWell(child: icon, onTap: () async => go())
        : IconButton(
            icon: icon,
            tooltip: alaAdmin ? 'alaAdmin section' : 'Admin section',
            onPressed: () async => go());
    return tooltip != null ? Tooltip(message: tooltip, child: btn) : btn;
  }

  Future<bool> go() async =>
      launchUrl(Uri.parse(url + (alaAdmin ? '/alaAdmin' : '//admin')));
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminIconButton extends StatelessWidget {
  static IconData alaAdminIcon = Icons.admin_panel_settings_outlined;
  static IconData adminIcon = Icons.admin_panel_settings_rounded;

  final bool alaAdmin;
  final String url;
  final String? tooltip;
  final Color? color;
  final double? size;
  final bool min;

  const AdminIconButton(
      {Key? key,
      required this.url,
      this.tooltip,
      this.alaAdmin = false,
      this.min = false,
      this.color,
      this.size})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    var icon =
        Icon(alaAdmin ? alaAdminIcon : adminIcon, color: color, size: size);
    var btn = min
        ? InkWell(child: icon, onTap: () async => await go())
        : IconButton(
            icon: icon,
            tooltip: alaAdmin ? "alaAdmin section" : "Admin section",
            onPressed: () async => await go());
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }

  Future<bool> go() async =>
      await launch(url + (alaAdmin ? '/alaAdmin' : '//admin'));
}

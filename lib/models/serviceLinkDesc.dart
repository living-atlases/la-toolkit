import 'package:flutter/cupertino.dart';

class ServiceLinkDesc {
  final IconData icon;
  final String name;
  final String tooltip;
  final String url;
  final bool admin;
  final bool alaAdmin;
  final String? help;
  final String subtitle;
  ServiceLinkDesc({
    required this.icon,
    required this.name,
    required this.tooltip,
    required this.url,
    required this.admin,
    required this.alaAdmin,
    required this.subtitle,
    this.help,
  });
}

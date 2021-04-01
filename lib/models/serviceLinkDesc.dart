import 'package:flutter/cupertino.dart';

class ServiceLinkDesc {
  final IconData icon;
  final String name;
  final String url;
  final bool admin;
  final bool alaAdmin;
  final String? help;
  ServiceLinkDesc(
      {required this.icon,
      required this.name,
      required this.url,
      required this.admin,
      required this.alaAdmin,
      this.help});
}

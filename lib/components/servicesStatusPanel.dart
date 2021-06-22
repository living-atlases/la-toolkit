import 'package:flutter/material.dart';
import 'package:la_toolkit/components/serviceStatusCard.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';

class ServicesStatusPanel extends StatelessWidget {
  final List<ProdServiceDesc> services;
  const ServicesStatusPanel({Key? key, required this.services})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ProdServiceDesc> filteredServices = services
        .where((s) =>
            s.nameInt != LAServiceName.branding.toS() &&
            s.nameInt != LAServiceName.nameindexer.toS() &&
            s.nameInt != LAServiceName.biocache_cli.toS())
        .toList();
    return Wrap(children: [
      for (var service in filteredServices) ServiceStatusCard(service)
    ]);
  }
}

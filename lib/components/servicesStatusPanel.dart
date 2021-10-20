import 'package:flutter/material.dart';
import 'package:la_toolkit/components/serviceStatusCard.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';

class ServicesStatusPanel extends StatelessWidget {
  final List<ProdServiceDesc> services;
  const ServicesStatusPanel({Key? key, required this.services})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<ProdServiceDesc> filteredServices = services
        .where((s) =>
            s.nameInt != branding &&
            s.nameInt != nameindexer &&
            s.nameInt != biocacheCli)
        .toList();
    return Wrap(children: [
      for (var service in filteredServices) ServiceStatusCard(service)
    ]);
  }
}

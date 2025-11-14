import 'package:flutter/material.dart';


import '../models/LAServiceConstants.dart';
import '../models/prodServiceDesc.dart';
import 'service_status_card.dart';

class ServicesStatusPanel extends StatelessWidget {
  const ServicesStatusPanel({super.key, required this.services});

  final List<ProdServiceDesc> services;

  @override
  Widget build(BuildContext context) {
    final List<ProdServiceDesc> filteredServices = services
        .where((ProdServiceDesc s) =>
            s.nameInt != branding &&
            s.nameInt != nameindexer &&
            s.nameInt != dockerCommon &&
            s.nameInt != biocacheCli)
        .toList();
    return Wrap(children: <Widget>[
      for (final ProdServiceDesc service in filteredServices)
        ServiceStatusCard(service)
    ]);
  }
}

import 'package:flutter/material.dart';
import '../models/la_service_constants.dart';
import '../models/prod_service_desc.dart';
import 'service_status_card.dart';

class ServicesStatusPanel extends StatelessWidget {
  const ServicesStatusPanel({super.key, required this.services});

  final List<ProdServiceDesc> services;

  @override
  Widget build(BuildContext context) {
    final List<ProdServiceDesc> filteredServices = services
        .where(
          (ProdServiceDesc s) =>
              s.nameInt != branding &&
              s.nameInt != nameindexer &&
              s.nameInt != dockerCommon &&
              s.nameInt != biocacheCli,
        )
        .toList();
    return Wrap(
      children: <Widget>[
        for (final ProdServiceDesc service in filteredServices)
          ServiceStatusCard(service),
      ],
    );
  }
}

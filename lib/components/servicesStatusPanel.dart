import 'package:flutter/material.dart';
import 'package:la_toolkit/components/serviceStatusCard.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';

class ServicesStatusPanel extends StatelessWidget {
  final List<ProdServiceDesc> services;
  ServicesStatusPanel({Key? key, required this.services}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: [for (var service in services) ServiceStatusCard(service)]);
  }
}

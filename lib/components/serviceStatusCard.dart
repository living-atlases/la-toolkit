import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../laTheme.dart';
import '../models/LAServiceConstants.dart';
import '../models/la_service.dart';
import '../models/prodServiceDesc.dart';
import '../utils/StringUtils.dart';
import '../utils/cardConstants.dart';
import 'adminIconButton.dart';

class ServiceStatusCard extends StatelessWidget {
  const ServiceStatusCard(this.service, {super.key});

  final ProdServiceDesc service;
  static const TextStyle subtitle = TextStyle(color: LAColorTheme.inactive);

  @override
  Widget build(BuildContext context) {
    const double iconDefSize = 18;

    // debugPrint(service.serviceDeploys);
    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: const EdgeInsets.all(10),
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(children: <Widget>[
                  Tooltip(
                      message:
                          'Status: ${StringUtils.capitalize(service.status.toSforHumans())}',
                      child: Icon(service.icon,
                          size: 30, color: service.status.color)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(service.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text(service.subtitle, style: subtitle),
                    ],
                  ),
                  const SizedBox(width: 5),
                  ServiceSmallLinks(service: service, iconDefSize: iconDefSize),
                ]))));
  }
}

class ServiceSmallLinks extends StatelessWidget {
  const ServiceSmallLinks({
    super.key,
    required this.service,
    required this.iconDefSize,
  });

  final ProdServiceDesc service;
  final double iconDefSize;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (service.nameInt != biocacheBackend)
            SimpleServiceStatusItem(
                icon: Tooltip(
                    message: service.tooltip,
                    child: InkWell(
                      child: Icon(Icons.link,
                          size: iconDefSize, color: LAColorTheme.link),
                      onTap: () async => launchUrl(Uri.parse(service.url)),
                    ))),
          if (service.admin)
            SimpleServiceStatusItem(
                icon: AdminIconButton(
                    url: service.url,
                    color: LAColorTheme.link,
                    size: iconDefSize,
                    tooltip: 'Admin section',
                    min: true)),
          if (service.alaAdmin)
            SimpleServiceStatusItem(
                icon: AdminIconButton(
                    url: service.url,
                    color: LAColorTheme.link,
                    size: iconDefSize,
                    tooltip: 'AlaAdmin section',
                    min: true,
                    alaAdmin: true)),
        ]);
  }
}

class SimpleServiceStatusItem extends StatelessWidget {
  const SimpleServiceStatusItem({super.key, required this.icon});

  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Row(children: <Widget>[
      icon,
    ]);
  }
}

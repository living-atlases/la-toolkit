import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/components/adminIconButton.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/LAServiceConstants.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceStatusCard extends StatelessWidget {
  final ProdServiceDesc service;
  static const TextStyle subtitle = TextStyle(color: LAColorTheme.inactive);

  const ServiceStatusCard(this.service, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconDefSize = 18;

    // print(service.serviceDeploys);
    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: const EdgeInsets.all(10),
            child: Padding(
                padding: const EdgeInsets.all(5),
                child: Row(children: [
                  Tooltip(
                      message:
                          "Status: ${StringUtils.capitalize(service.status.toSforHumans())}",
                      child: Icon(service.icon,
                          size: 30, color: service.status.color)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
    Key? key,
    required this.service,
    required this.iconDefSize,
  }) : super(key: key);

  final ProdServiceDesc service;
  final double iconDefSize;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (service.nameInt != biocacheBackend)
            SimpleServiceStatusItem(
                icon: Tooltip(
                    message: service.tooltip,
                    child: InkWell(
                      child: Icon(Icons.link,
                          size: iconDefSize, color: LAColorTheme.link),
                      onTap: () async => await launch(service.url),
                    ))),
          if (service.admin)
            SimpleServiceStatusItem(
                icon: AdminIconButton(
                    url: service.url,
                    color: LAColorTheme.link,
                    size: iconDefSize,
                    tooltip: "Admin section",
                    min: true)),
          if (service.alaAdmin)
            SimpleServiceStatusItem(
                icon: AdminIconButton(
                    url: service.url,
                    color: LAColorTheme.link,
                    size: iconDefSize,
                    tooltip: "AlaAdmin section",
                    min: true,
                    alaAdmin: true)),
        ]);
  }
}

class SimpleServiceStatusItem extends StatelessWidget {
  final Widget icon;
  const SimpleServiceStatusItem({Key? key, required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      icon,
    ]);
  }
}

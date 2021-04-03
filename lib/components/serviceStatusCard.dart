import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/components/adminIconButton.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/prodServiceDesc.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceStatusCard extends StatelessWidget {
  final ProdServiceDesc service;
  static final TextStyle subtitle = TextStyle(color: LAColorTheme.inactive);

  ServiceStatusCard(this.service);

  @override
  Widget build(BuildContext context) {
    double iconDefSize = 18;

    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: EdgeInsets.all(10),
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(children: [
                  Icon(service.icon, size: 30, color: service.status.color),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 5),
                      Text(service.subtitle, style: subtitle),
                    ],
                  ),
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
  SimpleServiceStatusItem({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      icon,
    ]);
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/components/adminIconButton.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/serviceLinkDesc.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceStatusCard extends StatelessWidget {
  final ServiceLinkDesc service;
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
                  Icon(service.icon,
                      size: 30, color: ResultType.unreachable.color),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 5),
                      Text(service.subtitle,
                          style: TextStyle(color: LAColorTheme.inactive)),
                    ],
                  ),
                  SizedBox(width: 20),
                  // Expanded(
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SimpleServiceStatusItem(
                            icon: Tooltip(
                                message: service.tooltip,
                                child: InkWell(
                                  child: Icon(Icons.link,
                                      size: iconDefSize,
                                      color: LAColorTheme.link),
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
                        /*   SimpleServiceStatusItem(
                            "SSH",
                            service.sshReachable,
                            'SSH access to this service is ok',
                            'I cannot SSH to this service, review your SSH config and keys for this service'),
                        SimpleServiceStatusItem(
                            "SUDO",
                            service.sudoEnabled,
                            'SUDO is enabled for this service',
                            'SUDO is not enabled in the service for this user') */
                      ])
                ]))));
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

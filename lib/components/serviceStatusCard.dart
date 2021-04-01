import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/components/adminIconButton.dart';
import 'package:la_toolkit/components/statusIcon.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/basicService.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/serviceLinkDesc.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:la_toolkit/utils/resultTypes.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceStatusCard extends StatelessWidget {
  final ServiceLinkDesc service;
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
                  Icon(service.icon,
                      size: 30, color: ResultType.unreachable.color),
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
                  if (service.deps != null) DepsPanel(service.deps!),
                  SizedBox(width: 20),
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

  final ServiceLinkDesc service;
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

class DepsPanel extends StatelessWidget {
  final List<BasicService> deps;
  DepsPanel(this.deps);
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var dep in deps.where((dep) => dep.name != "java"))
                Row(children: [
                  StatusIcon(CmdResult.success, size: 10),
                  SizedBox(width: 3),
                  Text(dep.name)
                ])
            ]));
  }
}

import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/components/serviceStatusCard.dart';
import 'package:la_toolkit/components/statusIcon.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/basicService.dart';
import 'package:la_toolkit/models/cmdHistoryEntry.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDepsDesc.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:mdi/mdi.dart';

class ServerStatusCard extends StatelessWidget {
  final LAServer server;
  final bool extendedStatus;
  final List<LAService> services;
  final String alaInstallVersion;
  final VoidCallback onTerm;
  ServerStatusCard(
      {required this.server,
      required this.extendedStatus,
      required this.services,
      required this.alaInstallVersion,
      required this.onTerm});

  @override
  Widget build(BuildContext context) {
    Map<String, LAServiceDepsDesc> despForV =
        LAServiceDepsDesc.getDeps(alaInstallVersion);
    LinkedHashSet<BasicService> deps = LinkedHashSet<BasicService>();
    services.forEach((service) {
      LAServiceDepsDesc? serDepDesc = despForV[service.nameInt];
      if (serDepDesc != null) deps.addAll(serDepDesc.serviceDepends);
    });
    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: const EdgeInsets.all(10),
            child: Padding(
                padding: EdgeInsets.all(extendedStatus ? 10 : 5),
                child: Row(children: [
                  Column(children: [
                    Tooltip(
                        message: "Open a terminal in ${server.name}",
                        child: ElevatedButton(
                          child: Icon(
                            Mdi.console,
                            color: statusUpDownColor(),
                            size: 36,
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              elevation: 10,
                              shadowColor: Colors.green,
                              minimumSize: Size(0, 0),
                              padding: EdgeInsets.fromLTRB(1, 1, 1, 0),
                              enableFeedback: true),
                          onPressed: () => onTerm(),
                        ))
                  ]),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(server.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text("IP: ${server.ip}", style: GoogleFonts.robotoMono()),
                      if (extendedStatus) const SizedBox(height: 10),
                      if (extendedStatus)
                        Container(
                            width: 140,
                            child: ConnectivityStatus(server: server)),
                      if (extendedStatus) const SizedBox(height: 10),
                      if (extendedStatus)
                        Container(
                            width: 140,
                            child: RichText(
                              overflow: TextOverflow.visible,
                              softWrap: true,
                              text: TextSpan(
                                  text: services
                                      .map((service) => StringUtils.capitalize(
                                          LAServiceDesc.get(service.nameInt)
                                              .name))
                                      .toList()
                                      .join(', '),
                                  style: ServiceStatusCard.subtitle),
                            )),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Expanded(
                  if (!extendedStatus) ConnectivityStatus(server: server),
                  if (extendedStatus) const SizedBox(width: 10),
                  if (extendedStatus) DepsPanel(deps),
                ]))));
  }

  Color statusUpDownColor() {
    return server.isReady() ? LAColorTheme.up : LAColorTheme.down;
  }
}

class ConnectivityStatus extends StatelessWidget {
  const ConnectivityStatus({
    Key? key,
    required this.server,
  }) : super(key: key);

  final LAServer server;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SimpleServerStatusItem(
              "REACHABLE",
              server.reachable,
              'Ping to this server works great',
              'I cannot reach this server, review your IP and ssh configuration for this server'),
          SimpleServerStatusItem(
              "SSH",
              server.sshReachable,
              'SSH access to this server is ok',
              'I cannot SSH to this server, review your SSH config and keys for this server'),
          SimpleServerStatusItem(
              "SUDO",
              server.sudoEnabled,
              'SUDO is enabled for this server',
              'SUDO is not enabled in the server for this user')
        ]);
  }
}

class SimpleServerStatusItem extends StatelessWidget {
  final String text;
  final ServiceStatus status;
  final String successHint;
  final String errorHint;
  SimpleServerStatusItem(
      this.text, this.status, this.successHint, this.errorHint);

  @override
  Widget build(BuildContext context) {
    bool ready = status == ServiceStatus.success;
    Color readyColor = ready ? LAColorTheme.up : LAColorTheme.down;
    return Tooltip(
        message: ready ? successHint : errorHint,
        child: Row(children: [
          Text(text,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: readyColor)),
          Icon(
              ready
                  ? Icons.check
                  : Icons.error_outline, // Icons.cancel_outlined,
              size: 14,
              color: readyColor)
        ]));
  }
}

class DepsPanel extends StatelessWidget {
  final LinkedHashSet<BasicService> deps;
  const DepsPanel(this.deps);

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
                  const StatusIcon(CmdResult.success, size: 10),
                  const SizedBox(width: 3),
                  Text(dep.name)
                ])
            ]));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/components/defDivider.dart';
import 'package:la_toolkit/components/serviceStatusCard.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/models/laService.dart';
import 'package:la_toolkit/models/laServiceDesc.dart';
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:mdi/mdi.dart';

class ServerStatusCard extends StatelessWidget {
  final LAServer server;
  final bool extendedStatus;
  final List<String> services;
  ServerStatusCard(this.server, this.services, this.extendedStatus);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: EdgeInsets.all(10),
            child: Padding(
                padding: EdgeInsets.all(extendedStatus ? 10 : 5),
                child: Row(children: [
                  Icon(Mdi.serverNetwork,
                      size: extendedStatus ? 40 : 30,
                      color: server.isReady()
                          ? LAColorTheme.up
                          : LAColorTheme.down),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(server.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 5),
                      Text("IP: ${server.ip}", style: GoogleFonts.robotoMono()),
                      if (extendedStatus) DefDivider(),
                      if (extendedStatus)
                        Container(
                            width: 140,
                            child: RichText(
                              overflow: TextOverflow.visible,
                              softWrap: true,
                              text: TextSpan(
                                  text: services
                                      .map((nameInt) => StringUtils.capitalize(
                                          LAServiceDesc.get(nameInt).name))
                                      .toList()
                                      .join(', '),
                                  style: ServiceStatusCard.subtitle),
                            ))
                      /* for (var service in services)
                          Text(
                            StringUtils.capitalize(
                                LAServiceDesc.map[service]!.name),
                            textAlign: TextAlign.right,
                          )*/
                    ],
                  ),
                  SizedBox(width: 20),
                  // Expanded(
                  Column(
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
                      ])
                ]))));
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

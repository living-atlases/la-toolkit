import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:la_toolkit/laTheme.dart';
import 'package:la_toolkit/models/laServer.dart';
import 'package:la_toolkit/utils/cardContants.dart';
import 'package:mdi/mdi.dart';

class ServerDiagram extends StatelessWidget {
  final LAServer server;
  ServerDiagram(this.server);

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: Card(
            elevation: CardConstants.defaultElevation,
            // color: Colors.black12,
            margin: EdgeInsets.all(10),
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Row(children: [
                  Icon(Mdi.serverNetwork,
                      size: 30,
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
                      Text(server.ip),
                    ],
                  ),
                  SizedBox(width: 20),
                  // Expanded(
                  Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _createStatus(
                            "REACHABLE",
                            server.reachable,
                            'Ping to this server works great',
                            'I cannot reach this server, review your IP and ssh configuration for this server'),
                        _createStatus(
                            "SSH",
                            server.sshReachable,
                            'SSH access to this server is ok',
                            'I cannot SSH to this server, review your SSH config and keys for this server'),
                        _createStatus(
                            "SUDO",
                            server.sudoEnabled,
                            'SUDO is enabled for this server',
                            'SUDO is not enabled in the server for this user')
                      ])
                ]))));
  }

  _createStatus(
      String text, ServiceStatus status, String successHint, String errorHint) {
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

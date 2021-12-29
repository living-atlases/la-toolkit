import 'dart:collection';

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
import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:la_toolkit/utils/cardConstants.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuple/tuple.dart';

class ServerStatusCard extends StatelessWidget {
  final LAServer server;
  final bool extendedStatus;
  final List<LAService> services;
  final String alaInstallVersion;
  final VoidCallback onTerm;
  final List<dynamic> status;
  const ServerStatusCard(
      {Key? key,
      required this.server,
      required this.extendedStatus,
      required this.services,
      required this.alaInstallVersion,
      required this.onTerm,
      required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, LAServiceDepsDesc> depsForV =
        LAServiceDepsDesc.getDeps(alaInstallVersion);
    LinkedHashSet<BasicService> deps = LinkedHashSet<BasicService>();
    for (LAService service in services) {
      LAServiceDepsDesc? serDepDesc = depsForV[service.nameInt];
      if (serDepDesc != null) {
        deps.addAll(BasicService.toCheck(serDepDesc.serviceDepends));
      }
    }
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
                            MdiIcons.console,
                            color: statusUpDownColor(),
                            size: 36,
                          ),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              elevation: 10,
                              shadowColor: Colors.green,
                              minimumSize: const Size(0, 0),
                              padding: const EdgeInsets.fromLTRB(1, 1, 1, 0),
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
                        // ignore: sized_box_for_whitespace
                        Container(
                            width: 140,
                            child: ConnectivityStatus(server: server)),
                      if (extendedStatus) const SizedBox(height: 10),
                      if (extendedStatus)
                        // ignore: sized_box_for_whitespace
                        Container(
                            width: 140,
                            child: RichText(
                              overflow: TextOverflow.visible,
                              softWrap: true,
                              text: TextSpan(
                                  text: LAService.servicesForHumans(services),
                                  style: ServiceStatusCard.subtitle),
                            )),
                    ],
                  ),
                  const SizedBox(width: 20),
                  // Expanded(
                  if (!extendedStatus) ConnectivityStatus(server: server),
                  if (extendedStatus) const SizedBox(width: 10),
                  if (extendedStatus) DepsPanel(deps, status),
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
              server.reachable == ServiceStatus.success ||
                  server.sshReachable == ServiceStatus.success,
              server.sshReachable == ServiceStatus.success
                  ? 'I cannot ping this server, although I can reach it by ssh. Is the ping filtered in your firewall?'
                  : 'Ping to this server works great',
              'I cannot reach this server, review your IP and ssh configuration for this server'),
          SimpleServerStatusItem(
              "SSH",
              server.sshReachable == ServiceStatus.success,
              'SSH access to this server is ok',
              'I cannot SSH to this server, review your SSH config and keys for this server'),
          SimpleServerStatusItem(
              "SUDO",
              server.sudoEnabled == ServiceStatus.success,
              'SUDO is enabled for this server',
              'SUDO is not enabled in the server for this user')
        ]);
  }
}

class SimpleServerStatusItem extends StatelessWidget {
  final String text;
  final bool ready;
  final String successHint;
  final String errorHint;
  const SimpleServerStatusItem(
      this.text, this.ready, this.successHint, this.errorHint,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  final List<dynamic> status;
  const DepsPanel(this.deps, this.status, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<BasicService, CmdResult> depStatus = {};
    for (BasicService dep in deps) {
      int depCodeStatus = 0;
      int checks = 0;
      for (num tcp in dep.tcp) {
        String type = "tcp";
        Tuple2<int, int> r = checkResultForType(type, "$tcp");
        depCodeStatus += r.item2;
        checks += r.item1;
      }
      for (num udp in dep.udp) {
        String type = "udp";
        Tuple2<int, int> r = checkResultForType(type, "$udp");
        depCodeStatus += r.item2;
        checks += r.item1;
      }
      Tuple2<int, int> r = checkResultForType(dep.name, "");
      depCodeStatus += r.item2;
      checks += r.item1;
      depStatus[dep] = checks == 0
          ? CmdResult.unknown
          : (depCodeStatus == 0 ? CmdResult.success : CmdResult.failed);
    }

    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var dep in deps)
                Tooltip(
                    message:
                        "Status: ${StringUtils.capitalize(depStatus[dep]!.toServiceForHumans())}",
                    child: Row(children: [
                      StatusIcon(depStatus[dep]!, size: 12),
                      const SizedBox(width: 3),
                      Text(dep.name)
                    ]))
            ]));
  }

  Tuple2<int, int> checkResultForType(String type, String value) {
    int depCodeStatus = 0;
    List<dynamic> matchs = status
        .where((s) => s['service'] == "check_$type" && s['args'] == value)
        .toList();
    for (var match in matchs) {
      depCodeStatus += int.parse(match['code'] ?? '0');
    }
    return Tuple2(matchs.length, depCodeStatus);
  }
}

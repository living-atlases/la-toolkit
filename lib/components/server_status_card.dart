import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:tuple/tuple.dart';

import '../laTheme.dart';
import '../models/basic_service.dart';
import '../models/cmdHistoryEntry.dart';
import '../models/laServer.dart';
import '../models/laServiceDepsDesc.dart';
import '../models/la_service.dart';
import '../utils/StringUtils.dart';
import '../utils/cardConstants.dart';
import 'serviceStatusCard.dart';
import 'statusIcon.dart';

class ServerStatusCard extends StatelessWidget {
  const ServerStatusCard(
      {super.key,
      required this.server,
      required this.extendedStatus,
      required this.services,
      required this.alaInstallVersion,
      required this.onTerm,
      required this.status});

  final LAServer server;
  final bool extendedStatus;
  final List<LAService> services;
  final String alaInstallVersion;
  final VoidCallback onTerm;
  final List<dynamic> status;

  @override
  Widget build(BuildContext context) {
    final Map<String, LAServiceDepsDesc> depsForV =
        LAServiceDepsDesc.getDeps(alaInstallVersion);
    final LinkedHashSet<BasicService> deps = LinkedHashSet<BasicService>();
    for (final LAService service in services) {
      final LAServiceDepsDesc? serDepDesc = depsForV[service.nameInt];
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
                child: Row(children: <Widget>[
                  Column(children: <Widget>[
                    Tooltip(
                        message: 'Open a terminal in ${server.name}',
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              elevation: 10,
                              shadowColor: Colors.green,
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.fromLTRB(1, 1, 1, 0),
                              enableFeedback: true),
                          onPressed: () => onTerm(),
                          child: Icon(
                            MdiIcons.console,
                            color: statusUpDownColor(),
                            size: 36,
                          ),
                        ))
                  ]),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(server.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 5),
                      Text('IP: ${server.ip}', style: GoogleFonts.robotoMono()),
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
                              // softWrap: true,
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
    super.key,
    required this.server,
  });

  final LAServer server;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          SimpleServerStatusItem(
              'REACHABLE',
              server.reachable == ServiceStatus.success ||
                  server.sshReachable == ServiceStatus.success,
              server.sshReachable == ServiceStatus.success
                  ? 'I cannot ping this server, although I can reach it by ssh. Is the ping filtered in your firewall?'
                  : 'Ping to this server works great',
              'I cannot reach this server, review your IP and ssh configuration for this server'),
          SimpleServerStatusItem(
              'SSH',
              server.sshReachable == ServiceStatus.success,
              'SSH access to this server is ok',
              'I cannot SSH to this server, review your SSH config and keys for this server'),
          SimpleServerStatusItem(
              'SUDO',
              server.sudoEnabled == ServiceStatus.success,
              'SUDO is enabled for this server',
              'SUDO is not enabled in the server for this user')
        ]);
  }
}

class SimpleServerStatusItem extends StatelessWidget {
  const SimpleServerStatusItem(
      this.text, this.ready, this.successHint, this.errorHint,
      {super.key});

  final String text;
  final bool ready;
  final String successHint;
  final String errorHint;

  @override
  Widget build(BuildContext context) {
    final Color readyColor = ready ? LAColorTheme.up : LAColorTheme.down;
    return Tooltip(
        message: ready ? successHint : errorHint,
        child: Row(children: <Widget>[
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
  const DepsPanel(this.deps, this.status, {super.key});

  final LinkedHashSet<BasicService> deps;
  final List<dynamic> status;

  @override
  Widget build(BuildContext context) {
    final Map<BasicService, CmdResult> depStatus = <BasicService, CmdResult>{};
    for (final BasicService dep in deps) {
      int depCodeStatus = 0;
      int checks = 0;
      for (final num tcp in dep.tcp) {
        const String type = 'tcp';
        final Tuple2<int, int> r = checkResultForType(type, '$tcp');
        depCodeStatus += r.item2;
        checks += r.item1;
      }
      for (final num udp in dep.udp) {
        const String type = 'udp';
        final Tuple2<int, int> r = checkResultForType(type, '$udp');
        depCodeStatus += r.item2;
        checks += r.item1;
      }
      final Tuple2<int, int> r = checkResultForType(dep.name, '');
      depCodeStatus += r.item2;
      checks += r.item1;
      depStatus[dep] = checks == 0
          ? CmdResult.unknown
          : (depCodeStatus == 0 ? CmdResult.success : CmdResult.failed);
    }

    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
        child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final BasicService dep in deps)
                Tooltip(
                    message:
                        'Status: ${StringUtils.capitalize(depStatus[dep]!.toServiceForHumans())}',
                    child: Row(children: <Widget>[
                      StatusIcon(depStatus[dep]!), // , size: 12),
                      const SizedBox(width: 3),
                      Text(dep.name)
                    ]))
            ]));
  }

  Tuple2<int, int> checkResultForType(String type, String value) {
    int depCodeStatus = 0;
    final List<dynamic> matchs = status
        .where(
            (dynamic s) => s['service'] == 'check_$type' && s['args'] == value)
        .toList();
    for (final dynamic match in matchs) {
      final String? mS = match['code'] as String?;
      depCodeStatus += int.parse(mS ?? '0');
    }
    return Tuple2<int, int>(matchs.length, depCodeStatus);
  }
}

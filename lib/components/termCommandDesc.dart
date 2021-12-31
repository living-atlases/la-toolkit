import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../laTheme.dart';

class TermCommandDesc extends StatelessWidget {
  const TermCommandDesc({
    Key? key,
    required this.cmdHistoryDetails,
  }) : super(key: key);

  final CmdHistoryDetails cmdHistoryDetails;

  @override
  Widget build(BuildContext context) {
    String cmd = cmdHistoryDetails.cmd!.rawCmd;
    Widget? subtitle;
    const subColor = Colors.grey;
    String cwd = cmdHistoryDetails.cmd!.invDir.isNotEmpty
        ? cmdHistoryDetails.cmd!.invDir
        : cmdHistoryDetails.cmd!.cwd != null &&
                cmdHistoryDetails.cmd!.cwd!.isNotEmpty
            ? cmdHistoryDetails.cmd!.cwd!
            : "";
    if (cwd.isNotEmpty) {
      subtitle = RichText(
          overflow: TextOverflow.visible,
          textAlign: TextAlign.left,
          softWrap: true,
          text: TextSpan(children: <TextSpan>[
            const TextSpan(
                text: 'Executed in directory: ',
                style: TextStyle(color: subColor)),
            TextSpan(text: cwd, style: GoogleFonts.robotoMono(color: subColor)),
            // TextSpan(text: ""),
          ]));
    }
    return ListTile(
        leading: const Icon(MdiIcons.console,
            size: 36, color: LAColorTheme.laPalette),
        title: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () => onTap(cmd, context),
                child: Text(cmd,
                    style: GoogleFonts.robotoMono(
                        color: LAColorTheme.inactive, fontSize: 18)))),
        subtitle: subtitle,
        trailing: Tooltip(
            message: "Press to copy the command",
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => onTap(cmd, context),
            )));
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> onTap(
      String cmd, BuildContext context) {
    return FlutterClipboard.copy(cmd).then((value) =>
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Command copied to clipboard"))));
  }
}

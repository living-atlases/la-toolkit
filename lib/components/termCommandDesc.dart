import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:la_toolkit/models/cmdHistoryDetails.dart';
import 'package:mdi/mdi.dart';

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
    if (cmdHistoryDetails.cmd!.invDir != "")
      subtitle = RichText(
          overflow: TextOverflow.visible,
          textAlign: TextAlign.left,
          softWrap: true,
          text: TextSpan(children: <TextSpan>[
            TextSpan(
                text: 'Executed in directory: ',
                style: const TextStyle(color: subColor)),
            TextSpan(
                text: cmdHistoryDetails.cmd!.invDir,
                style: GoogleFonts.robotoMono(color: subColor)),
            // TextSpan(text: ""),
          ]));
    return ListTile(
        leading: Icon(Mdi.console, size: 36, color: LAColorTheme.laPalette),
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
              icon: Icon(Icons.copy),
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

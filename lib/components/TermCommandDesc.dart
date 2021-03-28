import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
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
    String cmd = cmdHistoryDetails.cmd!.cmd;
    return ListTile(
        leading: Icon(Mdi.console, size: 36, color: LAColorTheme.laPalette),
        title: Text(cmd,
            style: GoogleFonts.robotoMono(
                color: LAColorTheme.inactive, fontSize: 18)),
        trailing: Tooltip(
            message: "Press to copy the command",
            child: IconButton(
              icon: Icon(Icons.copy),
              onPressed: () => FlutterClipboard.copy(cmd).then((value) =>
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Command copied to clipboard")))),
            )));
  }
}

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../la_theme.dart';
import '../models/cmd_history_details.dart';

class TermCommandDesc extends StatelessWidget {
  const TermCommandDesc({
    super.key,
    required this.cmdHistoryDetails,
  });

  final CmdHistoryDetails cmdHistoryDetails;

  @override
  Widget build(BuildContext context) {
    final String cmd = cmdHistoryDetails.cmd!.rawCmd;
    Widget? subtitle;
    const MaterialColor subColor = Colors.grey;
    final String cwd = cmdHistoryDetails.cmd!.invDir.isNotEmpty
        ? cmdHistoryDetails.cmd!.invDir
        : cmdHistoryDetails.cmd!.cwd != null && cmdHistoryDetails.cmd!.cwd!.isNotEmpty
            ? cmdHistoryDetails.cmd!.cwd!
            : '';
    if (cwd.isNotEmpty) {
      subtitle = RichText(
          overflow: TextOverflow.visible,
          textAlign: TextAlign.left,
          text: TextSpan(children: <TextSpan>[
            const TextSpan(text: 'Executed in directory: ', style: TextStyle(color: subColor)),
            TextSpan(text: cwd, style: GoogleFonts.robotoMono(color: subColor)),
            // TextSpan(text: ""),
          ]));
    }
    return ListTile(
        leading: Icon(MdiIcons.console, size: 36, color: LAColorTheme.laPalette),
        title: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
                onTap: () => onTap(cmd, context),
                child: Text(cmd, style: GoogleFonts.robotoMono(color: LAColorTheme.inactive, fontSize: 18)))),
        subtitle: subtitle,
        trailing: Tooltip(
            message: 'Press to copy the command',
            child: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => onTap(cmd, context),
            )));
  }

  Future<ScaffoldFeatureController<SnackBar, SnackBarClosedReason>> onTap(String cmd, BuildContext context) {
    return FlutterClipboard.copy(cmd).then((value) =>
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Command copied to clipboard'))));
  }
}

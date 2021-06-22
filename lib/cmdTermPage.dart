import 'package:flutter/material.dart';

class CmdTermPage extends StatelessWidget {
  static const routeName = "term";

  /* Not used right now, but maybe in the future */

  final int port;
  final int ttydPid;
  const CmdTermPage({Key? key, required this.port, required this.ttydPid})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Material App Bar'),
      ),
      body: InteractiveViewer(
          child: Container(
        alignment: Alignment.center,
/*              width: 1000,
              height: 1000,*/
        // child: EmbedWebView(src: TermDialog.getInitialUrl(port)))),
      )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {},
      ),
    );
  }
}

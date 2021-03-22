import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';

class LaunchBtn extends StatelessWidget {
  const LaunchBtn({
    Key? key,
    this.onTap,
    required this.execBtn,
  }) : super(key: key);

  final VoidCallback? onTap;
  final String execBtn;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
          SizedBox(height: 40),
          ButtonTheme(
              // minWidth: 200.0,
              height: 100.0,
              child: ElevatedButton.icon(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      minimumSize: Size(140, 50),
                      // primary: LAColorTheme.laPalette,
                      // padding: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        // side: BorderSide(color: Colors.red)),
                      )),
                  icon: Icon(Mdi.rocketLaunch, size: 30),
                  label: new Text(execBtn, style: TextStyle(fontSize: 18))))
        ]));
  }
}

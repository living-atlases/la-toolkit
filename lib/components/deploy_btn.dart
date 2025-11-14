import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LaunchBtn extends StatelessWidget {
  LaunchBtn({
    super.key,
    this.onTap,
    required this.execBtn,
    IconData? icon,
  }) : icon = icon ?? MdiIcons.rocketLaunch;

  final VoidCallback? onTap;
  final String execBtn;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      const SizedBox(height: 40),
      ButtonTheme(
          // minWidth: 200.0,
          height: 100.0,
          child: ElevatedButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(
                  //backgroundColor: Theme.of(context).primaryColor,
                  minimumSize: const Size(140, 50),
                  // padding: const EdgeInsets.all(8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    // side: BorderSide(color: Colors.red)),
                  )),
              icon: Icon(icon, size: 30),
              label: Text(execBtn, style: const TextStyle(fontSize: 18))))
    ]));
  }
}

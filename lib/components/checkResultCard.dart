import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/models/laService.dart';

class CheckResultCard extends StatelessWidget {
  final ServiceStatus status;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? action;

  CheckResultCard(
      {required this.status,
      required this.title,
      required this.subtitle,
      this.actionText,
      this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
        child: Card(
            elevation: 2,
            color: status.backColor,
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  leading: Icon(status.icon, color: status.color),
                  trailing: actionText != null
                      ? TextButton(
                          child: Text(actionText!),
                          onPressed: () {
                            if (action != null) action!();
                          },
                        )
                      : null,
                  title: Text(title),
                  subtitle: Text(subtitle),
                ))));
  }
}

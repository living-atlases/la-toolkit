import 'package:flutter/material.dart';
import 'package:la_toolkit/models/laService.dart';

class CheckResultCard extends StatelessWidget {
  final ServiceStatus status;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? action;

  const CheckResultCard(
      {Key? key,
      required this.status,
      required this.title,
      required this.subtitle,
      this.actionText,
      this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
        child: Card(
            elevation: 2,
            color: status.backColor,
            child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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

import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {

  const AlertCard(
      {super.key,
      required this.message,
      this.actionText,
      this.action,
      this.icon,
      this.color});
  final String message;
  final String? actionText;
  final VoidCallback? action;
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(5, 10, 0, 0),
        child: Card(
            elevation: 2,
            color: color ?? Colors.lightGreen.shade100,
            child: Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  leading: Icon(icon ?? Icons.warning_amber_outlined,
                      color: Colors.orangeAccent),
                  trailing: actionText != null
                      ? TextButton(
                          child: Text(actionText!),
                          onPressed: () {
                            if (action != null) action!();
                          },
                        )
                      : null,
                  title: Text(message),
                ))));
  }
}

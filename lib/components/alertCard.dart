import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AlertCard extends StatelessWidget {
  final String message;

  AlertCard({this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
        child: Card(
            elevation: 2,
            color: Colors.lightGreen.shade100,
            child: Container(
                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: ListTile(
                  contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  leading: Icon(Icons.warning_amber_outlined,
                      color: Colors.orangeAccent),
                  title: Text(message),
                ))));
  }
}

import 'package:flutter/material.dart';

class ChoiceEmptyPanel extends StatelessWidget {
  final String title;
  final String body;
  final String footer;
  ChoiceEmptyPanel(
      {required this.title, required this.body, required this.footer});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.search,
              color: Colors.grey,
              size: 120.0,
            ),
            const SizedBox(height: 25),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 20),
            ),
            const SizedBox(height: 7),
            Text(
              body,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 7),
            Text(
              footer,
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}

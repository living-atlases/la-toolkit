import 'package:flutter/material.dart';

class LoadingTextOverlay extends StatelessWidget {
  const LoadingTextOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            // SizedBox(height: 12),
            // Remove til we found a nice way to do it
            // Text(
            // 'Loading...',
            //),
          ],
        ),
      );
}

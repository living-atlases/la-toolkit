import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../la_theme.dart';

class CountDownWidget extends StatefulWidget {
  const CountDownWidget({super.key, required this.onReload});

  final void Function() onReload;

  @override
  State<CountDownWidget> createState() => _CountDownWidgetState();
}

class _CountDownWidgetState extends State<CountDownWidget> {
  final CountDownController _controller = CountDownController();
  final int _duration = 5;
  final double _size = 60;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Tooltip(
              message: 'Next check',
              child: CircularCountDownTimer(
                // Countdown duration in Seconds.
                duration: _duration * 60,
                // Countdown initial elapsed Duration in Seconds.
                // initialDuration: 0,
                // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                controller: _controller,
                // Width of the Countdown Widget.
                width: _size,
                // Height of the Countdown Widget.
                height: _size,
                // Ring Color for Countdown Widget.
                ringColor: Colors.grey[300]!,
                // Ring Gradient for Countdown Widget.
                // ringGradient: null,
                // Filling Color for Countdown Widget.
                // fillColor: Colors.purpleAccent[100]!,
                fillColor: LAColorTheme.laPalette.shade500,
                // Filling Gradient for Countdown Widget.
                // fillGradient: null,
                // Background Color for Countdown Widget.
                // backgroundColor: Colors.purple[500],
                // Background Gradient for Countdown Widget.
                // backgroundGradient: null,
                // Border Thickness of the Countdown Ring.
                strokeWidth: 10.0,
                // Begin and end contours with a flat edge and no extension.
                strokeCap: StrokeCap.round,
                // Text Style for Countdown Text.
                textStyle: TextStyle(
                  fontSize: 14.0,
                  color: LAColorTheme.laPalette,
                  fontWeight: FontWeight.bold,
                ),
                // Format for the Countdown Text.
                textFormat: CountdownTextFormat.MM_SS,
                // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                isReverse: true,
                // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                // isReverseAnimation: false,
                // Handles visibility of the Countdown Text.
                // isTimerTextShown: true,
                // Handles the timer start.
                // autoStart: true,
                // This Callback will execute when the Countdown Starts.
                onStart: () {
                  // Here, do whatever you want
                  // debugPrint('Countdown Started');
                },
                // This Callback will execute when the Countdown Ends.
                onComplete: () {
                  // Here, do whatever you want
                  // debugPrint('Countdown Ended');
                  _controller.start();
                  widget.onReload();
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                /*  SizedBox(
            width: 30,
          ),
          _button(title: "Start", onPressed: () => _controller.start()), */
                const SizedBox(width: 10),
                _button(
                  title: 'Pause',
                  icon: Icons.pause,
                  onPressed: () => _controller.pause(),
                ),
                /* SizedBox(
            width: 10,
          ),
          _button(title: "Resume", onPressed: () => _controller.resume()), */
                const SizedBox(width: 10),
                _button(
                  title: 'Refresh',
                  icon: MdiIcons.reload,
                  onPressed: () {
                    _controller.restart();
                    widget.onReload();
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _button({
    required String title,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: Icon(icon),
      tooltip: title,
      onPressed: onPressed, // color: Colors.purple,
    );
  }
}

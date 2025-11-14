import 'package:flutter/widgets.dart';

/* Not used yet */
class NetworkImageWPlaceHolder extends StatelessWidget {
  const NetworkImageWPlaceHolder(
      {super.key,
      required this.url,
      required this.height,
      required this.width});
  final String url;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return FadeInImage.assetNetwork(
        height: height,
        width: width,
        // don't have color ...
        placeholder: 'assets/images/la-icon.png',
        image: url);
  }
}

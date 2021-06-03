import 'package:flutter/widgets.dart';

/* Not used yet */
class NetworkImageWPlaceHolder extends StatelessWidget {
  final String url;
  final double height;
  final double width;

  const NetworkImageWPlaceHolder(
      {Key? key, required this.url, required this.height, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FadeInImage.assetNetwork(
            height: height,
            width: width,
            // don't have color ...
            placeholder: 'assets/images/la-icon.png',
            image: url));
  }
}

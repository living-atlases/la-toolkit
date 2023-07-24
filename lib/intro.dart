import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:la_toolkit/redux/actions.dart';
import 'package:la_toolkit/routes.dart';
import 'package:la_toolkit/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import 'laTheme.dart';
import 'models/appState.dart';

class Intro extends StatefulWidget {
  const Intro({Key? key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final introKey = GlobalKey<IntroductionScreenState>();
  static const _markdownColor = LAColorTheme.inactive;
  static const _markdownStyle = TextStyle(fontSize: 18);

  Widget _buildTitle(String title) {
    return Text(title,
        style: GoogleFonts.signika(
            textStyle: const TextStyle(
                color: Colors.black,
                fontSize: 38,
                fontWeight: FontWeight.w400)));
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );
    return StoreConnector<AppState, _IntroViewModel>(converter: (store) {
      return _IntroViewModel(
        state: store.state,
        onAddProject: () {
          store.dispatch(CreateProject());
          BeamerCond.of(context, LAProjectEditLocation());
        },
        onIntroEnd: () => store.dispatch(OnIntroEnd()),
      );
    }, builder: (BuildContext context, _IntroViewModel vm) {
      return IntroductionScreen(
        key: introKey,
        pages: [
          PageViewModel(
            titleWidget: _buildTitle("Welcome to the\nLiving Atlases Toolkit"),
            body: '''This tool facilitates the installation,
maintenance and monitor of
Living Atlases portals''',
            image: _buildImage(),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: _buildTitle("How?"),
            bodyWidget: _introText(
                text:
                    '''A Living Atlas (LA) can be deployed and maintained using:
1) the [Atlas of Living Australia](https://ala.org.au/) (ALA) Free and Open Source Software, with
2) the [ala-install](https://github.com/AtlasOfLivingAustralia/ala-install/), the official [ansible](https://www.ansible.com/) code that automatically deploy and maintain a Living Atlas (LA) portal
3) some configuration that describes your LA portal that is used by ala-install''',
                markdown: true),
            image: _buildImage('la-toolkit-intro-images-2.png'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: _buildTitle(
                "This LA Toolkit\nputs all these parts together..."),
            body:
                "...with an user friendly interface , and an up-to-date environment\nto perform the common maintenance tasks of a LA portal",
            image: _buildImage('la-toolkit-intro-images-3.png', 150),
            decoration: pageDecoration,
          ),
          if (AppUtils.isDemo())
            PageViewModel(
              titleWidget: _buildTitle("Just a demo"),
              body:
                  "Right now this website is only a demo\nof our toolkit for demonstration purposes",
              image: _buildImage('la-toolkit-intro-images-4.png', 150),
              decoration: pageDecoration,
            ),
          PageViewModel(
            title: "Ready to start?",
            bodyWidget: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Click on ", style: bodyStyle),
                Icon(Icons.add_circle),
                Text(" to create your first Living Atlas project",
                    style: bodyStyle),
              ],
            ),
            image: _buildImage('la-toolkit-intro-images-5.png', 150),
            decoration: pageDecoration,
            footer: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                vm.onIntroEnd();
                vm.onAddProject();
              },
            ),
          ),
        ],
        onDone: () => vm.onIntroEnd(),
        onSkip: () => vm.onIntroEnd(),
        showSkipButton: true,
        skipFlex: 0,
        nextFlex: 0,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: const DotsDecorator(
          size: Size(10.0, 10.0),
          color: Color(0xFFBDBDBD),
          activeSize: Size(22.0, 10.0),
          activeShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0)),
          ),
        ),
      );
    });
  }

  Widget _introText({required String text, bool markdown = false}) {
    // ignore: sized_box_for_whitespace
    return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        child: markdown
            ? MarkdownBody(
                shrinkWrap: true,
                fitContent: true,
                styleSheet: MarkdownStyleSheet(
                  h2: _markdownStyle,
                  p: _markdownStyle,
                  a: const TextStyle(
                      color: _markdownColor,
                      decoration: TextDecoration.underline),
                ),
                onTapLink: (text, href, title) async => await launchUrl(Uri.parse(href!)),
                data: text)
            : Text(text,
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 18.0, fontWeight: FontWeight.normal)));
  }

  Widget _buildImage([String? assetName, double? width]) {
    return Align(
      child: assetName == null
          ? Image.asset('assets/images/la-icon.png', width: 150.0)
          : Image.asset('assets/images/$assetName',
              width: width ?? MediaQuery.of(context).size.width * 0.5),
      alignment: Alignment.bottomCenter,
    );
  }
}

class _IntroViewModel {
  final AppState state;
  final void Function() onIntroEnd;
  final void Function() onAddProject;

  _IntroViewModel(
      {required this.state,
      required this.onIntroEnd,
      required this.onAddProject});
}

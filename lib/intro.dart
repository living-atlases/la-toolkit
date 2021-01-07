import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:la_toolkit/redux/actions.dart';

import 'models/appState.dart';

class Intro extends StatefulWidget {
  Intro({Key key}) : super(key: key);

  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final introKey = GlobalKey<IntroductionScreenState>();

  Widget _buildTitle(String title) {
    return Text(title,
        style: GoogleFonts.signika(
            textStyle: TextStyle(
                color: Colors.black,
                fontSize: 38,
                fontWeight: FontWeight.w400)));
  }

  Widget _buildImage(String assetName) {
    return Align(
      child: Image.asset('assets/images/la-icon.png', width: 100.0),
      // Image.asset('assets/$assetName.jpg', width: 350.0),
      alignment: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);
    const pageDecoration = const PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );
    return StoreConnector<AppState, _IntroViewModel>(converter: (store) {
      return _IntroViewModel(
        state: store.state,
        onAddProject: () => store.dispatch(CreateProject()),
        onIntroEnd: () => store.dispatch(OnIntroEnd()),
      );
    }, builder: (BuildContext context, _IntroViewModel vm) {
      return IntroductionScreen(
        key: introKey,
        pages: [
          PageViewModel(
            titleWidget: _buildTitle("Welcome to the\nLiving Atlases Toolkit"),
            body:
                "This tool try to facilitate the installation,\nmaintenance and monitor of LA portals",
            image: _buildImage('img1'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: _buildTitle("How?"),
            body: "Using a more easy web user interface blah blah blah... ",
            image: _buildImage('img2'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            titleWidget: _buildTitle("Just a demo"),
            body:
                "Right now this website is only a demo of the toolkit for demonstration purposes",
            image: _buildImage('img3'),
            decoration: pageDecoration,
          ),
          PageViewModel(
            title: "Ready to start?",
            bodyWidget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("Click on ", style: bodyStyle),
                Icon(Icons.add_circle),
                Text(" to create your first Living Atlas project",
                    style: bodyStyle),
              ],
            ),
            image: _buildImage('img1'),
            decoration: pageDecoration,
            footer: FloatingActionButton(
              child: Icon(Icons.add),
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
}

class _IntroViewModel {
  final AppState state;
  final void Function() onIntroEnd;
  final void Function() onAddProject;

  _IntroViewModel({this.state, this.onIntroEnd, this.onAddProject});
}

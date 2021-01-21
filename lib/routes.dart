import 'package:animations/animations.dart';
import 'package:flutter/widgets.dart';
import 'package:la_toolkit/projectEditPage.dart';
import 'package:la_toolkit/projectTunePage.dart';
import 'package:la_toolkit/projectViewPage.dart';
import 'package:la_toolkit/sandboxPage.dart';

import 'main.dart';

class Routes {
  static Route<T> fadeThrough<T>(RouteSettings settings, WidgetBuilder page,
      {int duration = 300}) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: Duration(milliseconds: duration),
      pageBuilder: (context, animation, secondaryAnimation) => page(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeScaleTransition(animation: animation, child: child);
      },
    );
  }

  static Route<T> onGenerateRoute<T>(RouteSettings settings) {
    return Routes.fadeThrough(settings, (context) {
      switch (settings.name) {
        case HomePage.routeName:
          return HomePage(title: appName);
          break;
        case LAProjectEditPage.routeName:
          return LAProjectEditPage();
          break;
        case LAProjectViewPage.routeName:
          return LAProjectViewPage();
          break;
        case SandboxPage.routeName:
          return SandboxPage();
        case LAProjectTunePage.routeName:
          return LAProjectTunePage();
          break;
        default:
          return HomePage(title: appName);
          break;
      }
    });
  }
}

/*
static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case ROUTE_HOME:
        final page = HomeScreen(settings.arguments);
        return MaterialPageRoute(builder: (context) => page);

      case ROUTE_SEARCH:
        final page = SearchScreen();
        return MaterialPageRoute(builder: (context) => page);

      default:
         return MaterialPageRoute(builder: (context) => LoginScreen());
    }
  }

}
*/

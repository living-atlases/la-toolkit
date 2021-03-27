import "package:flutter/material.dart";
import "package:flutter_redux/flutter_redux.dart";
import 'package:la_toolkit/components/appSnackBarMessage.dart';
import 'package:la_toolkit/models/appState.dart';
import 'package:la_toolkit/redux/actions.dart';

// Adapted from: https://github.com/brianegan/flutter_redux/issues/44
class AppSnackBar extends StatelessWidget {
  final Widget child;

  AppSnackBar(this.child);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _AppSnackBarViewModel>(
      converter: (store) => _AppSnackBarViewModel(
          messageToShow: store.state.appSnackBarMessages.length > 0
              ? store.state.appSnackBarMessages.first
              : AppSnackBarMessage.empty,
          onSnackBarShowed: (message) =>
              store.dispatch(OnShowedSnackBar(message))),
      builder: (context, view) => child,
      onWillChange: (oldVm, newVm) {
        // onDidChange: (newVm) {
        AppSnackBarMessage appSnackMessage = newVm.messageToShow;
        if (appSnackMessage != AppSnackBarMessage.empty) {
          // print(
          //    ">>>>>>>>>>>>>>>> Snackbar message '${appSnackMessage?.message}'");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(appSnackMessage.message),
            duration: appSnackMessage.duration ??
                Duration(
                    milliseconds: 4000), // 4000 is the default one in Flutter
            action: appSnackMessage.action,
          ));
          newVm.onSnackBarShowed(appSnackMessage);
          // newViewModel.setShowToastSuccessful();
        }
      },
      distinct: false,
    );
  }
}

class _AppSnackBarViewModel {
  Function onSnackBarShowed;
  final AppSnackBarMessage messageToShow;

  _AppSnackBarViewModel(
      {required this.onSnackBarShowed, required this.messageToShow});

  @override
  int get hashCode => messageToShow.hashCode;

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is _AppSnackBarViewModel &&
          other.messageToShow == this.messageToShow;
}

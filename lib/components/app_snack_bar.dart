import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../models/appState.dart';
import '../redux/actions.dart';
import 'appSnackBarMessage.dart';

// Adapted from: https://github.com/brianegan/flutter_redux/issues/44
class AppSnackBar extends StatelessWidget {
  const AppSnackBar(this.child, {super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _AppSnackBarViewModel>(
      converter: (Store<AppState> store) => _AppSnackBarViewModel(
          messageToShow: store.state.appSnackBarMessages.isNotEmpty
              ? store.state.appSnackBarMessages.first
              : AppSnackBarMessage.empty,
          onSnackBarShowed: (AppSnackBarMessage message) =>
              store.dispatch(OnShowedSnackBar(message))),
      builder: (BuildContext context, _AppSnackBarViewModel view) => child,
      onWillChange:
          (_AppSnackBarViewModel? oldVm, _AppSnackBarViewModel newVm) {
        // onDidChange: (newVm) {
        final AppSnackBarMessage appSnackMessage = newVm.messageToShow;
        if (appSnackMessage != AppSnackBarMessage.empty) {
          // print(
          //    ">>>>>>>>>>>>>>>> Snackbar message '${appSnackMessage?.message}'");
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(appSnackMessage.message),
            duration: appSnackMessage.duration ??
                const Duration(
                    milliseconds: 4000), // 4000 is the default one in Flutter
            action: appSnackMessage.action,
          ));
          newVm.onSnackBarShowed(appSnackMessage);
          // newViewModel.setShowToastSuccessful();
        }
      },
      // distinct: false,
    );
  }
}

@immutable
class _AppSnackBarViewModel {
  const _AppSnackBarViewModel(
      {required this.onSnackBarShowed, required this.messageToShow});

  final Function onSnackBarShowed;
  final AppSnackBarMessage messageToShow;

  @override
  int get hashCode => messageToShow.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _AppSnackBarViewModel && other.messageToShow == messageToShow;
}

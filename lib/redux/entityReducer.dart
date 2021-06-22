import 'package:la_toolkit/models/appState.dart';
import 'package:redux/redux.dart';

import 'entityActions.dart';

class EntityReducer<T> {
  final List<Reducer<AppState>> appReducer = [
    TypedReducer<AppState, RequestCreateOne<T>>(
        (AppState state, RequestCreateOne<T> action) {
      return state;
    }),
    TypedReducer<AppState, SuccessCreateOne<T>>(
        (AppState state, SuccessCreateOne<T> action) {
      return state;
    }),
  ];
}

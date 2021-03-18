import 'package:flutter/material.dart';

class AppSnackBarMessage {
  final String message;
  final Duration duration;

  final SnackBarAction action;

  AppSnackBarMessage({this.message, this.duration, this.action});

  static final AppSnackBarMessage empty = AppSnackBarMessage(message: "");

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSnackBarMessage &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

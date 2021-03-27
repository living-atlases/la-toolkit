import 'package:flutter/material.dart';

class AppSnackBarMessage {
  final String message;
  final Duration? duration;
  final SnackBarAction? action;
  static final AppSnackBarMessage empty = AppSnackBarMessage(message: "");

  AppSnackBarMessage({required this.message, this.duration, this.action});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSnackBarMessage &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;

  factory AppSnackBarMessage.ok(String message) => AppSnackBarMessage(
      message: message,
      duration: Duration(days: 365),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ));
}

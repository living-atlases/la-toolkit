import 'package:flutter/material.dart';

class AppSnackBarMessage {

  AppSnackBarMessage(this.message, [this.duration, this.action]);

  factory AppSnackBarMessage.ok(String message) => AppSnackBarMessage(
      message,
      const Duration(days: 365),
      SnackBarAction(
        label: 'OK',
        onPressed: () {},
      ));
  final String message;
  final Duration? duration;
  final SnackBarAction? action;
  static final AppSnackBarMessage empty = AppSnackBarMessage('');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSnackBarMessage &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

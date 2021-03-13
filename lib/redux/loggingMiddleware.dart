import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:redux_logging/redux_logging.dart';

enum LogLevel { none, actions, all }

LoggingMiddleware customLogPrinter<State>({
  Logger logger,
  Level level = Level.INFO,
  MessageFormatter<State> formatter = LoggingMiddleware.singleLineFormatter,
}) {
  String onlyLogActionFormatter<State>(
    State state,
    dynamic action,
    DateTime timestamp,
  ) {
    return " Action: >>>> $action <<<< }";
  }

  final middleware = new LoggingMiddleware<State>(
    logger: logger,
    level: level,
    formatter: onlyLogActionFormatter,
  );

  middleware.logger.onRecord
      .where((record) => record.loggerName == middleware.logger.name)
      .listen((Object object) {
    debugPrint("##################### $object");
  });

  return middleware;
}

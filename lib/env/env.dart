import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

@Envify(path: kReleaseMode ? '.env.production' : '.env.development')
abstract class Env {
  static const String sentryDsn = _Env.sentryDsn;
  static const bool demo = _Env.demo;
  static const String backend = _Env.backend;
}

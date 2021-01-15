import 'package:envify/envify.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

/*
@Envify()
abstract class Env {
  static const sentryDsn = _Env.sentryDsn;
}*/

@Envify(path: kReleaseMode ? '.env.production' : '.env.development')
abstract class Env {
  static const String sentryDsn = _Env.sentryDsn;
  static const bool demo = _Env.demo;
}

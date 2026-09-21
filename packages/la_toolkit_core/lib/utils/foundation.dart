// The few pieces of Flutter's `foundation` library the model uses, defined
// the same way, so the model behaves identically inside the app and outside
// it (CLI, MCP server) without depending on the Flutter SDK.
import 'package:collection/collection.dart';

export 'package:meta/meta.dart' show immutable, protected, visibleForTesting;

/// `true` in release builds; the Flutter tool defines `dart.vm.product` for
/// every platform, web included.
const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
const bool kProfileMode = bool.fromEnvironment('dart.vm.profile');
const bool kDebugMode = !kReleaseMode && !kProfileMode;

/// Element-wise equality of two lists, as Flutter's `listEquals`.
bool listEquals<T>(List<T>? a, List<T>? b) => const ListEquality<Object?>().equals(a, b);

/// Where the model's debug output goes. Plain `print` by default; the app
/// points it at Flutter's `debugPrint` at startup (throttled, and silenced
/// the same way in tests).
void Function(String? message, {int? wrapWidth}) debugPrint = _printDebug;

void _printDebug(String? message, {int? wrapWidth}) {
  // ignore: avoid_print
  print(message);
}

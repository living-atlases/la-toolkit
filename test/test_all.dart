// The model suites live in packages/la_toolkit_core/test (dart test there).

import 'src/passwd_test.dart' as passwd_test;
import 'src/versions_test.dart' as versions_test;

void main() {
  passwd_test.main();
  versions_test.main();
}

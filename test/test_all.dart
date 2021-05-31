import './src/basic_service_test.dart' as basic_service_test;
import './src/cmd_test.dart' as cmd_test;
import './src/passwd_test.dart' as passwd_test;
import './src/project_test.dart' as project_test;
import './src/regexp_test.dart' as regexp_test;
import './src/server_test.dart' as server_test;
import './src/service_desc_test.dart' as service_desc_test;
import './src/utils_test.dart' as utils_test;
import './src/versions_test.dart' as versions_test;
// import './src/widget_test.dart' as widget_test;

void main() {
  basic_service_test.main();
  basic_service_test.main();
  cmd_test.main();
  passwd_test.main();
  project_test.main();
  regexp_test.main();
  server_test.main();
  service_desc_test.main();
  utils_test.main();
  versions_test.main();
  // widget_test.main();
}

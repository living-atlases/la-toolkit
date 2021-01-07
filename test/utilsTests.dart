import 'package:la_toolkit/utils/StringUtils.dart';
import 'package:test/test.dart';

void main() {
  test('Capitalize strings', () {
    var string = 'abc';
    expect(StringUtils.capitalize(string), equals('Abc'));
  });

  test('Capitalize strings', () {
    var string = 'a';
    expect(StringUtils.capitalize(string), equals('A'));
  });

  test('Capitalize null strings', () {
    var string;
    expect(StringUtils.capitalize(string), equals(null));
  });

  test('Capitalize empty strings', () {
    var string = "";
    expect(StringUtils.capitalize(string), equals(""));
  });
}

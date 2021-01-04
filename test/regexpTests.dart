import 'package:la_toolkit/utils/regexp.dart';
import 'package:test/test.dart';

void main() {
  test('project long name regexp should not allow non letters', () {
    var string = '55l&&7%()';
    expect(FieldValidators.projectNameRegexp.hasMatch(string), equals(false));
  });
  test('project long name regexp should not allow non letters (cont)', () {
    var string = 'a#/&%()';
    expect(FieldValidators.projectNameRegexp.hasMatch(string), equals(false));
  });

  test('project long name regexp should allow valid simple names', () {
    var string = 'AEIOU';
    expect(FieldValidators.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow names with numbers', () {
    var string = 'AEIOU 1';
    expect(FieldValidators.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow valid tilde names', () {
    var string = 'áéíóú';
    expect(FieldValidators.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow valid unicode names', () {
    var string = 'αν ένας ανώνυμος';
    expect(FieldValidators.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('hostname regexp should not allow non letters', () {
    var string = 'vm org';
    expect(FieldValidators.hostnameRegexp.hasMatch(string), equals(false));
  });

  test('hostname regexp should allow valid hostnames', () {
    var string = 'vm-1-01';
    expect(FieldValidators.hostnameRegexp.hasMatch(string), equals(true));
  });
}

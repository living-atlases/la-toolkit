import 'package:la_toolkit/utils/regexp.dart';
import 'package:test/test.dart';

void main() {
  test('project long name regexp should not allow non letters', () {
    var string = '55l&&7%()';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(false));
  });
  test('project long name regexp should not allow non letters (cont)', () {
    var string = 'a#/&%()';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(false));
  });

  test('project long name regexp should allow valid simple names', () {
    var string = 'AEIOU';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow names with numbers', () {
    var string = 'AEIOU 1';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow names with dot', () {
    var string = 'AEIOU.1';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow valid tilde names', () {
    var string = 'áéíóú';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow valid unicode names', () {
    var string = 'αν ένας ανώνυμος';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('hostname regexp should not allow non letters', () {
    var string = 'vm org';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(false));
  });
  test('hostname regexp should allow basic names', () {
    var string = 'vm1';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(true));
  });

  test('hostname regexp should allow valid hostnames', () {
    var string = 'vm-1-01';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(true));
  });
  test('hostname regexp should allow domains', () {
    var string = 'demo.l-a.site';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(true));
  });

  test('hostname aliases regexp should allow valid hostnames', () {
    var string = 'vm-1-01   vm2 vm3';
    expect(LARegExp.aliasesRegexp.hasMatch(string), equals(true));
  });

  test('hostname aliases empty regexp should be valid', () {
    var string = '';
    expect(LARegExp.aliasesRegexp.hasMatch(string), equals(true));
  });

  test('ipv4', () {
    List<String> ipAddresses = ['127.0.0.1', '10.0.0.1', '1.1.1.1'];
    ipAddresses.forEach((ipv4) {
      expect(LARegExp.ipv4.hasMatch(ipv4), equals(true));
    });
  });

  test('ipv4 failed', () {
    List<String> ipAddresses = [
      'vm1',
      '260.0.0.1',
      '1.1.1.1.1',
      '111',
      '255.255.255.256',
      // Not empty (lets allow)
      //   '',
      // Neither ipv6
      '::1'
    ];
    ipAddresses.forEach((ipv4) {
      expect(LARegExp.ipv4.hasMatch(ipv4), equals(false));
    });
  });

  test('domain regexp should allow valid domains', () {
    List<String> domains = [
      'l-a.site',
      'example.org',
    ];
    domains.forEach((d) {
      expect(LARegExp.domainRegexp.hasMatch(d), equals(true));
    });
  });
}

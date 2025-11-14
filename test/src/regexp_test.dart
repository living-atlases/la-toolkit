import 'package:la_toolkit/utils/string_utils.dart';
import 'package:la_toolkit/utils/regexp.dart';
import 'package:test/test.dart';

void main() {
  test('project long name regexp should not allow non letters', () {
    const String string = '55l&&7%()';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(false));
  });
  test('project long name regexp should not allow non letters (cont)', () {
    const String string = 'a#/&%()';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(false));
  });

  test('project long name regexp should allow valid simple names', () {
    const String string = 'AEIOU';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow names with numbers', () {
    const String string = 'AEIOU 1';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow names with dot', () {
    const String string = 'AEIOU.1';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow valid tilde names', () {
    const String string = 'áéíóú';
    expect(LARegExp.projectNameRegexp.hasMatch(string), equals(true));
  });

  test('project long name regexp should allow valid unicode names', () {
    final List<String> correctNames = <String>[
      'αν ένας ανώνυμος',
      'Biodiversitäts-Atlas Österreich',
    ];
    for (final String name in correctNames) {
      expect(LARegExp.projectNameRegexp.hasMatch(name), equals(true));
    }
  });

  test('project shortname name regexp should allow valid unicode names', () {
    final List<String> correctNames = <String>[
      'αν ένας ανώνυμος',
      'GBIF.ES',
      'ALA',
      'Biodiversitäts-Atlas Österreich',
    ];
    for (final String name in correctNames) {
      expect(LARegExp.shortNameRegexp.hasMatch(name), equals(true));
    }
  });

  test('hostname regexp should not allow non letters', () {
    const String string = 'vm org';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(false));
  });
  test('multi hostname regexp should not allow non letters', () {
    final List<String> names = <String>['vm org', 'vm1, vm2', 'vm1,vm2'];
    for (final String name in names) {
      expect(LARegExp.multiHostnameRegexp.hasMatch(name), equals(true));
    }
  });
  test('hostname regexp should allow basic names', () {
    const String string = 'vm1';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(true));
  });

  test('hostname regexp should allow valid hostnames', () {
    const String string = 'vm-1-01';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(true));
  });
  test('hostname regexp should allow domains', () {
    const String string = 'demo.l-a.site';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(true));
  });

  test('hostname aliases regexp should allow valid hostnames', () {
    const String string = 'vm-1-01   vm2 vm3';
    expect(LARegExp.aliasesRegexp.hasMatch(string), equals(true));
  });

  test('hostname aliases empty regexp should be valid', () {
    const String string = '';
    expect(LARegExp.aliasesRegexp.hasMatch(string), equals(true));
  });

  test('ipv4', () {
    final List<String> ipAddresses = <String>['127.0.0.1', '10.0.0.1', '1.1.1.1'];
    for (final String ipv4 in ipAddresses) {
      expect(LARegExp.ipv4.hasMatch(ipv4), equals(true));
    }
  });

  test('ipv4 failed', () {
    final List<String> ipAddresses = <String>[
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
    for (final String ipv4 in ipAddresses) {
      expect(LARegExp.ipv4.hasMatch(ipv4), equals(false));
    }
  });

  test('private addresses', () {
    final List<String> ipAddresses = <String>[
      '127.0.0.1',
      '10.0.0.1',
      '172.16.20.1',
      'fd12:3456:789a:1::1',
      '192.168.0.1'
    ];
    for (final String privateIp in ipAddresses) {
      expect(LARegExp.privateIp.hasMatch(privateIp), equals(true));
    }
  });

  test('private addresses', () {
    final List<String> ipAddresses = <String>[
      '1.1.1.1',
      '192.1.1.1',
      'fe80::1ff:fe23:4567:890a',
    ];
    for (final String privateIp in ipAddresses) {
      expect(LARegExp.privateIp.hasMatch(privateIp), equals(false));
    }
  });

  test('ipv6', () {
    final List<String> ipAddresses = <String>[
      '::1',
      '2620:119:35::35',
      'fe80::1ff:fe23:4567:890a'
    ];
    for (final String ipv6 in ipAddresses) {
      expect(LARegExp.ipv6.hasMatch(ipv6), equals(true));
    }
  });
  test('ipv6 failed', () {
    final List<String> ipAddresses = <String>[
      'vm1',
      '260.0.0.1',
      '1.1.1.1.1',
      '111',
      '255.255.255.256',
    ];
    for (final String ipv6 in ipAddresses) {
      expect(LARegExp.ipv6.hasMatch(ipv6), equals(false));
    }
  });

  test('ip v4 or v6', () {
    final List<String> ipAddresses = <String>[
      '127.0.0.1',
      '10.0.0.1',
      '1.1.1.1',
      '::1',
      '2620:119:35::35',
      'fe80::1ff:fe23:4567:890a'
    ];
    for (final String ip in ipAddresses) {
      expect(LARegExp.ip.hasMatch(ip), equals(true));
    }
  });

  test('domain regexp should allow valid domains', () {
    final List<String> domains = <String>[
      'l-a.site',
      'example.org',
      'b.a.example.com',
      'c.b.a.example.com'
    ];
    for (final String d in domains) {
      expect(LARegExp.domainRegexp.hasMatch(d), equals(true));
    }
  });

  test('valid ssh pub keys', () {
    final List<String> pubKeys = <String>[
      '''ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSUGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3Pbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XAt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/EnmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbxNrRFi9wrf+M7Q== schacon@mylaptop.local''',
      '''
ssh-rsa 
AAAAB3NzaC1yc2EAAAABIwAAAgEAwrr66r8n6B8Y0zMF3dOpXEapIQD9DiYQ6D6/zwor9o
39jSkHNiMMER/GETBbzP83LOcekm02aRjo55ArO7gPPVvCXbrirJu9pkm4AC4BBre5xSLS
7soyzwbigFruM8G63jSXqpHqJ/ooi168sKMC2b0Ncsi+JlTfNYlDXJVLKEeZgZOInQyMmt
isaDTUQWTIv1snAizf4iIYENuAkGYGNCL77u5Y5VOu5eQipvFajTnps9QvUx/zdSFYn9e2
sulWM3Bxc/S4IJ67JWHVRpfJxGi3hinRBH8WQdXuUwdJJTiJHKPyYrrM7Q6Xq4TOMFtcRu
LDC6u3BXM1L0gBvHPNOnD5l2Lp5EjUkQ9CBf2j4A4gfH+iWQZyk08esAG/iwArAVxkl368
+dkbMWOXL8BN4x5zYgdzoeypQZZ2RKH780MCTSo4WQ19DP8pw+9q3bSFC9H3xYAxrKAJNW
jeTUJOTrTe+mWXXU770gYyQTxa2ycnYrlZucn1S3vsvn6eq7NZZ8NRbyv1n15Ocg+nHK4f
uKOrwPhU3NbKQwtjb0Wsxx1gAmQqIOLTpAdsrAauPxC7TPYA5qQVCphvimKuhQM/1gMV22
5JrnjspVlthCzuFYUjXOKC3wxz6FFEtwnXu3uC5bVVkmkNadJmD21gD23yk4BraGXVYpRM
IB+X+OTUUI8= dhopson@VMUbuntu-DSH'''
    ];
    for (final String key in pubKeys) {
      expect(
          LARegExp.sshPubKey.hasMatch(key.replaceAll('\n', '')), equals(true));
    }
  });

  test('url regexp should allow valid urls', () {
    final List<String> urls = <String>[
      'http://example.com',
      'https://example.com/favico.ico',
    ];
    final List<String> wrongUrls = <String>[
      'http//example.com',
      'http:/example.com/favico.ico',
      'example.com',
      ''
    ];
    for (final String url in urls) {
      expect(LARegExp.url.hasMatch(url), equals(true));
    }
    for (final String url in wrongUrls) {
      expect(LARegExp.url.hasMatch(url), equals(false));
    }
  });

  test('Valid email addresses', () {
    final List<String> validEmails = <String>[
      'example@example.com',
      'john.doe@domain.co.uk',
      'inf@l-a.site',
      'jane_doe@example.io',
      'test.email+123@example.ca',
    ];

    for (final String email in validEmails) {
      expect(LARegExp.email.hasMatch(email), true,
          reason: 'Expected $email to be a valid email address');
    }
  });

  test('Invalid email addresses', () {
    final List<String> invalidEmails = <String>[
      'example@example',
      'john.doe@domain',
      'inf@l-a',
      '@example.com',
      'example@.com',
      'example@.com.',
      'example@.',
    ];

    for (final String email in invalidEmails) {
      expect(LARegExp.email.hasMatch(email), false,
          reason: 'Expected $email to be an invalid email address');
    }
  });

  test('test valid and invalid port numbers', () {
    final List<String> valid = <String>[
      '1',
      '22',
      '8080',
      '60000',
    ];
    final List<String> invalid = <String>[
      '70000',
      'abc',
    ];
    for (final String current in valid) {
      expect(LARegExp.portNumber.hasMatch(current), equals(true));
    }
    for (final String current in invalid) {
      expect(LARegExp.portNumber.hasMatch(current), equals(false));
    }
  });

  test('test subdomains', () {
    final List<String> subdomains = <String>[
      'aa',
      'a-b',
      'a_b',
      'a.b',
    ];
    for (final String sub in subdomains) {
      expect(LARegExp.subdomain.hasMatch(sub), equals(true));
    }
  });

  test('test invalid subdomains', () {
    final List<String> subdomains = <String>[
      'a*b',
      'a b',
      'a\b',
    ];
    for (final String sub in subdomains) {
      // print("Testing $sub");
      expect(
        LARegExp.subdomain.hasMatch(sub),
        equals(false),
      );
    }
  });

  test('test not empty fields', () {
    final List<String> emptyVars = <String>[
      '',
      ' ',
      '   ',
    ];
    for (final String sub in emptyVars) {
      expect(
        LARegExp.something.hasMatch(sub),
        equals(false),
      );
    }
  });

  test('test correct slash removal', () {
    expect(StringUtils.removeLastSlash('http://example.com/'),
        equals('http://example.com'));
  });

  test('test drs', () {
    final List<String> validValues = <String>[
      'dr1',
      'dr234',
      'dr2 dr3',
      'dr3 dr4 dr5 dr6',
      'dr3 dr4 dr5 dr6 ',
      'dr1    '
    ];
    final List<String> inValidValues = <String>['dr', '123', 'dr234 dr', 'dr2 dra3'];
    for (final String value in validValues) {
      expect(LARegExp.drs.hasMatch(value), equals(true),
          reason: '$value should match');
    }
    for (final String value in inValidValues) {
      expect(LARegExp.drs.hasMatch(value), equals(false),
          reason: '$value should not match');
    }
  });
}

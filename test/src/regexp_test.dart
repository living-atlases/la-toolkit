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
    List<String> correctNames = [
      'αν ένας ανώνυμος',
      'Biodiversitäts-Atlas Österreich',
    ];
    for (String name in correctNames) {
      expect(LARegExp.projectNameRegexp.hasMatch(name), equals(true));
    }
  });

  test('project shortname name regexp should allow valid unicode names', () {
    List<String> correctNames = [
      'αν ένας ανώνυμος',
      'GBIF.ES',
      'ALA',
      'Biodiversitäts-Atlas Österreich',
    ];
    for (String name in correctNames) {
      expect(LARegExp.shortNameRegexp.hasMatch(name), equals(true));
    }
  });

  test('hostname regexp should not allow non letters', () {
    var string = 'vm org';
    expect(LARegExp.hostnameRegexp.hasMatch(string), equals(false));
  });
  test('multi hostname regexp should not allow non letters', () {
    List<String> names = ['vm org', 'vm1, vm2', 'vm1,vm2'];
    for (String name in names) {
      expect(LARegExp.multiHostnameRegexp.hasMatch(name), equals(true));
    }
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
    for (String ipv4 in ipAddresses) {
      expect(LARegExp.ipv4.hasMatch(ipv4), equals(true));
    }
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
    for (String ipv4 in ipAddresses) {
      expect(LARegExp.ipv4.hasMatch(ipv4), equals(false));
    }
  });

  test('private addresses', () {
    List<String> ipAddresses = [
      '127.0.0.1',
      '10.0.0.1',
      '172.16.20.1',
      'fd12:3456:789a:1::1',
      '192.168.0.1'
    ];
    for (String privateIp in ipAddresses) {
      expect(LARegExp.privateIp.hasMatch(privateIp), equals(true));
    }
  });

  test('private addresses', () {
    List<String> ipAddresses = [
      '1.1.1.1',
      '192.1.1.1',
      'fe80::1ff:fe23:4567:890a',
    ];
    for (String privateIp in ipAddresses) {
      expect(LARegExp.privateIp.hasMatch(privateIp), equals(false));
    }
  });

  test('ipv6', () {
    List<String> ipAddresses = [
      '::1',
      '2620:119:35::35',
      'fe80::1ff:fe23:4567:890a'
    ];
    for (String ipv6 in ipAddresses) {
      expect(LARegExp.ipv6.hasMatch(ipv6), equals(true));
    }
  });
  test('ipv6 failed', () {
    List<String> ipAddresses = [
      'vm1',
      '260.0.0.1',
      '1.1.1.1.1',
      '111',
      '255.255.255.256',
    ];
    for (String ipv6 in ipAddresses) {
      expect(LARegExp.ipv6.hasMatch(ipv6), equals(false));
    }
  });

  test('ip v4 or v6', () {
    List<String> ipAddresses = [
      '127.0.0.1',
      '10.0.0.1',
      '1.1.1.1',
      '::1',
      '2620:119:35::35',
      'fe80::1ff:fe23:4567:890a'
    ];
    for (String ip in ipAddresses) {
      expect(LARegExp.ip.hasMatch(ip), equals(true));
    }
  });

  test('domain regexp should allow valid domains', () {
    List<String> domains = [
      'l-a.site',
      'example.org',
    ];
    for (String d in domains) {
      expect(LARegExp.domainRegexp.hasMatch(d), equals(true));
    }
  });

  test('valid ssh pub keys', () {
    List<String> pubKeys = [
      '''ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAklOUpkDHrfHY17SbrmTIpNLTGK9Tjom/BWDSUGPl+nafzlHDTYW7hdI4yZ5ew18JH4JW9jbhUFrviQzM7xlELEVf4h9lFX5QVkbPppSwg0cda3Pbv7kOdJ/MTyBlWXFCR+HAo3FXRitBqxiX1nKhXpHAZsMciLq8V6RjsNAQwdsdMFvSlVK/7XAt3FaoJoAsncM1Q9x5+3V0Ww68/eIFmb1zuUFljQJKprrX88XypNDvjYNby6vw/Pb0rwert/EnmZ+AW4OZPnTPI89ZPmVMLuayrD2cE86Z/il8b+gw3r3+1nKatmIkjn2so1d01QraTlMqVSsbxNrRFi9wrf+M7Q== schacon@mylaptop.local''',
      '''ssh-rsa 
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
    for (String key in pubKeys) {
      expect(
          LARegExp.sshPubKey.hasMatch(key.replaceAll('\n', '')), equals(true));
    }
  });

  test('url regexp should allow valid urls', () {
    List<String> urls = [
      'http://example.com',
      'https://example.com/favico.ico',
    ];
    List<String> wrongUrls = [
      'http//example.com',
      'http:/example.com/favico.ico',
      'example.com',
      ''
    ];
    for (String url in urls) {
      expect(LARegExp.url.hasMatch(url), equals(true));
    }
    for (String url in wrongUrls) {
      expect(LARegExp.url.hasMatch(url), equals(false));
    }
  });

  test('email regexp should allow valid emails', () {
    List<String> emails = [
      'bob@example.com',
      'alice@example.org',
    ];
    List<String> wrongEmails = [
      'example.com',
      '',
    ];
    for (String email in emails) {
      expect(LARegExp.email.hasMatch(email), equals(true));
    }
    for (String email in wrongEmails) {
      expect(LARegExp.email.hasMatch(email), equals(false));
    }
  });

  test('test valid and invalid port numbers', () {
    List<String> valid = [
      '1',
      '22',
      '8080',
      '60000',
    ];
    List<String> invalid = [
      '70000',
      'abc',
    ];
    for (String current in valid) {
      expect(LARegExp.portNumber.hasMatch(current), equals(true));
    }
    for (String current in invalid) {
      expect(LARegExp.portNumber.hasMatch(current), equals(false));
    }
  });

  test('test subdomains', () {
    List<String> subdomains = [
      'aa',
      'a-b',
      'a_b',
      'a.b',
    ];
    for (String sub in subdomains) {
      expect(LARegExp.subdomain.hasMatch(sub), equals(true));
    }
  });

  test('test invalid subdomains', () {
    List<String> subdomains = [
      'a*b',
      'a b',
      'a\b',
    ];
    for (String sub in subdomains) {
      // print("Testing $sub");
      expect(
        LARegExp.subdomain.hasMatch(sub),
        equals(false),
      );
    }
  });
}

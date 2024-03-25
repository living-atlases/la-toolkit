import 'package:dbcrypt/dbcrypt.dart';
import 'package:test/test.dart';

void main() {
  test('Check password hash', () {
    const String plainPassword = 'easyeasy';
    final String hashedPassword =
        DBCrypt().hashpw(plainPassword, DBCrypt().gensaltWithRounds(10));
    // print(hashedPassword);
    expect(DBCrypt().checkpw(plainPassword, hashedPassword), equals(true));
    // $2a bcrypt version also works
    expect(
        DBCrypt().checkpw(
            plainPassword, hashedPassword.replaceFirst(r'$2b', r'$2a')),
        equals(true));
  });
}

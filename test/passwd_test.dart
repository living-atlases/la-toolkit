import 'package:dbcrypt/dbcrypt.dart';
import 'package:test/test.dart';

void main() {
  test('Check password hash', () {
    var plainPassword = "easyeasy";
    var hashedPassword = new DBCrypt()
        .hashpw(plainPassword, new DBCrypt().gensaltWithRounds(10));
    print(hashedPassword);
    expect(DBCrypt().checkpw(plainPassword, hashedPassword), equals(true));
    // $2a bcrypt version also works
    expect(
        DBCrypt().checkpw(
            plainPassword, hashedPassword.replaceFirst("\$2b", "\$2a")),
        equals(true));
  });
}

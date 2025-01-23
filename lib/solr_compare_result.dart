import 'package:intl/intl.dart' as intl;

class SolrCompareResult {
  SolrCompareResult(this.key, this.a) : b = 0;

  SolrCompareResult.empty(this.key)
      : a = 0,
        b = 0;
  static bool csvFormat = false;

  final String key;
  int a;
  int b;

  int get d => b - a;

  @override
  String toString() => csvFormat
      ? '$key;${_f(a)};${_f(b)};${d > 0 ? '+' : ''}${_f(d)}'
      : '|$key|${_f(a)}|${_f(b)}|${d > 0 ? '+' : ''}${_f(d)}|';

  SolrCompareResult setA(int a) {
    this.a = a;
    return this;
  }

  SolrCompareResult setB(int b) {
    this.b = b;
    return this;
  }

  String _f(int n) => intl.NumberFormat.decimalPattern('en').format(n);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SolrCompareResult &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode ^ a.hashCode ^ b.hashCode;
}

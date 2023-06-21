String formatCurrency(double value) {
  String sign = '';
  int intVal = value.ceil();
  if (intVal < 0) {
    sign = '-';
    intVal = -intVal;
  }

  List<int> result = [];
  final chars = intVal.toString().codeUnits;
  for (int i = chars.length - 1; i >= 0; --i) {
    int p = chars.length - (i + 1);
    if (p > 0 && [3, 5, 0].contains(p % 7)) {
      result.add(','.codeUnitAt(0));
    }
    result.add(chars[i]);
  }

  final formatted = String.fromCharCodes(result.reversed);
  return sign + formatted + '/='; // '৳';
}

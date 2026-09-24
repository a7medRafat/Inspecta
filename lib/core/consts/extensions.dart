extension DoubleExtension on double {
  String signFixed(int fixed) {
    if (this == 0) return toStringAsFixed(fixed);
    return this > 0 ? '+${toStringAsFixed(fixed)}' : toStringAsFixed(fixed);
  }

  String get signingFixed {
    if (this == 0) return '$this';
    return this > 0 ? '+$this' : '$this';
  }

  String get toTwoDecimal {
    return toStringAsFixed(2);
  }

  double get toTwoDecimalNum {
    return double.parse(toStringAsFixed(2));
  }
}

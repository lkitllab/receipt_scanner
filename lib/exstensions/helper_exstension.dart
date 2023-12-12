import 'dart:convert';

extension Rounded on double {
  String roundedString() {
    return round().toDouble() == this ? round().toString() : toStringAsFixed(3);
  }
}

extension ConvertSymbols on String {
  String convertSymbolsForDevice() {
    return const Utf8Decoder().convert(codeUnits);
  }
}

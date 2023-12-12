import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:receipt_scanner/models/receipt_model.dart';

class Mocks {
  Future<List<Receipt>> receipts() async {
    final data = await rootBundle.loadString("assets/data.json");
    final Map<String, dynamic> json = jsonDecode(data);
    final receipts = (json['documents'] as List<dynamic>).map((e) {
      return Receipt.fromJson(e);
    }).toList();
    return receipts;
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'dart:convert';

import './lineitem_model.dart';
import './vendor_model.dart';

export './lineitem_model.dart';
export './vendor_model.dart';
import './tax_model.dart';

enum ReceiptParameter {
  id,
  category,
  date,
  imageUrl,
  thumbnailUrl,
  lineItems,
  ocrText,
  paymentType,
  tags,
  total,
  currencyCode,
  vendor,
}

extension ReceiptPath on ReceiptParameter {
  String get path {
    switch (this) {
      case ReceiptParameter.id:
        return 'id';
      case ReceiptParameter.category:
        return 'category';
      case ReceiptParameter.date:
        return 'date';
      case ReceiptParameter.imageUrl:
        return 'img_url';
      case ReceiptParameter.thumbnailUrl:
        return 'img_thumbnail_url';
      case ReceiptParameter.lineItems:
        return 'line_items';
      case ReceiptParameter.ocrText:
        return 'ocr_text';
      case ReceiptParameter.paymentType:
        return 'type';
      case ReceiptParameter.tags:
        return 'tags';
      case ReceiptParameter.total:
        return 'total';
      case ReceiptParameter.currencyCode:
        return 'currency_code';
      case ReceiptParameter.vendor:
        return 'vendor';
      default:
        return '';
    }
  }
}

@immutable
class Receipt {
  final String id; // id
  final String category; // category
  final DateTime date; // date
  final String imageUrl; // img_url
  final String thumbnailUrl;
  final List<LineItem> lineItems; // line_items
  final String ocrText; // ocr_text
  final String paymentType; // payment/type
  final List<String> tags; // tags
  final double total; // total
  final String currencyCode;
  final List<Tax> taxes;
  final Vendor vendor;

  const Receipt({
    required this.id,
    required this.category,
    required this.date,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.lineItems,
    required this.ocrText,
    required this.paymentType,
    required this.tags,
    required this.total,
    required this.currencyCode,
    required this.taxes,
    required this.vendor,
  }); // vendor

  factory Receipt.fromJson(Map<String, dynamic> json) {
    final id = json[ReceiptParameter.id.path].toString();
    final category = json[ReceiptParameter.category.path].toString();
    final date = DateTime.parse(json[ReceiptParameter.date.path].toString());
    final imageUrl = json[ReceiptParameter.imageUrl.path].toString();
    final thumbnailUrl = json[ReceiptParameter.thumbnailUrl.path].toString();
    final ocrText = const Utf8Decoder()
        .convert(json[ReceiptParameter.ocrText.path].toString().codeUnits);
    final payment = json['payment'];
    final paymentType = payment[ReceiptParameter.paymentType.path].toString();
    final tags = (json[ReceiptParameter.tags.path] as List)
        .map((e) => e.toString())
        .toList();
    final total = double.parse(json[ReceiptParameter.total.path].toString());
    final currencyCode = json[ReceiptParameter.currencyCode.path].toString();
    final taxes = (json['tax_lines'] as List).map((e) => Tax.fromJson(e)).toList();
    final lineitems = (json[ReceiptParameter.lineItems.path] as List)
        .map((json) => LineItem.fromJson(json))
        .toList();
    final vendor = Vendor.fromJson(
        json[ReceiptParameter.vendor.path] as Map<String, dynamic>);
    return Receipt(
      id: id,
      category: category,
      date: date,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      lineItems: lineitems,
      ocrText: ocrText,
      paymentType: paymentType,
      tags: tags,
      total: total,
      currencyCode: currencyCode,
      taxes: taxes,
      vendor: vendor,
    );
  }

  Receipt copyWith({
    String? id,
    String? category,
    DateTime? date,
    String? imageUrl,
    String? thumbnailUrl,
    List<LineItem>? lineItems,
    String? ocrText,
    String? paymentType,
    List<String>? tags,
    double? total,
    String? currencyCode,
    List<Tax>? taxes,
    Vendor? vendor,
  }) {
    return Receipt(
      id: id ?? this.id,
      category: category ?? this.category,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      lineItems: lineItems ?? this.lineItems,
      ocrText: ocrText ?? this.ocrText,
      paymentType: paymentType ?? this.paymentType,
      tags: tags ?? this.tags,
      total: total ?? this.total,
      currencyCode: currencyCode ?? this.currencyCode,
      taxes: taxes ?? this.taxes,
      vendor: vendor ?? this.vendor,
    );
  }
}

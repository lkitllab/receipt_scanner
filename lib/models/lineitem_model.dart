// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'package:flutter/material.dart';

enum LineItemParameter {
  id,
  description,
  order,
  quantity,
  tags,
  text,
  price,
  total,
  type,
}

extension LineItemPath on LineItemParameter {
  String get path {
    switch (this) {
      case LineItemParameter.id:
        return 'id';
      case LineItemParameter.description:
        return 'description';
      case LineItemParameter.order:
        return 'order';
      case LineItemParameter.quantity:
        return 'quantity';
      case LineItemParameter.tags:
        return 'tags';
      case LineItemParameter.text:
        return 'text';
      case LineItemParameter.price:
        return 'price';
      case LineItemParameter.total:
        return 'total';
      case LineItemParameter.type:
        return 'type';
      default:
        return '';
    }
  }
}

@immutable
class LineItem {
  final String id;
  final String description;
  final int order;
  final double quantity;
  final List<String> tags;
  final String text;
  final double price;
  final double total;
  final String type;

  const LineItem({
    required this.id,
    required this.description,
    required this.order,
    required this.quantity,
    required this.tags,
    required this.text,
    required this.price,
    required this.total,
    required this.type,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    final id = json[LineItemParameter.id.path].toString();
    final description = const Utf8Decoder()
        .convert(json[LineItemParameter.description.path].toString().codeUnits);
    final order =
        int.tryParse(json[LineItemParameter.order.path].toString()) ?? 0;
    final quantity =
        double.tryParse(json[LineItemParameter.quantity.path].toString()) ?? 1;
    final tags = (json[LineItemParameter.tags.path] as List)
        .map((e) => e.toString())
        .toList();
    final text = json[LineItemParameter.text.path].toString();
    final price =
        double.tryParse(json[LineItemParameter.price.path].toString()) ?? 0;
    final total =
        double.tryParse(json[LineItemParameter.total.path].toString()) ?? 0;
    final type = json[LineItemParameter.type.path].toString();
    return LineItem(
      id: id,
      description: description,
      order: order,
      quantity: quantity,
      tags: tags,
      text: text,
      price: price,
      total: total,
      type: type,
    );
  }

  LineItem copyWith({
    String? id,
    String? description,
    int? order,
    double? quantity,
    List<String>? tags,
    String? text,
    double? price,
    double? total,
    String? type,
  }) {
    return LineItem(
      id: id ?? this.id,
      description: description ?? this.description,
      order: order ?? this.order,
      quantity: quantity ?? this.quantity,
      tags: tags ?? this.tags,
      text: text ?? this.text,
      total: total ?? this.total,
      price: price ?? this.price,
      type: type ?? this.type,
    );
  }
}

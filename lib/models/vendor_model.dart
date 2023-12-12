import 'package:flutter/material.dart';
import '../exstensions/helper_exstension.dart';

enum VendorParameter {
  name,
  address,
  logo,
  categories,
  types,
}

extension VendorPath on VendorParameter {
  String get path {
    switch (this) {
      case VendorParameter.name:
        return 'name';
      case VendorParameter.address:
        return 'address';
      case VendorParameter.logo:
        return 'logo';
      case VendorParameter.categories:
        return 'category';
      case VendorParameter.types:
        return 'type';
      default:
        return '';
    }
  }
}

@immutable
class Vendor {
  // vendor
  final String name; // name
  final String address; // address
  final String logo; // logo
  final List<String> categories; // category
  final List<String> types; // type

  const Vendor({
    required this.name,
    required this.address,
    required this.logo,
    required this.categories,
    required this.types,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    final name = json[VendorParameter.name.path].toString().convertSymbolsForDevice();
    final address = json[VendorParameter.address.path].toString().convertSymbolsForDevice();
    final logo = json[VendorParameter.logo.path].toString();
    final categories = json[VendorParameter.categories.path].toString().split(', ');
    final types = json[VendorParameter.types.path].toString().split(', ');
    return Vendor(
      name: name,
      address: address,
      logo: logo,
      categories: categories,
      types: types,
    );
  }

  Vendor copyWith({
    String? name,
    String? address,
    String? logo,
    List<String>? categories,
    List<String>? types,
  }) {
    return Vendor(
      name: name ?? this.name,
      address: address ?? this.address,
      logo: logo ?? this.logo,
      categories: categories ?? this.categories,
      types: types ?? this.types,
    );
  }
}

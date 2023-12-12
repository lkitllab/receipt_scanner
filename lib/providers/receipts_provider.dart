import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:math';

export '../models/receipt_model.dart';
export '../models/tag_model.dart';

import 'package:veryfi_dart/veryfi_dart.dart';
// ignore: implementation_imports
import 'package:veryfi_dart/src/network/network_request_manager.dart';
// ignore: implementation_imports
import 'package:veryfi_dart/src/exception/veryfi_exception.dart';

import '../models/receipt_model.dart';
import '../models/tag_model.dart';

const clientId = '';
const clientSecret =
    '';
const userName = '';
const apiKey = '';

class ReceiptsNotifier extends StateNotifier<List<Receipt>> {
  final _client = VeryfiDart(
    clientId,
    clientSecret,
    userName,
    apiKey,
  );

  ReceiptsNotifier() : super([]);
  Future<void> processDocuments(List<String> paths,
      [Function()? success]) async {
    final futures = paths.map((path) => processDocument(path, success));
    try {
      final newReceipts = await Future.wait(futures);
      state = [...newReceipts, ...state];
    } on VeryfiException catch (error) {
      throw Exception(error.response);
    }
  }

  Future<Receipt> processDocument(String path, [Function()? success]) async {
    File file = File(path);
    Uint8List imageData = file.readAsBytesSync();
    String fileData = base64Encode(imageData);
    final json = await _client.processDocument(
      basename(file.path),
      fileData,
      params: {'external_id': '111111'},
    );
    final receipt = Receipt.fromJson(json);
    if (success != null) success();
    return receipt;
  }

  Future<void> getDocuments() async {
    // final json = await _client.getDocuments();
    final json = await _client.getUserDocuments('111111');
    final receipts = (json['documents'] as List<dynamic>).map((e) {
      return Receipt.fromJson(e);
    }).toList();
    receipts.sort((a, b) => b.date.compareTo(a.date));
    state = receipts;
  }

  Future<Receipt> getDocument(String documentId) async {
    final json = await _client.getDocumentById(documentId);
    final receipt = Receipt.fromJson(json);
    return receipt;
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final result = await _client.deleteDocument(documentId);
      final status = result['status'];
      if (status == 'ok') {
        state.removeWhere((element) => element.id == documentId);
      } else {
        throw Exception(result['message']);
      }
    } on VeryfiException catch (error) {
      throw Exception(error.response);
    }
  }

  Future<void> updateLineItem(
    String receiptId,
    String lineItemId,
    Map<String, String> params,
  ) async {
    final json = await _client.uupdateLineItem(receiptId, lineItemId, params);
    final lineItem = LineItem.fromJson(json);
    final receiptIndex = state.indexWhere((element) => element.id == receiptId);
    final itemIndex = state[receiptIndex]
        .lineItems
        .indexWhere((element) => element.id == lineItemId);
    state[receiptIndex].lineItems[itemIndex] = lineItem;
  }

  Future<void> updateAllDocuments(List<String> receipts) async {
    final futures = receipts.map((e) => updateDocument(e));
    try {
      await Future.wait(futures);
    } on VeryfiException catch (error) {
      throw Exception(error.response);
    }
  }

  Future<void> updateDocument(String documentId,
      {Map<String, dynamic>? params, void Function()? completion}) async {
    final body = params ?? {};
    final json = await _client.updateDocument(documentId, body);
    if (completion != null) completion();
    final index = state.indexWhere((element) => element.id == documentId);
    final receipt = Receipt.fromJson(json);
    state[index] = receipt;
    state = [...state];
  }

  Future<List<Tag>> getTags(String documentId) async {
    try {
      final json = await _client.getTags(documentId);
      final tags = (json['tags'] as List).map((e) => Tag.fromJson(e)).toList();
      return tags;
    } on VeryfiException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<Tag> addTag(String documentId, String name) async {
    try {
      final json = await _client.addTag(documentId, name);
      final tag = Tag.fromJson(json);
      return tag;
    } on VeryfiException catch (e) {
      throw Exception(e.response);
    }
  }

  Future<void> deleteTag(String documentId, String tagId) async {
    try {
      await _client.deleteTag(documentId, tagId);
    } on VeryfiException catch (e) {
      throw Exception(e.response);
    }
  }
}

extension on VeryfiDart {
  Future<Map<String, dynamic>> getUserDocuments(String userId) async {
    final Map<String, dynamic> body = {
      'q': userId,
    };
    final json = await request(HTTPMethod.get, 'documents', queryItems: body);
    return json;
  }

  Future<Map<String, dynamic>> uupdateLineItem(
      String documentId, String lineItemId, Map<String, dynamic> params) {
    return request(
      HTTPMethod.put,
      'documents/$documentId/line-items/$lineItemId',
      body: params,
    );
  }

  Future<Map<String, dynamic>> getTags(String documentId) async {
    return request(
      HTTPMethod.get,
      'documents/$documentId/tags',
    );
  }

  Future<Map<String, dynamic>> addTag(String documentId, String tag) async {
    final body = {'name': tag};
    return request(
      HTTPMethod.put,
      'documents/$documentId/tags',
      body: body,
    );
  }

  Future<Map<String, dynamic>> deleteTag(
      String documentId, String tagId) async {
    return request(
      HTTPMethod.delete,
      'documents/$documentId/tags/$tagId',
    );
  }
}

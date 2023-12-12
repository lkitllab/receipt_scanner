import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../router.dart';
import '../exstensions/helper_exstension.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:receipt_scanner/colors.dart';
import '../exstensions/alert_extension.dart';
import './progress_screen.dart';

class ReceiptDetailsScreen extends ConsumerStatefulWidget {
  const ReceiptDetailsScreen(this.receiptId, {super.key});

  final String receiptId;

  @override
  ConsumerState<ReceiptDetailsScreen> createState() =>
      _ReceiptDetailsScreemState();
}

class _ReceiptDetailsScreemState extends ConsumerState<ReceiptDetailsScreen> {
  final Map<String, dynamic> _params = {};
  bool _isLoading = false;
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  void _loadTags() {
    ref
        .read(receiptProvider.notifier)
        .getTags(widget.receiptId)
        .then((value) => setState(() {
              _tags = value;
            }))
        .catchError((error) => print(error.toString()));
  }

  void _showDatePicker(Receipt receipt) async {
    final dateString = _params[ReceiptParameter.date.path];
    final date = dateString == null ? receipt.date : DateTime.parse(dateString);
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: date, //get today's date
        firstDate: DateTime(2000),
        lastDate: DateTime.now());
    if (pickedDate != null) {
      setState(() {
        _params[ReceiptParameter.date.path] =
            DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _saveChanges(String documentId) async {
    FocusScope.of(context).requestFocus(FocusNode());
    final receipts = ref.read(receiptProvider.notifier);
    try {
      _toggleLoading(true);
      await receipts.updateDocument(documentId, params: _params);
      _toggleLoading(false);
      showAlert(title: 'Success!', message: 'Your changes are saved');
    } catch (error) {
      _toggleLoading(false);
      setState(() {});
      showAlert(title: 'Error!', message: error.toString());
    }
  }

  void _toggleLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _validate(String oldValue, String newValue,
      {required String key, String? parentKey}) {
    if (oldValue != newValue && newValue.isNotEmpty) {
      if (parentKey == null) {
        _params[key] = newValue;
      } else if (_params[parentKey] == null) {
        _params[parentKey] = {key: newValue};
      } else {
        _params[parentKey][key] = newValue;
      }
    } else if (oldValue == newValue) {
      if (parentKey == null) {
        _params.remove(key);
      } else {
        _params.remove(parentKey);
      }
    }
  }

  void _removeTag(Tag tag) async {
    showOkCancelAlert(
      title: '',
      message: 'Do you want to delete $tag?',
      okComletion: () async {
        await ref.read(receiptProvider.notifier).deleteTag(widget.receiptId, tag.id);
      },
    );
  }

  void _addTag() async {
    await showTextInputDialog('Tag name', (name) async {
      _toggleLoading(true);
      try {
        final tag = await ref
            .read(receiptProvider.notifier)
            .addTag(widget.receiptId, name);
        setState(() {
          _tags.add(tag);
        });
      } on Exception catch (e) {
        showAlert(title: 'Error', message: e.toString());
      }
      _toggleLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final receipt = ref
        .watch(receiptProvider)
        .firstWhere((element) => element.id == widget.receiptId);
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.accentColor,
          title: const Text('Receipt details'),
          centerTitle: true,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.accentColor),
              onPressed: () => _isLoading || _params.isEmpty
                  ? null
                  : _saveChanges(receipt.id),
              child: const Icon(
                Icons.done,
                size: 28,
              ),
            ),
          ],
        ),
        body: Stack(children: [
          Container(
            color: AppColors.backgroundColor,
          ),
          SafeArea(
            bottom: true,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _vendor(receipt),
                    _separator(),
                    _lineItems(receipt),
                    _separator(),
                    _info(receipt),
                    _separator(),
                    _tagsView(),
                    _separator(),
                    _ocrText(receipt.ocrText),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const ProgressScreen(null),
        ]),
      ),
    );
  }

  Widget _tagsView() {
    return Column(
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Tags(
                alignment: WrapAlignment.start,
                runAlignment: WrapAlignment.start,
                itemCount: _tags.length + 1,
                itemBuilder: (index) {
                  return index == _tags.length
                      ? ItemTags(
                          index: index,
                          title: '',
                          icon: ItemTagsIcon(icon: Icons.add),
                          color: AppColors.accentColor,
                          onPressed: (i) => _addTag(),
                        )
                      : ItemTags(
                          index: index,
                          title: _tags[index].name,
                          color: AppColors.textColor,
                          removeButton: ItemTagsRemoveButton(
                            icon: Icons.delete,
                            onRemoved: () => true,
                          ),
                        );
                }),
          ],
        ),
      ],
    );
  }

  Widget _ocrText(String text) {
    return Column(
      children: [
        const Text(
          'OCR Text:',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 12),
        SelectableText(
          text,
          maxLines: null,
        ),
      ],
    );
  }

  Widget _thumbnailImage(String imageUrl) {
    Widget image;
    try {
      image = Image.network(
        imageUrl,
        width: 200,
      );
    } catch (_) {
      image = const Icon(
        Icons.image_not_supported,
        size: 60,
      );
    }
    return image;
  }

  Widget _vendor(Receipt receipt) {
    return Column(
      children: [
        _thumbnailImage(receipt.thumbnailUrl),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            Image.network(
              receipt.vendor.logo,
              width: 70,
              height: 70,
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    key: Key(receipt.vendor.name),
                    initialValue: receipt.vendor.name,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    onChanged: (value) => _validate(
                      receipt.vendor.name,
                      value,
                      key: VendorParameter.name.name,
                      parentKey: ReceiptParameter.vendor.path,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  GestureDetector(
                    child: Row(
                      children: [
                        const Icon(Icons.date_range),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(_params[ReceiptParameter.date.path] ??
                            DateFormat('yyyy-MM-dd').format(receipt.date)),
                      ],
                    ),
                    onTap: () => _showDatePicker(receipt),
                  ),
                ],
              ),
            ),
          ],
        ),
        TextFormField(
          key: Key(receipt.vendor.address),
          initialValue: receipt.vendor.address,
          decoration: const InputDecoration(
            labelText: 'Address',
            border: InputBorder.none,
          ),
          maxLines: null,
          onChanged: (value) => _validate(
            receipt.vendor.address,
            value,
            key: VendorParameter.address.path,
            parentKey: ReceiptParameter.vendor.path,
          ),
        ),
      ],
    );
  }

  Widget _separator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Colors.black,
      ),
    );
  }

  Widget _info(Receipt receipt) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          for (final tax in receipt.taxes)
            Row(
              children: [
                Text('Tax (${tax.rate}%)'),
                const Spacer(),
                SizedBox(
                  width: 50,
                  child: Text(
                    tax.total.toStringAsFixed(2),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          Row(
            children: [
              Text(
                'Total ${receipt.currencyCode}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Flexible(
                child: TextFormField(
                  initialValue: receipt.total.toStringAsFixed(2),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onFieldSubmitted: null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lineItems(Receipt receipt) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Description',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'Qnt.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'Price.',
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'Total',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        for (final (index, item) in receipt.lineItems.indexed)
          Container(
            color: index % 2 == 0
                ? AppColors.textColor
                : AppColors.backgroundColor,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: Text(
                item.description,
                style: TextStyle(
                  color: index % 2 == 0 ? Colors.white : Colors.black,
                ),
              ),
              trailing: SizedBox(
                width: 150,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 50,
                      child: Text(
                        item.quantity.roundedString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: index % 2 == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        item.price == 0 ? '0' : item.price.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: index % 2 == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text(
                        item.total.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: index % 2 == 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                context.goNamed(
                  AppRoute.lineitemDetails.path(),
                  pathParameters: {
                    'rid': widget.receiptId,
                    'lid': item.id,
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

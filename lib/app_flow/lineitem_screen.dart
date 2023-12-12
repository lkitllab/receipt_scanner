import 'package:flutter/material.dart';
import 'package:receipt_scanner/exstensions/helper_exstension.dart';
import '../providers/providers.dart';
import '../exstensions/alert_extension.dart';
import './progress_screen.dart';

class LineItemScreen extends ConsumerStatefulWidget {
  const LineItemScreen(
      {required this.receiptId, required this.lineItemId, super.key});

  final String receiptId;
  final String lineItemId;

  @override
  ConsumerState<LineItemScreen> createState() => _LineItemScreenState();
}

class _LineItemScreenState extends ConsumerState<LineItemScreen> {

  final Map<String, String> _parameters = {};
  var _isLoading = false;

  void _validate(String oldValue, String newValue, String key) {
    if (oldValue != newValue && newValue.isNotEmpty) {
      _parameters[key] = newValue;
    } else if (oldValue == newValue) {
      _parameters.remove(key);
    }
  }

  void _saveChanges() async {
    final receipts = ref.read(receiptProvider.notifier);
    try {
      _toggleLoading(true);
      await receipts.updateLineItem(
          widget.receiptId, widget.lineItemId, _parameters);
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

  @override
  Widget build(BuildContext context) {

    final lineItem = ref
      .watch(receiptProvider)
      .firstWhere((element) => element.id == widget.receiptId)
      .lineItems
      .firstWhere((element) => element.id == widget.lineItemId);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilledButton(
              onPressed: () =>
                  _isLoading || _parameters.isEmpty ? null : _saveChanges(),
              child: const Icon(
                Icons.done,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextFormField(
                  key: Key(lineItem.description),
                  initialValue: lineItem.description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onChanged: (value) => _validate(
                    lineItem.description,
                    value,
                    LineItemParameter.description.path,
                  ),
                ),
                TextFormField(
                  key: Key(lineItem.quantity.roundedString()),
                  initialValue: lineItem.quantity.roundedString(),
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  onChanged: (value) => _validate(
                    lineItem.quantity.roundedString(),
                    value,
                    LineItemParameter.quantity.path,
                  ),
                ),
                TextFormField(
                  key: Key(lineItem.price.toStringAsFixed(2)),
                  initialValue: lineItem.price.toStringAsFixed(2),
                  decoration: const InputDecoration(labelText: 'Price'),
                  onChanged: (value) => _validate(
                    lineItem.price.toStringAsFixed(2),
                    value,
                    LineItemParameter.price.path,
                  ),
                ),
                TextFormField(
                  key: Key(lineItem.total.toStringAsFixed(2)),
                  initialValue: lineItem.total.toStringAsFixed(2),
                  decoration: const InputDecoration(labelText: 'Total'),
                  onChanged: (value) => _validate(
                    lineItem.total.toStringAsFixed(2),
                    value,
                    LineItemParameter.total.path,
                  ),
                ),
                TextFormField(
                  initialValue: lineItem.type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  readOnly: true,
                ),
              ],
            ),
          ),
          if (_isLoading) const ProgressScreen(null),
        ],
      ),
    );
  }
}

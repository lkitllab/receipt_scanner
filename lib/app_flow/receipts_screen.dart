import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../providers/providers.dart';
import '../exstensions/alert_extension.dart';
import '../router.dart';

class ReceiptsScreen extends ConsumerStatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  ConsumerState<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends ConsumerState<ReceiptsScreen> {
  List<Receipt> receipts = [];
  late final _progress = ref.read(progressProvider.notifier);

  @override
  void initState() {
    super.initState();
  }

  void _deleteDocument(String documentId) async {
    _progress.startProgress();
    try {
      await ref.read(receiptProvider.notifier).deleteDocument(documentId);
      _progress.stopProgress();
      await showAlert(title: 'Success!', message: 'Item has been deleted');
    } on Exception catch (error) {
      _progress.stopProgress();
      await showAlert(title: 'Error!', message: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipts = ref.watch(receiptProvider);
    return Center(
      child: ListView.builder(
        itemCount: receipts.length,
        itemBuilder: (_, index) => ReceiptItem(receipts[index], delete: () {
          _deleteDocument(receipts[index].id);
        }),
      ),
    );
  }
}

class ReceiptItem extends StatelessWidget {
  const ReceiptItem(
    Receipt receipt, {
    this.delete,
    super.key,
  }) : _receipt = receipt;

  final Receipt _receipt;
  final Function? delete;

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm"),
          content: const Text("Are you sure you wish to delete this item?"),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("DELETE")),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(_receipt.hashCode.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(
          Icons.delete_forever,
          color: Colors.white,
          size: 32,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmationDialog(context),
      onDismissed: (direction) {
        delete!();
      },
      child: Card(
          child: ListTile(
        leading: SizedBox(
          height: 36,
          width: 36,
          child: Image.network(_receipt.vendor.logo),
        ),
        title: Text(_receipt.vendor.name),
        subtitle: Text(_receipt.category),
        trailing: Text(_receipt.total.toString()),
        onTap: () {
          final path = AppRoute.receiptDetails.path();
          context.goNamed(path, pathParameters: {'rid' : _receipt.id});
        },
      )),
    );
  }
}

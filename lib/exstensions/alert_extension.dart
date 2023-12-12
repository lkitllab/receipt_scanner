import 'package:flutter/material.dart';

Future<bool?> _showAlert(BuildContext context,
    {required String title,
    required String message,
    bool cancel = false,
    Function? okComletion,
    Function? cancelComletion}) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (cancel == true)
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              if (cancelComletion != null) cancelComletion();
              Navigator.of(context).pop(false);
            },
          ),
        TextButton(
          child: const Text('Ok'),
          onPressed: () {
            if (okComletion != null) okComletion();
            Navigator.of(context).pop(true);
          },
        ),
      ],
    ),
  );
}

extension StateAlerts<T extends StatefulWidget> on State<T> {
  Future<bool?> showAlert({
    required String title,
    required String message,
  }) async {
    return _showAlert(context, title: title, message: message);
  }

  Future<bool?> showOkCancelAlert(
      {required String title,
      required String message,
      Function? okComletion,
      Function? cancelComletion}) async {
    return _showAlert(
      context,
      title: title,
      message: message,
      cancel: true,
      okComletion: okComletion,
      cancelComletion: cancelComletion,
    );
  }

  Future<void> showTextInputDialog(
    String labelText,
    Function(String) completion,
  ) async {
    String value = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextFormField(
          decoration: InputDecoration(
            label: Text(labelText),
          ),
          onChanged: (v) => value = v,
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              completion(value);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

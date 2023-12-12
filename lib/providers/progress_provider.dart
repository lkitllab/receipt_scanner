import 'package:flutter_riverpod/flutter_riverpod.dart';

// export 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressNotifier extends StateNotifier<bool> {
  ProgressNotifier(super.state);

  Function(Exception)? showDialogCallback;

  void startProgress() {
    state = true;
  }

  void stopProgress() {
    state = false;
  }
}

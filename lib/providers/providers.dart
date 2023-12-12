import 'package:flutter_riverpod/flutter_riverpod.dart';
import './progress_provider.dart';
import './receipts_provider.dart';

export 'package:flutter_riverpod/flutter_riverpod.dart';
export './progress_provider.dart';
export './receipts_provider.dart';

class AppContainer {
  final progressNotifier =
      ProgressNotifier(false);
  final receiptNotifier = ReceiptsNotifier();

  AppContainer() {
    progressNotifier.startProgress();
    receiptNotifier.getDocuments().then((_) {
      progressNotifier.stopProgress();
    });
  }
}

final containerProvider = StateProvider<AppContainer>((ref) => AppContainer());

final progressProvider = StateNotifierProvider<ProgressNotifier, bool>(
    (ref) => ref.read(containerProvider).progressNotifier);

final receiptProvider = StateNotifierProvider<ReceiptsNotifier, List<Receipt>>(
    (ref) => ref.read(containerProvider).receiptNotifier);

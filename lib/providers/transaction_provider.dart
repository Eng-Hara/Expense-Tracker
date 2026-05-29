import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/transaction_repository.dart';
import '../models/transaction_model.dart';
import 'auth_provider.dart';

final transactionRepositoryProvider =
Provider<TransactionRepository>(
      (ref) => TransactionRepository(),
);

final transactionStreamProvider =
StreamProvider.autoDispose<List<TransactionModel>>(
      (ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    // 🔴 safe guard (prevents silent bugs)
    if (user == null || user.id.trim().isEmpty) {
      return const Stream.empty();
    }

    final repository =
    ref.watch(transactionRepositoryProvider);

    return repository.getTransactionsStream(
      user.id.trim(),
    );
  },
);
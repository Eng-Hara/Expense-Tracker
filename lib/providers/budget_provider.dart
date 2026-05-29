import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/budget_model.dart';
import '../services/budget_repository.dart';
import 'auth_provider.dart';

/// Repository Provider
final budgetRepositoryProvider =
Provider<BudgetRepository>((ref) {
  return BudgetRepository();
});

/// Shared selected month across Dashboard + Budget screen
final currentMonthProvider =
StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Budget Stream Provider
final budgetStreamProvider =
StreamProvider.autoDispose<List<BudgetModel>>(
      (ref) {
    final authState = ref.watch(authStateProvider);

    final selectedMonth =
    ref.watch(currentMonthProvider);

    final user = authState.valueOrNull;

    /// user not logged in
    if (user == null ||
        user.id.trim().isEmpty) {
      return Stream.value([]);
    }

    final repository =
    ref.watch(budgetRepositoryProvider);

    return repository.getBudgetsStream(
      user.id.trim(),
      selectedMonth,
    );
  },
);
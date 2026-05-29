import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/category_repository.dart';
import '../models/category_model.dart';
import 'auth_provider.dart';

final categoryRepositoryProvider =
Provider<CategoryRepository>(
      (ref) => CategoryRepository(),
);

final categoryStreamProvider =
StreamProvider.autoDispose<List<CategoryModel>>(
      (ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    // 🔴 safer null + empty handling
    if (user == null || user.id.trim().isEmpty) {
      return const Stream.empty();
    }

    final repository =
    ref.watch(categoryRepositoryProvider);

    return repository.getCategoriesStream(
      user.id.trim(),
    );
  },
);
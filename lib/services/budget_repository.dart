import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget_model.dart';
import 'supabase_service.dart';

class BudgetRepository {
  final SupabaseClient _supabase = SupabaseService.client;

  Stream<List<BudgetModel>> getBudgetsStream(
      String userId,
      DateTime month,
      ) {
    final monthKey =
        "${month.year}-${month.month.toString().padLeft(2, '0')}";

    return _supabase
        .from(SupabaseService.budgetsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
      return data.where((json) {
        final dbMonth = json['month'];

        if (dbMonth == null) return false;

        final parsed = DateTime.tryParse(dbMonth.toString());
        if (parsed == null) return false;

        final dbKey =
            "${parsed.year}-${parsed.month.toString().padLeft(2, '0')}";

        return dbKey == monthKey;
      }).map((json) => BudgetModel.fromJson(json)).toList();
    });
  }

  Future<BudgetModel> addBudget(BudgetModel budget) async {
    try {
      // 🔴 HARD VALIDATION (fix UUID error)
      if (budget.userId.isEmpty ||
          budget.categoryId.isEmpty) {
        throw Exception("Invalid user or category ID");
      }

      final response = await _supabase
          .from(SupabaseService.budgetsTable)
          .insert({
        'user_id': budget.userId,
        'category_id': budget.categoryId,
        'limit_amount': budget.limitAmount,
        'month': budget.month.toIso8601String(),
      })
          .select()
          .maybeSingle(); // ✅ safe

      if (response == null) {
        throw Exception("Budget insert failed");
      }

      return BudgetModel.fromJson(response);
    } catch (e) {
      throw Exception('Add budget failed: $e');
    }
  }

  Future<BudgetModel> updateBudget(BudgetModel budget) async {
    try {
      if (budget.id.isEmpty) {
        throw Exception("Invalid budget ID");
      }

      final response = await _supabase
          .from(SupabaseService.budgetsTable)
          .update({
        'user_id': budget.userId,
        'category_id': budget.categoryId,
        'limit_amount': budget.limitAmount,
        'month': budget.month.toIso8601String(),
      })
          .eq('id', budget.id)
          .select()
          .maybeSingle(); // ✅ safe

      if (response == null) {
        throw Exception("Update failed");
      }

      return BudgetModel.fromJson(response);
    } catch (e) {
      throw Exception('Update budget failed: $e');
    }
  }

  Future<void> deleteBudget(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception("Invalid budget ID");
      }

      await _supabase
          .from(SupabaseService.budgetsTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Delete budget failed: $e');
    }
  }
}
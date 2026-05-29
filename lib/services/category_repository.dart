import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';
import 'supabase_service.dart';

class CategoryRepository {
  final SupabaseClient _supabase = SupabaseService.client;

  Stream<List<CategoryModel>> getCategoriesStream(String userId) {
    return _supabase
        .from(SupabaseService.categoriesTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('name')
        .map(
          (data) => data
          .map((json) => CategoryModel.fromJson(json))
          .toList(),
    );
  }

  Future<CategoryModel> addCategory(CategoryModel category) async {
    final response = await _supabase
        .from(SupabaseService.categoriesTable)
        .insert(category.toJson())
        .select()
        .single();

    return CategoryModel.fromJson(response);
  }

  Future<CategoryModel> updateCategory(CategoryModel category) async {
    final response = await _supabase
        .from(SupabaseService.categoriesTable)
        .update(category.toJson())
        .eq('id', category.id)
        .select()
        .single();

    return CategoryModel.fromJson(response);
  }

  Future<void> deleteCategory(String id) async {
    await _supabase
        .from(SupabaseService.categoriesTable)
        .delete()
        .eq('id', id);
  }
}
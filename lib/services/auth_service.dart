import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<UserModel?> signUp(
      String email,
      String password,
      String name,
      ) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final authUser = response.user ?? response.session?.user;

      if (authUser == null) {
        throw Exception('Signup failed: user not created');
      }

      final user = UserModel(
        id: authUser.id,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      await _supabase.from('users').upsert(user.toJson());

      await _createDefaultCategories(authUser.id);

      return user;
    } catch (e) {
      throw Exception('Sign up error: $e');
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final authUser = response.user;

      if (authUser == null) {
        throw Exception('Login failed');
      }

      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', authUser.id)
          .maybeSingle(); // ✅ FIX: avoids crash

      if (userData == null) {
        throw Exception('User profile not found in database');
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      throw Exception('Sign in error: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Sign out error: $e');
    }
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Future<void> _createDefaultCategories(String userId) async {
    final categories = [
      {'name': 'Food', 'color': '#FF6B6B', 'icon': 'fastfood'},
      {'name': 'Transport', 'color': '#4ECDC4', 'icon': 'directions_car'},
      {'name': 'Shopping', 'color': '#45B7D1', 'icon': 'shopping_cart'},
      {'name': 'Entertainment', 'color': '#96CEB4', 'icon': 'movie'},
      {'name': 'Bills', 'color': '#FFEAA7', 'icon': 'receipt'},
      {'name': 'Health', 'color': '#DDA0DD', 'icon': 'favorite'},
      {'name': 'Salary', 'color': '#98D8C8', 'icon': 'work'},
      {'name': 'Other', 'color': '#B0B0B0', 'icon': 'help'},
    ];

    await _supabase.from('categories').insert(
      categories.map((cat) {
        return {
          'user_id': userId,
          'name': cat['name'],
          'color': cat['color'],
          'icon': cat['icon'],
        };
      }).toList(),
    );
  }
}
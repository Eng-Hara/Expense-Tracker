import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient client =
      Supabase.instance.client;

  // Tables (keep as constants - good practice)
  static const String usersTable = 'users';
  static const String categoriesTable = 'categories';
  static const String transactionsTable = 'transactions';
  static const String budgetsTable = 'budgets';

  // Optional: helper to check auth user safely
  static String? get currentUserId {
    final user = client.auth.currentUser;
    return user?.id;
  }

  // Optional: safe auth check
  static bool get isLoggedIn =>
      client.auth.currentUser != null;
}
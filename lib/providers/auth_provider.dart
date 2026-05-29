import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider = StreamProvider<UserModel?>((ref) {
  final supabase = Supabase.instance.client;

  return supabase.auth.onAuthStateChange.asyncMap((event) async {
    final session = event.session;

    if (session?.user == null) return null;

    final user = session!.user;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle(); // ✅ safe

    if (response == null) return null;

    return UserModel.fromJson(response);
  });
});
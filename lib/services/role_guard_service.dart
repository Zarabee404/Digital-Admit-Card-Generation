import 'package:supabase_flutter/supabase_flutter.dart';

class RoleGuardService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> getCurrentUserRole() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      return null;
    }

    final admin = await _client
        .from('admins')
        .select('id')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (admin != null) {
      return 'admin';
    }

    final student = await _client
        .from('students')
        .select('id')
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (student != null) {
      return 'student';
    }

    return null;
  }

  Future<bool> isAdmin() async {
    final role = await getCurrentUserRole();
    return role == 'admin';
  }

  Future<bool> isStudent() async {
    final role = await getCurrentUserRole();
    return role == 'student';
  }
}
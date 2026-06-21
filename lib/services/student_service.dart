import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student_model.dart';

class StudentService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<StudentModel?> getCurrentStudent() async {
    final user = _client.auth.currentUser;

    if (user == null) return null;

    final response = await _client
        .from('students')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return StudentModel.fromJson(response);
  }
}
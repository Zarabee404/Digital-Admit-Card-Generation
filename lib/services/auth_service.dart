import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_model.dart';
import '../models/student_model.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<void> registerStudent({
    required String name,
    required String studentId,
    required String email,
    required String password,
    required String batch,
    required int semester,
  }) async {
    final authResponse = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );

    final user = authResponse.user;

    if (user == null) {
      throw Exception('Registration failed. Please try again.');
    }

    await _client.from('students').insert({
      'auth_user_id': user.id,
      'name': name.trim(),
      'student_id': studentId.trim(),
      'email': email.trim(),
      'batch': batch.trim(),
      'semester': semester,
      'role': 'student',
    });
  }

  Future<String> loginAndGetRole({
    required String email,
    required String password,
  }) async {
    final authResponse = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = authResponse.user;

    if (user == null) {
      throw Exception('Login failed. Please check your credentials.');
    }

    final admin = await getCurrentAdmin();
    if (admin != null) {
      return 'admin';
    }

    final student = await getCurrentStudent();
    if (student != null) {
      return 'student';
    }

    await logout();
    throw Exception('No registered account found for this user.');
  }

  Future<StudentModel?> getCurrentStudent() async {
    final user = currentUser;

    if (user == null) return null;

    final response = await _client
        .from('students')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return StudentModel.fromJson(response);
  }

  Future<AdminModel?> getCurrentAdmin() async {
    final user = currentUser;

    if (user == null) return null;

    final response = await _client
        .from('admins')
        .select()
        .eq('auth_user_id', user.id)
        .maybeSingle();

    if (response == null) return null;

    return AdminModel.fromJson(response);
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'digitaladmitcard://reset-password',
    );
  }

  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course_model.dart';

class CourseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<CourseModel>> getCoursesBySemester(int semester) async {
    final response = await _client
        .from('courses')
        .select()
        .eq('semester', semester)
        .order('course_code', ascending: true);

    return (response as List)
        .map((course) => CourseModel.fromJson(course))
        .toList();
  }

  Future<List<CourseModel>> getAllCourses() async {
    final response = await _client
        .from('courses')
        .select()
        .order('semester', ascending: true)
        .order('course_code', ascending: true);

    return (response as List)
        .map((course) => CourseModel.fromJson(course))
        .toList();
  }
}
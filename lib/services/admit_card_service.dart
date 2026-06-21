import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admit_card_request_model.dart';
import '../models/course_model.dart';
import '../models/student_model.dart';

class AdmitCardService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<AdmitCardRequestModel?> getCurrentStudentRequest({
    required String studentAuthId,
    required int semester,
  }) async {
    final response = await _client
        .from('admit_card_requests')
        .select()
        .eq('student_auth_id', studentAuthId)
        .eq('semester', semester)
        .maybeSingle();

    if (response == null) return null;

    return AdmitCardRequestModel.fromJson(response);
  }

  Future<AdmitCardRequestModel> applyForAdmitCard({
    required StudentModel student,
    required List<CourseModel> selectedCourses,
  }) async {
    final existingRequest = await getCurrentStudentRequest(
      studentAuthId: student.authUserId,
      semester: student.semester,
    );

    if (existingRequest != null) {
      throw Exception('You have already applied for this semester.');
    }

    if (selectedCourses.isEmpty) {
      throw Exception('Please select at least one course.');
    }

    final requestResponse = await _client
        .from('admit_card_requests')
        .insert({
          'student_auth_id': student.authUserId,
          'student_db_id': student.id,
          'student_name': student.name,
          'student_id': student.studentId,
          'email': student.email,
          'batch': student.batch,
          'semester': student.semester,
          'status': 'pending',
        })
        .select()
        .single();

    final request = AdmitCardRequestModel.fromJson(requestResponse);

    final requestCourses = selectedCourses
        .map((course) => course.toRequestCourseJson(request.id))
        .toList();

    await _client.from('admit_card_request_courses').insert(requestCourses);

    return request;
  }

  Future<List<CourseModel>> getCoursesForRequest(String requestId) async {
    final response = await _client
        .from('admit_card_request_courses')
        .select()
        .eq('request_id', requestId)
        .order('course_code', ascending: true);

    return (response as List)
        .map(
          (course) => CourseModel(
            id: course['course_id'] as int,
            semester: 0,
            courseCode: course['course_code'].toString(),
            courseTitle: course['course_title'].toString(),
            credit: double.parse(course['credit'].toString()),
            createdAt: DateTime.parse(course['created_at'].toString()),
          ),
        )
        .toList();
  }

  Future<List<AdmitCardRequestModel>> getAllRequests() async {
    final response = await _client
        .from('admit_card_requests')
        .select()
        .order('submitted_on', ascending: false);

    return (response as List)
        .map((request) => AdmitCardRequestModel.fromJson(request))
        .toList();
  }

  Future<List<AdmitCardRequestModel>> searchRequestsByStudentId(
    String studentId,
  ) async {
    final response = await _client
        .from('admit_card_requests')
        .select()
        .ilike('student_id', '%${studentId.trim()}%')
        .order('submitted_on', ascending: false);

    return (response as List)
        .map((request) => AdmitCardRequestModel.fromJson(request))
        .toList();
  }

  Future<void> approveRequest(String requestId) async {
    await _client.from('admit_card_requests').update({
      'status': 'approved',
      'approved_on': DateTime.now().toIso8601String(),
    }).eq('id', requestId);
  }

  Future<AdmitCardRequestModel?> verifyAdmitCard(String requestId) async {
    final response = await _client
        .from('admit_card_requests')
        .select()
        .eq('id', requestId)
        .maybeSingle();

    if (response == null) return null;

    return AdmitCardRequestModel.fromJson(response);
  }
    Future<List<CourseModel>> getVerificationCourses(String requestId) async {
  final response = await _client
      .from('admit_card_request_courses')
      .select()
      .eq('request_id', requestId)
      .order('course_code', ascending: true);

  return (response as List)
      .map(
        (course) => CourseModel(
          id: course['course_id'] as int,
          semester: 0,
          courseCode: course['course_code'].toString(),
          courseTitle: course['course_title'].toString(),
          credit: double.parse(course['credit'].toString()),
          createdAt: DateTime.parse(course['created_at'].toString()),
        ),
      )
      .toList();
}

}

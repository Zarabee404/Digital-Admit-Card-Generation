class CourseModel {
  final int id;
  final int semester;
  final String courseCode;
  final String courseTitle;
  final double credit;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.semester,
    required this.courseCode,
    required this.courseTitle,
    required this.credit,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as int,
      semester: json['semester'] as int,
      courseCode: json['course_code'].toString(),
      courseTitle: json['course_title'].toString(),
      credit: double.parse(json['credit'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toRequestCourseJson(String requestId) {
    return {
      'request_id': requestId,
      'course_id': id,
      'course_code': courseCode,
      'course_title': courseTitle,
      'credit': credit,
    };
  }
}
class StudentModel {
  final String id;
  final String authUserId;
  final String name;
  final String studentId;
  final String email;
  final String batch;
  final int semester;
  final String role;
  final DateTime createdAt;

  StudentModel({
    required this.id,
    required this.authUserId,
    required this.name,
    required this.studentId,
    required this.email,
    required this.batch,
    required this.semester,
    required this.role,
    required this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'].toString(),
      authUserId: json['auth_user_id'].toString(),
      name: json['name'].toString(),
      studentId: json['student_id'].toString(),
      email: json['email'].toString(),
      batch: json['batch'].toString(),
      semester: json['semester'] as int,
      role: json['role'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auth_user_id': authUserId,
      'name': name,
      'student_id': studentId,
      'email': email,
      'batch': batch,
      'semester': semester,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
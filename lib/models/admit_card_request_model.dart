class AdmitCardRequestModel {
  final String id;
  final String studentAuthId;
  final String studentDbId;
  final String studentName;
  final String studentId;
  final String email;
  final String batch;
  final int semester;
  final String status;
  final DateTime submittedOn;
  final DateTime? approvedOn;
  final DateTime createdAt;

  AdmitCardRequestModel({
    required this.id,
    required this.studentAuthId,
    required this.studentDbId,
    required this.studentName,
    required this.studentId,
    required this.email,
    required this.batch,
    required this.semester,
    required this.status,
    required this.submittedOn,
    required this.approvedOn,
    required this.createdAt,
  });

  factory AdmitCardRequestModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardRequestModel(
      id: json['id'].toString(),
      studentAuthId: json['student_auth_id'].toString(),
      studentDbId: json['student_db_id'].toString(),
      studentName: json['student_name'].toString(),
      studentId: json['student_id'].toString(),
      email: json['email'].toString(),
      batch: json['batch'].toString(),
      semester: json['semester'] as int,
      status: json['status'].toString(),
      submittedOn: DateTime.parse(json['submitted_on'].toString()),
      approvedOn: json['approved_on'] == null
          ? null
          : DateTime.parse(json['approved_on'].toString()),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
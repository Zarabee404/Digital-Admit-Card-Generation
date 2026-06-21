class AdminModel {
  final String id;
  final String authUserId;
  final String name;
  final String email;
  final String role;
  final DateTime createdAt;

  AdminModel({
    required this.id,
    required this.authUserId,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
  });

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'].toString(),
      authUserId: json['auth_user_id'].toString(),
      name: json['name'].toString(),
      email: json['email'].toString(),
      role: json['role'].toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
    );
  }
}
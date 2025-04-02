import 'package:class_interaction_wear_os/User.dart';

class Instructor extends User {
  final String department;

  Instructor({
    required super.id,
    required super.username,
    required super.email,
    required super.password,
    required super.role,
    required this.department,
  });

  // From JSON
  factory Instructor.fromJson(Map<String, dynamic> json) {
    return Instructor(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'] ?? "",
      role: json['role'],
      department: json['department'],
    );
  }

  // To JSON
  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['department'] = department;
    return data;
  }
}

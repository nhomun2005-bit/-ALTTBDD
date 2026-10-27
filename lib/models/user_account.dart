class UserAccount {
  final String id;
  final String username;
  final String password;
  final String fullName;
  final String phone;
  final String email;
  final String faculty;
  final String academicYear; // Niên khóa (ví dụ: Khóa 2022 - 2026, K22...)
  final String role; // 'volunteer' hoặc 'admin'
  final DateTime createdAt;
  final String? studentId; // MSSV (nếu có)

  UserAccount({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.faculty,
    required this.academicYear,
    this.role = 'volunteer',
    required this.createdAt,
    this.studentId,
  });

  UserAccount copyWith({
    String? id,
    String? username,
    String? password,
    String? fullName,
    String? phone,
    String? email,
    String? faculty,
    String? academicYear,
    String? role,
    DateTime? createdAt,
    String? studentId,
  }) {
    return UserAccount(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      faculty: faculty ?? this.faculty,
      academicYear: academicYear ?? this.academicYear,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      studentId: studentId ?? this.studentId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'phone': phone,
      'email': email,
      'faculty': faculty,
      'academicYear': academicYear,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'studentId': studentId,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      faculty: map['faculty'] ?? '',
      academicYear: map['academicYear'] ?? '',
      role: map['role'] ?? 'volunteer',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      studentId: map['studentId'],
    );
  }
}

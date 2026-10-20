class Volunteer {
  final String id;
  final String studentId; // MSSV
  final String fullName;
  final String email;
  final String phone;
  final String faculty;
  final String? teamName; // Phân công theo đội hình
  // Các thông tin không bắt buộc theo yêu cầu người dùng:
  final String? bloodType; // Nhóm máu (Không bắt buộc)
  final String? skills; // Kỹ năng sở trường (Không bắt buộc)
  final int totalHours;
  final int totalPoints;
  final int completedActivities;

  Volunteer({
    required this.id,
    required this.studentId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.faculty,
    this.teamName,
    this.bloodType, // Không bắt buộc
    this.skills, // Không bắt buộc
    this.totalHours = 0,
    this.totalPoints = 0,
    this.completedActivities = 0,
  });

  Volunteer copyWith({
    String? id,
    String? studentId,
    String? fullName,
    String? email,
    String? phone,
    String? faculty,
    String? teamName,
    String? bloodType,
    String? skills,
    int? totalHours,
    int? totalPoints,
    int? completedActivities,
  }) {
    return Volunteer(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      faculty: faculty ?? this.faculty,
      teamName: teamName ?? this.teamName,
      bloodType: bloodType ?? this.bloodType,
      skills: skills ?? this.skills,
      totalHours: totalHours ?? this.totalHours,
      totalPoints: totalPoints ?? this.totalPoints,
      completedActivities: completedActivities ?? this.completedActivities,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'faculty': faculty,
      'teamName': teamName,
      'bloodType': bloodType,
      'skills': skills,
      'totalHours': totalHours,
      'totalPoints': totalPoints,
      'completedActivities': completedActivities,
    };
  }

  factory Volunteer.fromMap(Map<String, dynamic> map) {
    return Volunteer(
      id: map['id'],
      studentId: map['studentId'],
      fullName: map['fullName'],
      email: map['email'],
      phone: map['phone'],
      faculty: map['faculty'],
      teamName: map['teamName'],
      bloodType: map['bloodType'],
      skills: map['skills'],
      totalHours: map['totalHours'] ?? 0,
      totalPoints: map['totalPoints'] ?? 0,
      completedActivities: map['completedActivities'] ?? 0,
    );
  }
}

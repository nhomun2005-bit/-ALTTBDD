class AdminNotification {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  bool isRead;
  final String? registrationId;
  final String? studentId;
  final String? studentName;
  final String? phone;
  final String? faculty;
  final String? campaignId;
  final String? campaignTitle;

  AdminNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.registrationId,
    this.studentId,
    this.studentName,
    this.phone,
    this.faculty,
    this.campaignId,
    this.campaignTitle,
  });

  AdminNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    String? registrationId,
    String? studentId,
    String? studentName,
    String? phone,
    String? faculty,
    String? campaignId,
    String? campaignTitle,
  }) {
    return AdminNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      registrationId: registrationId ?? this.registrationId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      phone: phone ?? this.phone,
      faculty: faculty ?? this.faculty,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'registrationId': registrationId,
      'studentId': studentId,
      'studentName': studentName,
      'phone': phone,
      'faculty': faculty,
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
    };
  }

  factory AdminNotification.fromMap(Map<String, dynamic> map) {
    return AdminNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
      registrationId: map['registrationId'],
      studentId: map['studentId'],
      studentName: map['studentName'],
      phone: map['phone'],
      faculty: map['faculty'],
      campaignId: map['campaignId'],
      campaignTitle: map['campaignTitle'],
    );
  }
}

enum RegistrationStatus {
  pending,  // Chờ duyệt
  approved, // Đã duyệt
  rejected, // Từ chối
}

extension RegistrationStatusExtension on RegistrationStatus {
  String get label {
    switch (this) {
      case RegistrationStatus.pending:
        return 'Chờ duyệt';
      case RegistrationStatus.approved:
        return 'Đã duyệt';
      case RegistrationStatus.rejected:
        return 'Từ chối';
    }
  }
}

class Registration {
  final String id;
  final String volunteerId;
  final String volunteerName;
  final String studentId;
  final String? phone; // Số điện thoại liên hệ
  final String? faculty; // Khoa / Viện đào tạo
  final String campaignId;
  final String campaignTitle;
  final DateTime registeredDate;
  final RegistrationStatus status;
  final String? assignedTeam; // Phân công theo đội
  final String? note; // Ghi chú phản hồi / lý do
  final int attendanceDays; // Ghi nhận điểm danh
  final bool isCertified; // Đã phê duyệt chứng nhận

  Registration({
    required this.id,
    required this.volunteerId,
    required this.volunteerName,
    required this.studentId,
    this.phone,
    this.faculty,
    required this.campaignId,
    required this.campaignTitle,
    required this.registeredDate,
    this.status = RegistrationStatus.pending,
    this.assignedTeam,
    this.note,
    this.attendanceDays = 0,
    this.isCertified = false,
  });

  Registration copyWith({
    String? id,
    String? volunteerId,
    String? volunteerName,
    String? studentId,
    String? phone,
    String? faculty,
    String? campaignId,
    String? campaignTitle,
    DateTime? registeredDate,
    RegistrationStatus? status,
    String? assignedTeam,
    String? note,
    int? attendanceDays,
    bool? isCertified,
  }) {
    return Registration(
      id: id ?? this.id,
      volunteerId: volunteerId ?? this.volunteerId,
      volunteerName: volunteerName ?? this.volunteerName,
      studentId: studentId ?? this.studentId,
      phone: phone ?? this.phone,
      faculty: faculty ?? this.faculty,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      registeredDate: registeredDate ?? this.registeredDate,
      status: status ?? this.status,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      note: note ?? this.note,
      attendanceDays: attendanceDays ?? this.attendanceDays,
      isCertified: isCertified ?? this.isCertified,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'studentId': studentId,
      'phone': phone,
      'faculty': faculty,
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'registeredDate': registeredDate.toIso8601String(),
      'status': status.name,
      'assignedTeam': assignedTeam,
      'note': note,
      'attendanceDays': attendanceDays,
      'isCertified': isCertified,
    };
  }

  factory Registration.fromMap(Map<String, dynamic> map) {
    return Registration(
      id: map['id'],
      volunteerId: map['volunteerId'],
      volunteerName: map['volunteerName'],
      studentId: map['studentId'],
      phone: map['phone'],
      faculty: map['faculty'],
      campaignId: map['campaignId'],
      campaignTitle: map['campaignTitle'],
      registeredDate: DateTime.parse(map['registeredDate']),
      status: RegistrationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => RegistrationStatus.pending,
      ),
      assignedTeam: map['assignedTeam'],
      note: map['note'],
      attendanceDays: map['attendanceDays'] ?? 0,
      isCertified: map['isCertified'] ?? false,
    );
  }
}

import 'dart:typed_data';

enum ReportStatus {
  pending,  // Chờ đánh giá
  approved, // Đạt yêu cầu
  needsRevision, // Cần bổ sung minh chứng
}

extension ReportStatusExtension on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Chờ đánh giá';
      case ReportStatus.approved:
        return 'Đạt yêu cầu';
      case ReportStatus.needsRevision:
        return 'Cần bổ sung';
    }
  }
}

class TaskReport {
  final String id;
  final String volunteerId;
  final String volunteerName;
  final String studentId;
  final String campaignId;
  final String campaignTitle;
  final String title;
  final String description;
  final String proofDescription; // Chi tiết hình ảnh hoặc link video minh chứng
  final String? proofType; // 'image', 'video', 'document'
  final Uint8List? proofImageBytes; // Dữ liệu ảnh thực tế đã upload
  final String? proofImageName;    // Tên file ảnh
  final DateTime submittedAt;
  final ReportStatus status;
  final int awardedHours;
  final int awardedPoints;
  final String? feedback; // Nhận xét của người quản lý

  TaskReport({
    required this.id,
    required this.volunteerId,
    required this.volunteerName,
    required this.studentId,
    required this.campaignId,
    required this.campaignTitle,
    required this.title,
    required this.description,
    required this.proofDescription,
    this.proofType = 'image',
    this.proofImageBytes,
    this.proofImageName,
    required this.submittedAt,
    this.status = ReportStatus.pending,
    this.awardedHours = 0,
    this.awardedPoints = 0,
    this.feedback,
  });

  TaskReport copyWith({
    String? id,
    String? volunteerId,
    String? volunteerName,
    String? studentId,
    String? campaignId,
    String? campaignTitle,
    String? title,
    String? description,
    String? proofDescription,
    String? proofType,
    Uint8List? proofImageBytes,
    String? proofImageName,
    DateTime? submittedAt,
    ReportStatus? status,
    int? awardedHours,
    int? awardedPoints,
    String? feedback,
  }) {
    return TaskReport(
      id: id ?? this.id,
      volunteerId: volunteerId ?? this.volunteerId,
      volunteerName: volunteerName ?? this.volunteerName,
      studentId: studentId ?? this.studentId,
      campaignId: campaignId ?? this.campaignId,
      campaignTitle: campaignTitle ?? this.campaignTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      proofDescription: proofDescription ?? this.proofDescription,
      proofType: proofType ?? this.proofType,
      proofImageBytes: proofImageBytes ?? this.proofImageBytes,
      proofImageName: proofImageName ?? this.proofImageName,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      awardedHours: awardedHours ?? this.awardedHours,
      awardedPoints: awardedPoints ?? this.awardedPoints,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'studentId': studentId,
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'title': title,
      'description': description,
      'proofDescription': proofDescription,
      'proofType': proofType,
      'submittedAt': submittedAt.toIso8601String(),
      'status': status.name,
      'awardedHours': awardedHours,
      'awardedPoints': awardedPoints,
      'feedback': feedback,
    };
  }

  factory TaskReport.fromMap(Map<String, dynamic> map) {
    return TaskReport(
      id: map['id'],
      volunteerId: map['volunteerId'],
      volunteerName: map['volunteerName'],
      studentId: map['studentId'],
      campaignId: map['campaignId'],
      campaignTitle: map['campaignTitle'],
      title: map['title'],
      description: map['description'],
      proofDescription: map['proofDescription'] ?? '',
      proofType: map['proofType'] ?? 'image',
      submittedAt: DateTime.parse(map['submittedAt']),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      awardedHours: map['awardedHours'] ?? 0,
      awardedPoints: map['awardedPoints'] ?? 0,
      feedback: map['feedback'],
    );
  }
}

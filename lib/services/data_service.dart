import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/campaign.dart';
import '../models/volunteer.dart';
import '../models/registration.dart';
import '../models/task_report.dart';
import '../models/budget_logistics.dart';
import '../models/admin_notification.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal() {
    _initDefaultData();
  }

  // Tình trạng chế độ mạng
  bool isLowBandwidthMode = true; // Bật mặc định để tải siêu nhanh trên 3G

  // Danh sách dữ liệu chính
  late Volunteer currentVolunteer;
  List<Campaign> campaigns = [];
  List<Registration> registrations = [];
  List<TaskReport> taskReports = [];
  Map<String, ActivityBudgetLogistics> budgetLogisticsMap = {};
  List<AdminNotification> adminNotifications = [];

  int get unreadAdminNotificationCount =>
      adminNotifications.where((n) => !n.isRead).length;

  void _initDefaultData() {
    // 1. Hồ sơ sinh viên mẫu (các trường nhóm máu, kỹ năng để trống/tuỳ chọn)
    currentVolunteer = Volunteer(
      id: 'vol_001',
      studentId: '22120098',
      fullName: 'Nguyễn Văn An',
      email: 'an.nguyen@sinhvien.edu.vn',
      phone: '0987654321',
      faculty: 'Công nghệ Thông tin & Truyền thông',
      teamName: 'Đội hình Chuyển đổi số & Dạy tin học',
      bloodType: null, // Không bắt buộc theo yêu cầu người dùng
      skills: null,    // Không bắt buộc theo yêu cầu người dùng
      totalHours: 42,
      totalPoints: 18,
      completedActivities: 2,
    );

    // 2. Danh sách chiến dịch / hoạt động Mùa Hè Xanh
    final now = DateTime.now();
    campaigns = [
      Campaign(
        id: 'camp_001',
        title: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
        category: 'Xây dựng công trình',
        location: 'Xã Tân Mỹ, Huyện Lấp Vò, Tỉnh Đồng Tháp',
        startDate: now.add(const Duration(days: 3)),
        endDate: now.add(const Duration(days: 18)),
        targetVolunteers: 35,
        currentRegistered: 28,
        description: 'Phối hợp với chính quyền địa phương thi công 1 cây cầu bê tông liên ấp và 2km đường giao thông nông thôn phục vụ bà con đi lại thuận tiện.',
        requirements: 'Có sức khỏe tốt, nhiệt tình, ưu tiên sinh viên biết kỹ thuật xây dựng hoặc sẵn sàng lao động công ích.',
        volunteerHours: 45,
        trainingPoints: 15,
        status: 'Đang tuyển',
      ),
      Campaign(
        id: 'camp_002',
        title: 'Chuyển Đổi Số Cộng Đồng & Hỗ Trợ Cài Đặt Dịch Vụ Công VNeID',
        category: 'Chuyển đổi số',
        location: 'Xã Lý Nhơn, Huyện Cần Giờ, TP. Hồ Chí Minh',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 12)),
        targetVolunteers: 25,
        currentRegistered: 25,
        description: 'Đến từng ấp, từng hộ gia đình để hướng dẫn bà con đăng ký tài khoản định danh VNeID, thanh toán trực tuyến không dùng tiền mặt và nộp hồ sơ dịch vụ công trực tuyến.',
        requirements: 'Có điện thoại thông minh, kiên nhẫn hướng dẫn người lớn tuổi, nắm vững quy trình dịch vụ công.',
        volunteerHours: 35,
        trainingPoints: 12,
        status: 'Đang tuyển',
      ),
      Campaign(
        id: 'camp_003',
        title: 'Lớp Học Hè Yêu Thương & Ôn Tập Văn Hóa Cho Trẻ Em Vùng Xa',
        category: 'Dạy học hè',
        location: 'Xã An Phú Trung, Huyện Ba Tri, Tỉnh Bến Tre',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 5)),
        targetVolunteers: 20,
        currentRegistered: 20,
        description: 'Tổ chức các lớp ôn tập Toán, Tiếng Việt, Tiếng Anh và kỹ năng phòng chống đuối nước, sinh hoạt hè cho hơn 150 em học sinh cấp 1, cấp 2.',
        requirements: 'Yêu mến trẻ em, có kỹ năng sư phạm hoặc kinh nghiệm sinh hoạt tập thể thiếu nhi.',
        volunteerHours: 40,
        trainingPoints: 15,
        status: 'Đang diễn ra',
      ),
      Campaign(
        id: 'camp_004',
        title: 'Khám Bệnh, Tư Vấn Sức Khỏe & Tặng Quà Gia Đình Chính Sách',
        category: 'Y tế vì cộng đồng',
        location: 'Huyện Đắk Glong, Tỉnh Đắk Nông',
        startDate: now.subtract(const Duration(days: 25)),
        endDate: now.subtract(const Duration(days: 15)),
        targetVolunteers: 30,
        currentRegistered: 30,
        description: 'Phát thuốc, tư vấn dinh dưỡng cho 500 hộ đồng bào và trao tặng 100 suất học bổng cho học sinh nghèo vượt khó.',
        requirements: 'Đoàn kết, sẵn sàng vượt khó đến vùng sâu vùng xa.',
        volunteerHours: 50,
        trainingPoints: 20,
        status: 'Đã hoàn thành',
      ),
    ];

    // 3. Đơn đăng ký tham gia mẫu
    registrations = [
      Registration(
        id: 'reg_001',
        volunteerId: currentVolunteer.id,
        volunteerName: currentVolunteer.fullName,
        studentId: currentVolunteer.studentId,
        phone: currentVolunteer.phone,
        faculty: currentVolunteer.faculty,
        campaignId: 'camp_002',
        campaignTitle: 'Chuyển Đổi Số Cộng Đồng & Hỗ Trợ Cài Đặt Dịch Vụ Công VNeID',
        registeredDate: now.subtract(const Duration(days: 2)),
        status: RegistrationStatus.approved,
        assignedTeam: 'Đội hình Chuyển đổi số & Dạy tin học',
        note: 'Đã phân công vào Đội 1 phụ trách khu vực Ấp 2 & Ấp 3.',
        attendanceDays: 6,
        isCertified: true,
      ),
      Registration(
        id: 'reg_002',
        volunteerId: currentVolunteer.id,
        volunteerName: currentVolunteer.fullName,
        studentId: currentVolunteer.studentId,
        phone: currentVolunteer.phone,
        faculty: currentVolunteer.faculty,
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
        registeredDate: now.subtract(const Duration(days: 1)),
        status: RegistrationStatus.pending,
        assignedTeam: null,
        note: 'Hồ sơ đang được Ban chỉ huy mặt trận xét duyệt danh sách đợt 1.',
        attendanceDays: 0,
        isCertified: false,
      ),
      Registration(
        id: 'reg_003',
        volunteerId: 'vol_002',
        volunteerName: 'Trần Thị Mai',
        studentId: '22145012',
        phone: '0912345678',
        faculty: 'Y Dược & Điều Dưỡng',
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
        registeredDate: now.subtract(const Duration(days: 3)),
        status: RegistrationStatus.approved,
        assignedTeam: 'Đội Hậu cần & Y tế cơ sở',
        note: 'Duyệt tham gia đội hình hỗ trợ tiếp tế và sơ cấp cứu.',
        attendanceDays: 4,
        isCertified: false,
      ),
      Registration(
        id: 'reg_004',
        volunteerId: 'vol_003',
        volunteerName: 'Lê Hoàng Long',
        studentId: '21110034',
        phone: '0903112233',
        faculty: 'Kỹ Thuật Xây Dựng',
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
        registeredDate: now.subtract(const Duration(days: 4)),
        status: RegistrationStatus.rejected,
        assignedTeam: null,
        note: 'Trùng lịch thi học phần quân sự tập trung cùng thời điểm.',
        attendanceDays: 0,
        isCertified: false,
      ),
    ];

    // Khởi tạo thông báo mẫu cho Admin
    adminNotifications = [
      AdminNotification(
        id: 'notif_001',
        title: 'Sinh viên mới đăng ký hoạt động',
        message: 'Sinh viên ${currentVolunteer.fullName} (MSSV: ${currentVolunteer.studentId}, Khoa: ${currentVolunteer.faculty}, SĐT: ${currentVolunteer.phone}) vừa đăng ký tham gia "Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên".',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: false,
        registrationId: 'reg_002',
        studentId: currentVolunteer.studentId,
        studentName: currentVolunteer.fullName,
        phone: currentVolunteer.phone,
        faculty: currentVolunteer.faculty,
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
      ),
      AdminNotification(
        id: 'notif_002',
        title: 'Sinh viên đăng ký hoạt động',
        message: 'Sinh viên Trần Thị Mai (MSSV: 22145012, Khoa: Y Dược & Điều Dưỡng, SĐT: 0912345678) đã đăng ký tham gia "Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên".',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
        registrationId: 'reg_003',
        studentId: '22145012',
        studentName: 'Trần Thị Mai',
        phone: '0912345678',
        faculty: 'Y Dược & Điều Dưỡng',
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
      ),
      AdminNotification(
        id: 'notif_003',
        title: 'Sinh viên đăng ký hoạt động',
        message: 'Sinh viên Lê Hoàng Long (MSSV: 21110034, Khoa: Kỹ Thuật Xây Dựng, SĐT: 0903112233) đã đăng ký tham gia "Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên".',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
        registrationId: 'reg_004',
        studentId: '21110034',
        studentName: 'Lê Hoàng Long',
        phone: '0903112233',
        faculty: 'Kỹ Thuật Xây Dựng',
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
      ),
    ];

    // 4. Báo cáo nhiệm vụ và minh chứng mẫu
    taskReports = [
      TaskReport(
        id: 'rep_001',
        volunteerId: currentVolunteer.id,
        volunteerName: currentVolunteer.fullName,
        studentId: currentVolunteer.studentId,
        campaignId: 'camp_002',
        campaignTitle: 'Chuyển Đổi Số Cộng Đồng & Hỗ Trợ Cài Đặt Dịch Vụ Công VNeID',
        title: 'Hoàn thành hướng dẫn định danh VNeID cho 35 hộ gia đình Ấp 2',
        description: 'Tổ công tác gồm 3 chiến sĩ đã đến trực tiếp 35 hộ dân, hỗ trợ kích hoạt mức 2 thành công và phát 50 tờ rơi hướng dẫn nộp phạt nguội, đăng ký tạm trú qua mạng.',
        proofDescription: 'Ảnh chụp cùng bà con tại trụ sở ấp và danh sách ký nhận hỗ trợ (35 chữ ký). Video quay ngắn 1 phút ghi nhận hoạt động.',
        proofType: 'image',
        submittedAt: now.subtract(const Duration(days: 1)),
        status: ReportStatus.approved,
        awardedHours: 8,
        awardedPoints: 5,
        feedback: 'Báo cáo rất chi tiết, hình ảnh minh chứng rõ ràng. Biểu dương tinh thần tích cực của đồng chí.',
        proofImageName: 'minh_chung_vneid_ap2.png',
        proofImageBytes: base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAZAAAAEECAIAAACJKvXOAAADnUlEQVR4nO3YwQ2CUBRFQTTUgQ1pSWywJCuyE2MB6k+MmmNmtrB4q5MLu2U7TgAF+18fADBKsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIGN+/vi6Xr51CcDd4XyaHrCwgAzBAv7lk3BkpAG8b+QHlIUFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAxD753XS8fvgTgBQsLyBAsIGO3bMdf3wAwxMICMgQLyBAsIEOwgAzBAjIEC8gQLCBDsICp4gZsZAv20jafvwAAAABJRU5ErkJggg==',
        ),
      ),
      TaskReport(
        id: 'rep_002',
        volunteerId: 'vol_002',
        volunteerName: 'Trần Thị Mai',
        studentId: '22145012',
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
        title: 'Tiếp nhận và bảo quản 15 hộp sơ cứu & 50 suất cơm trưa tình nguyện',
        description: 'Đã kiểm đếm đầy đủ vật tư y tế, bông băng cồn đỏ, phát nước uống tăng lực cho anh em đội xây dựng thi công mố cầu số 1.',
        proofDescription: 'Biên bản bàn giao thực phẩm và ảnh chụp khu vực bếp ăn hậu cần dã chiến.',
        proofType: 'image',
        submittedAt: now.subtract(const Duration(hours: 5)),
        status: ReportStatus.pending,
        awardedHours: 0,
        awardedPoints: 0,
        feedback: null,
      ),
    ];

    // 5. Ngân sách & Hậu cần theo biểu mẫu
    budgetLogisticsMap['camp_001'] = ActivityBudgetLogistics(
      id: 'bl_001',
      campaignId: 'camp_001',
      campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
      estimatedBudget: 35000000, // 35 triệu VNĐ
      actualCost: 31800000,      // 31.8 triệu VNĐ
      logisticsItems: [
        LogisticsItem(itemName: 'Áo thun Mùa Hè Xanh', quantity: 40, unit: 'Cái', note: 'Đã cấp phát đủ cho TNV'),
        LogisticsItem(itemName: 'Nón tai bèo Đoàn - Hội', quantity: 40, unit: 'Cái', note: 'Đã nhận từ Tỉnh Đoàn'),
        LogisticsItem(itemName: 'Cuốc, xẻng, xe rùa thi công', quantity: 15, unit: 'Bộ', note: 'Mượn từ HTX địa phương'),
        LogisticsItem(itemName: 'Túi thuốc & dụng cụ y tế lưu động', quantity: 4, unit: 'Hộp', note: 'Đầy đủ cồn, gạc, thuốc cảm'),
        LogisticsItem(itemName: 'Băng rôn khẩu hiệu tuyên truyền', quantity: 3, unit: 'Tấm', note: 'Treo tại cầu và trụ sở UBND xã'),
      ],
      generalNotes: 'Chi phí phát sinh thấp hơn dự toán nhờ địa phương tài trợ cát đá và hỗ trợ nấu cơm trưa cho đội hình.',
      lastUpdated: now.subtract(const Duration(days: 1)),
    );

    budgetLogisticsMap['camp_002'] = ActivityBudgetLogistics(
      id: 'bl_002',
      campaignId: 'camp_002',
      campaignTitle: 'Chuyển Đổi Số Cộng Đồng & Hỗ Trợ Cài Đặt Dịch Vụ Công VNeID',
      estimatedBudget: 12000000, // 12 triệu VNĐ
      actualCost: 11200000,      // 11.2 triệu VNĐ
      logisticsItems: [
        LogisticsItem(itemName: 'Áo thun Mùa Hè Xanh', quantity: 25, unit: 'Cái', note: 'Đã trang bị'),
        LogisticsItem(itemName: 'Nón tai bèo', quantity: 25, unit: 'Cái', note: 'Đã trang bị'),
        LogisticsItem(itemName: 'Tài liệu & Tờ rơi hướng dẫn VNeID', quantity: 1200, unit: 'Tờ', note: 'Đã in ấn hoàn tất'),
        LogisticsItem(itemName: 'Sim 4G lưu động & Pin sạc dự phòng', quantity: 10, unit: 'Bộ', note: 'Phục vụ điểm không có wifi'),
      ],
      generalNotes: 'Các tổ lưu động đi ca ngày và tối, kinh phí tập trung cho tài liệu tuyên truyền và nước uống giải khát.',
      lastUpdated: now.subtract(const Duration(hours: 12)),
    );
  }

  // --- ACTIONS CHO SINH VIÊN ---

  // Đăng ký tham gia chiến dịch với thông tin sinh viên nhập từ Form
  bool registerForCampaign({
    required Campaign campaign,
    String? studentId,
    String? volunteerName,
    String? phone,
    String? faculty,
  }) {
    final finalStudentId = (studentId != null && studentId.trim().isNotEmpty)
        ? studentId.trim()
        : currentVolunteer.studentId;
    final finalVolunteerName = (volunteerName != null && volunteerName.trim().isNotEmpty)
        ? volunteerName.trim()
        : currentVolunteer.fullName;
    final finalPhone = (phone != null && phone.trim().isNotEmpty)
        ? phone.trim()
        : currentVolunteer.phone;
    final finalFaculty = (faculty != null && faculty.trim().isNotEmpty)
        ? faculty.trim()
        : currentVolunteer.faculty;

    final existing = registrations.any(
      (r) => r.campaignId == campaign.id && (r.volunteerId == currentVolunteer.id || r.studentId == finalStudentId),
    );
    if (existing) {
      return false; // Đã đăng ký rồi
    }

    final newRegId = 'reg_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    final newReg = Registration(
      id: newRegId,
      volunteerId: currentVolunteer.id,
      volunteerName: finalVolunteerName,
      studentId: finalStudentId,
      phone: finalPhone,
      faculty: finalFaculty,
      campaignId: campaign.id,
      campaignTitle: campaign.title,
      registeredDate: now,
      status: RegistrationStatus.pending,
      note: 'Hồ sơ đã nộp thành công, chờ Ban chỉ huy duyệt.',
    );

    registrations.insert(0, newReg);

    // Cập nhật số lượng chiến sĩ đã đăng ký của chiến dịch
    final campIndex = campaigns.indexWhere((c) => c.id == campaign.id);
    if (campIndex >= 0) {
      campaigns[campIndex] = campaigns[campIndex].copyWith(
        currentRegistered: campaigns[campIndex].currentRegistered + 1,
      );
    }

    // Tạo thông báo mới cho Admin Ban Chỉ Huy
    final notif = AdminNotification(
      id: 'notif_${now.millisecondsSinceEpoch}',
      title: 'Sinh viên mới đăng ký hoạt động',
      message: 'Sinh viên $finalVolunteerName (MSSV: $finalStudentId, Khoa: $finalFaculty, SĐT: $finalPhone) vừa nộp đơn đăng ký hoạt động "${campaign.title}".',
      createdAt: now,
      isRead: false,
      registrationId: newRegId,
      studentId: finalStudentId,
      studentName: finalVolunteerName,
      phone: finalPhone,
      faculty: finalFaculty,
      campaignId: campaign.id,
      campaignTitle: campaign.title,
    );
    adminNotifications.insert(0, notif);

    notifyListeners();
    return true;
  }

  // --- ACTIONS THÔNG BÁO CHO ADMIN ---
  void markNotificationAsRead(String id) {
    final index = adminNotifications.indexWhere((n) => n.id == id);
    if (index >= 0 && !adminNotifications[index].isRead) {
      adminNotifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool hasUnread = false;
    for (var n in adminNotifications) {
      if (!n.isRead) {
        n.isRead = true;
        hasUnread = true;
      }
    }
    if (hasUnread) {
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    adminNotifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // Nộp báo cáo nhiệm vụ kèm minh chứng
  void submitTaskReport({
    required String campaignId,
    required String campaignTitle,
    required String title,
    required String description,
    required String proofDescription,
    String proofType = 'image',
    Uint8List? proofImageBytes,
    String? proofImageName,
  }) {
    final newReport = TaskReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      volunteerId: currentVolunteer.id,
      volunteerName: currentVolunteer.fullName,
      studentId: currentVolunteer.studentId,
      campaignId: campaignId,
      campaignTitle: campaignTitle,
      title: title,
      description: description,
      proofDescription: proofDescription,
      proofType: proofType,
      proofImageBytes: proofImageBytes,
      proofImageName: proofImageName,
      submittedAt: DateTime.now(),
      status: ReportStatus.pending,
    );

    taskReports.insert(0, newReport);
    notifyListeners();
  }

  // Cập nhật / Bổ sung minh chứng cho báo cáo nhiệm vụ
  void updateTaskReport({
    required String reportId,
    String? title,
    String? description,
    String? proofDescription,
    String? proofType,
    Uint8List? proofImageBytes,
    String? proofImageName,
    bool resubmit = true,
  }) {
    final index = taskReports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      final old = taskReports[index];
      taskReports[index] = old.copyWith(
        title: title ?? old.title,
        description: description ?? old.description,
        proofDescription: proofDescription ?? old.proofDescription,
        proofType: proofType ?? old.proofType,
        proofImageBytes: proofImageBytes ?? old.proofImageBytes,
        proofImageName: proofImageName ?? old.proofImageName,
        status: resubmit ? ReportStatus.pending : old.status,
        submittedAt: resubmit ? DateTime.now() : old.submittedAt,
      );
      notifyListeners();
    }
  }

  // Cập nhật thông tin cá nhân (nhóm máu và kỹ năng là tuỳ chọn)
  void updateVolunteerProfile({
    required String fullName,
    required String phone,
    required String email,
    required String faculty,
    String? bloodType,
    String? skills,
  }) {
    currentVolunteer = currentVolunteer.copyWith(
      fullName: fullName,
      phone: phone,
      email: email,
      faculty: faculty,
      bloodType: bloodType,
      skills: skills,
    );
    notifyListeners();
  }

  // --- ACTIONS CHO ADMIN / BAN CHỈ HUY ---

  // Tạo hoặc cập nhật chiến dịch
  void saveCampaign(Campaign campaign) {
    final index = campaigns.indexWhere((c) => c.id == campaign.id);
    if (index >= 0) {
      campaigns[index] = campaign;
    } else {
      campaigns.insert(0, campaign);
      // Tạo sẵn bản ghi hậu cần mặc định
      budgetLogisticsMap[campaign.id] = ActivityBudgetLogistics(
        id: 'bl_${campaign.id}',
        campaignId: campaign.id,
        campaignTitle: campaign.title,
        estimatedBudget: 15000000,
        actualCost: 0,
        logisticsItems: [
          LogisticsItem(itemName: 'Áo thun Mùa Hè Xanh', quantity: campaign.targetVolunteers, unit: 'Cái', note: 'Dự kiến'),
          LogisticsItem(itemName: 'Nón tai bèo', quantity: campaign.targetVolunteers, unit: 'Cái', note: 'Dự kiến'),
          LogisticsItem(itemName: 'Túi thuốc y tế', quantity: 2, unit: 'Hộp', note: 'Dự kiến'),
        ],
        generalNotes: 'Khởi tạo theo kế hoạch hoạt động mới.',
        lastUpdated: DateTime.now(),
      );
    }
    notifyListeners();
  }

  // Xóa chiến dịch
  void deleteCampaign(String id) {
    campaigns.removeWhere((c) => c.id == id);
    budgetLogisticsMap.remove(id);
    notifyListeners();
  }

  // Phê duyệt đăng ký & phân đội hình
  void approveRegistration(String registrationId, String assignedTeam, String? note) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      final reg = registrations[index];
      registrations[index] = reg.copyWith(
        status: RegistrationStatus.approved,
        assignedTeam: assignedTeam,
        note: note ?? 'Đã được Ban chỉ huy phê duyệt tham gia đội hình.',
      );
      notifyListeners();
    }
  }

  // Từ chối đăng ký
  void rejectRegistration(String registrationId, String reason) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      final reg = registrations[index];
      registrations[index] = reg.copyWith(
        status: RegistrationStatus.rejected,
        note: reason,
      );
      notifyListeners();
    }
  }

  // Ghi nhận điểm danh
  void updateAttendance(String registrationId, int attendanceDays) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      registrations[index] = registrations[index].copyWith(
        attendanceDays: attendanceDays,
      );
      notifyListeners();
    }
  }

  // Đánh giá minh chứng nhiệm vụ và cộng điểm/giờ
  void evaluateTaskReport({
    required String reportId,
    required ReportStatus status,
    required int awardedHours,
    required int awardedPoints,
    required String feedback,
  }) {
    final index = taskReports.indexWhere((r) => r.id == reportId);
    if (index >= 0) {
      final old = taskReports[index];
      taskReports[index] = old.copyWith(
        status: status,
        awardedHours: awardedHours,
        awardedPoints: awardedPoints,
        feedback: feedback,
      );

      // Nếu duyệt và là báo cáo của sinh viên hiện tại, cộng điểm
      if (status == ReportStatus.approved && old.volunteerId == currentVolunteer.id) {
        currentVolunteer = currentVolunteer.copyWith(
          totalHours: currentVolunteer.totalHours + awardedHours,
          totalPoints: currentVolunteer.totalPoints + awardedPoints,
        );
      }
      notifyListeners();
    }
  }

  // Phê duyệt cấp chứng nhận điện tử
  void issueCertificate(String registrationId) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      registrations[index] = registrations[index].copyWith(
        isCertified: true,
      );
      if (registrations[index].volunteerId == currentVolunteer.id) {
        currentVolunteer = currentVolunteer.copyWith(
          completedActivities: currentVolunteer.completedActivities + 1,
        );
      }
      notifyListeners();
    }
  }

  // Cập nhật ngân sách và hậu cần
  void updateBudgetLogistics(ActivityBudgetLogistics data) {
    budgetLogisticsMap[data.campaignId] = data;
    notifyListeners();
  }

  void toggleLowBandwidthMode() {
    isLowBandwidthMode = !isLowBandwidthMode;
    notifyListeners();
  }
}

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/campaign.dart';
import '../models/volunteer.dart';
import '../models/registration.dart';
import '../models/task_report.dart';
import '../models/budget_logistics.dart';
import '../models/admin_notification.dart';
import '../models/faculty.dart';
import '../models/user_account.dart';
import 'firebase_service.dart';

class DataService extends ChangeNotifier {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;

  final FirebaseService _firebaseService = FirebaseService();

  // Trạng thái kết nối và đồng bộ Firebase
  bool _isFirebaseConnected = false;
  bool get isFirebaseConnected => _isFirebaseConnected;

  bool _isSyncingFirebase = false;
  bool get isSyncingFirebase => _isSyncingFirebase;

  String? _lastSyncMessage;
  String? get lastSyncMessage => _lastSyncMessage;

  // Tình trạng chế độ mạng
  bool isLowBandwidthMode = true; // Bật mặc định để tải siêu nhanh trên 3G

  // Địa chỉ khuôn viên trường đại học
  final String universityCampusAddress =
      'Số 1 Võ Văn Ngân, Phường Linh Chiểu, TP. Thủ Đức, TP. Hồ Chí Minh';

  // Quản lý tài khoản người dùng và xác thực
  List<UserAccount> users = [];
  UserAccount? currentUser;
  bool get isLoggedIn => currentUser != null;
  bool get isAdmin => currentUser?.role == 'admin';

  // Danh sách dữ liệu chính
  late Volunteer currentVolunteer;
  List<Faculty> faculties = [];
  List<Campaign> campaigns = [];
  List<Registration> registrations = [];
  List<TaskReport> taskReports = [];
  Map<String, ActivityBudgetLogistics> budgetLogisticsMap = {};
  List<AdminNotification> adminNotifications = [];

  int get unreadAdminNotificationCount =>
      adminNotifications.where((n) => !n.isRead).length;

  DataService._internal() {
    _initDefaultData();
    _initFirebase();
  }

  // --- KHỞI TẠO DỮ LIỆU MẶC ĐỊNH CHO BỘ NHỚ RAM BAN ĐẦU ---
  void _initDefaultData() {
    // 1. Hồ sơ sinh viên mẫu
    currentVolunteer = Volunteer(
      id: 'vol_001',
      studentId: '22120098',
      fullName: 'Nguyễn Văn An',
      email: 'an.nguyen@sinhvien.edu.vn',
      phone: '0987654321',
      faculty: 'Khoa Công nghệ Thông tin & TT',
      teamName: 'Đội hình Chuyển đổi số & Dạy tin học',
      bloodType: 'O',
      skills: 'Tin học văn phòng, Dạy học, Lắp ráp mạng',
      totalHours: 42,
      totalPoints: 18,
      completedActivities: 2,
    );

    // 1.1. Danh sách tài khoản người dùng mẫu
    users = [
      UserAccount(
        id: 'usr_001',
        username: 'annguyen',
        password: 'password123',
        fullName: 'Nguyễn Văn An',
        phone: '0987654321',
        email: 'an.nguyen@sinhvien.edu.vn',
        faculty: 'Khoa Công nghệ Thông tin & TT',
        academicYear: 'Khóa 2022 - 2026',
        role: 'volunteer',
        studentId: '22120098',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserAccount(
        id: 'usr_admin',
        username: 'admin',
        password: 'admin123',
        fullName: 'Ban Chỉ Huy Chiến Dịch',
        phone: '0903123456',
        email: 'bch.muahexanh@sinhvien.edu.vn',
        faculty: 'Đoàn - Hội Sinh Viên',
        academicYear: 'Ban Chỉ Huy',
        role: 'admin',
        studentId: null,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];

    // Mặc định chưa đăng nhập → sẽ hiển thị màn hình Auth
    currentUser = null;

    // 2. Danh sách Khoa / Viện của Trường
    faculties = [
      Faculty(
        id: 'fac_001',
        code: 'CNTT',
        name: 'Khoa Công nghệ Thông tin & TT',
        description: 'Phụ trách mũi nhọn Chuyển đổi số, phổ cập tin học cộng đồng và dịch vụ công trực tuyến.',
        leaderName: 'TS. Nguyễn Văn Bình - Bí thư Đoàn khoa',
        contactPhone: '0903123456',
        colorValue: 0xFF1E88E5,
      ),
      Faculty(
        id: 'fac_002',
        code: 'KTXD',
        name: 'Khoa Kỹ thuật Xây dựng',
        description: 'Chuyên trách các công trình cầu giao thông nông thôn, bê tông hóa tuyến đường và sửa chữa nhà tình bạn.',
        leaderName: 'ThS. Lê Hoàng Nam - Phó Bí thư Đoàn khoa',
        contactPhone: '0918765432',
        colorValue: 0xFFE65100,
      ),
      Faculty(
        id: 'fac_003',
        code: 'YD',
        name: 'Khoa Y Dược & Sức Khỏe',
        description: 'Khám bệnh, phát thuốc miễn phí cho hộ nghèo, tập huấn sơ cấp cứu và phòng chống dịch bệnh.',
        leaderName: 'BS. Trần Mai Anh - Phụ trách Đội Y tế',
        contactPhone: '0988112233',
        colorValue: 0xFF00897B,
      ),
      Faculty(
        id: 'fac_004',
        code: 'SP',
        name: 'Khoa Sư phạm & Ngôn ngữ',
        description: 'Tổ chức các lớp học hè yêu thương, ôn tập văn hóa, rèn luyện kỹ năng sống cho thiếu nhi.',
        leaderName: 'ThS. Phạm Thị Thu - Ban phong trào',
        contactPhone: '0977445566',
        colorValue: 0xFF7B1FA2,
      ),
      Faculty(
        id: 'fac_005',
        code: 'MT',
        name: 'Khoa Môi trường & Đô thị',
        description: 'Chiến dịch Ngày Chủ Nhật Xanh, xử lý điểm đen rác thải, trồng cây xanh bảo vệ cảnh quan trường và địa phương.',
        leaderName: 'Kỹ sư Đặng Quốc Huy - Bí thư Chi đoàn',
        contactPhone: '0933556677',
        colorValue: 0xFF43A047,
      ),
    ];

    // 3. Danh sách chiến dịch / hoạt động Mùa Hè Xanh
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
        facultyId: 'fac_002',
        facultyName: 'Khoa Kỹ thuật Xây dựng',
        isNearCampus: false,
        distanceFromCampusKm: 145.0,
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
        facultyId: 'fac_001',
        facultyName: 'Khoa Công nghệ Thông tin & TT',
        isNearCampus: false,
        distanceFromCampusKm: 65.0,
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
        facultyId: 'fac_004',
        facultyName: 'Khoa Sư phạm & Ngôn ngữ',
        isNearCampus: false,
        distanceFromCampusKm: 98.0,
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
        facultyId: 'fac_003',
        facultyName: 'Khoa Y Dược & Sức Khỏe',
        isNearCampus: false,
        distanceFromCampusKm: 260.0,
      ),
      Campaign(
        id: 'camp_005',
        title: 'Chuyển Đổi Số & Hướng Dẫn VNeID Tại Phường Linh Chiểu',
        category: 'Chuyển đổi số',
        location: 'UBND Phường Linh Chiểu, TP. Thủ Đức (Cạnh trường)',
        startDate: now.add(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 7)),
        targetVolunteers: 20,
        currentRegistered: 14,
        description: 'Phối hợp cùng UBND Phường kế bên trường đại học để hỗ trợ bà con kích hoạt VNeID định danh mức 2 và tích hợp thông tin thẻ BHYT.',
        requirements: 'Sinh viên năng động, có điện thoại thông minh kết nối 4G/Wifi.',
        volunteerHours: 20,
        trainingPoints: 10,
        status: 'Đang tuyển',
        facultyId: 'fac_001',
        facultyName: 'Khoa Công nghệ Thông tin & TT',
        isNearCampus: true,
        distanceFromCampusKm: 0.6,
      ),
      Campaign(
        id: 'camp_006',
        title: 'Ngày Chủ Nhật Xanh - Cải Tạo Mảng Xanh Khuôn Viên & KTX Trường',
        category: 'Xây dựng công trình',
        location: 'Khuôn viên chính & Khu Ký túc xá Sinh viên',
        startDate: now.add(const Duration(days: 4)),
        endDate: now.add(const Duration(days: 6)),
        targetVolunteers: 40,
        currentRegistered: 31,
        description: 'Thu gom phân loại rác tái chế, trồng mới 120 cây bóng mát và hoa kiểng, chỉnh trang cảnh quan xanh sạch đẹp tại khuôn viên trường.',
        requirements: 'Nhiệt huyết, thích hoạt động ngoài trời cải tạo môi trường học tập.',
        volunteerHours: 15,
        trainingPoints: 8,
        status: 'Đang tuyển',
        facultyId: 'fac_005',
        facultyName: 'Khoa Môi trường & Đô thị',
        isNearCampus: true,
        distanceFromCampusKm: 0.1,
      ),
      Campaign(
        id: 'camp_007',
        title: 'Gia Sư Áo Xanh Cho Trẻ Em Cơ Nhỡ - Cơ Sở Gò Dưa Thủ Đức',
        category: 'Dạy học hè',
        location: 'Trung tâm Bảo trợ Trẻ em Tam Bình - Gò Dưa, TP. Thủ Đức',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 2)),
        targetVolunteers: 15,
        currentRegistered: 15,
        description: 'Đã hoàn thành 12 buổi dạy kèm kiến thức Toán, Anh văn và giao lưu trò chơi dân gian cho 45 em nhỏ có hoàn cảnh đặc biệt.',
        requirements: 'Kiên nhẫn, yêu thương trẻ em.',
        volunteerHours: 30,
        trainingPoints: 12,
        status: 'Đã hoàn thành',
        facultyId: 'fac_004',
        facultyName: 'Khoa Sư phạm & Ngôn ngữ',
        isNearCampus: true,
        distanceFromCampusKm: 3.5,
      ),
    ];

    // 4. Đơn đăng ký tham gia mẫu
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
        faculty: 'Khoa Y Dược & Sức Khỏe',
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
        faculty: 'Khoa Kỹ thuật Xây dựng',
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

    // 5. Thông báo mẫu cho Admin
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
        message: 'Sinh viên Trần Thị Mai (MSSV: 22145012, Khoa: Khoa Y Dược & Sức Khỏe, SĐT: 0912345678) đã đăng ký tham gia "Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên".',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: true,
        registrationId: 'reg_003',
        studentId: '22145012',
        studentName: 'Trần Thị Mai',
        phone: '0912345678',
        faculty: 'Khoa Y Dược & Sức Khỏe',
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
      ),
      AdminNotification(
        id: 'notif_003',
        title: 'Sinh viên đăng ký hoạt động',
        message: 'Sinh viên Lê Hoàng Long (MSSV: 21110034, Khoa: Khoa Kỹ thuật Xây dựng, SĐT: 0903112233) đã đăng ký tham gia "Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên".',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
        registrationId: 'reg_004',
        studentId: '21110034',
        studentName: 'Lê Hoàng Long',
        phone: '0903112233',
        faculty: 'Khoa Kỹ thuật Xây dựng',
        campaignId: 'camp_001',
        campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
      ),
    ];

    // 6. Báo cáo nhiệm vụ và minh chứng mẫu
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
          'iVBORw0KGgoAAAANSUhEUgAAAZAAAAEECAIAAACJKvXOAAADnUlEQVR4nO3YwQ2CUBRFQTTUgQ1pSWywJCuyE2MB6k+MmmNmtrB4q5MLu2U7TgAF+18fADBKsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIGN+/vi6Xr51CcDd4XyaHrCwgAzBAv7lk3BkpAG8b+QHlIUFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAxD753XS8fvgTgBQsLyBAsIGO3bMdf3wAwxMICMgQLyBAsIEOwgAzBAjIEC8gQLCBDsICp4gZsZAv20jafvwAAAABJRU5ErkJggg==',
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
        proofImageName: 'minh_chung_bep_an_da_chien.png',
        proofImageBytes: base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAZAAAAEECAIAAACJKvXOAAADnUlEQVR4nO3YwQ2CUBRFQTTUgQ1pSWywJCuyE2MB6k+MmmNmtrB4q5MLu2U7TgAF+18fADBKsIAMwQIyBAvIECwgQ7CADMECMgQLyBAsIGN+/vi6Xr51CcDd4XyaHrCwgAzBAv7lk3BkpAG8b+QHlIUFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAhWECGYAEZggVkCBaQIVhAhmABGYIFZAgWkCFYQIZgARmCBWQIFpAxD753XS8fvgTgBQsLyBAsIGO3bMdf3wAwxMICMgQLyBAsIEOwgAzBAjIEC8gQLCBDsICp4gZsZAv20jafvwAAAABJRU5ErkJggg==',
        ),
        submittedAt: now.subtract(const Duration(hours: 5)),
        status: ReportStatus.pending,
        awardedHours: 0,
        awardedPoints: 0,
        feedback: null,
      ),
    ];

    // 7. Ngân sách & Hậu cần theo biểu mẫu
    budgetLogisticsMap['camp_001'] = ActivityBudgetLogistics(
      id: 'bl_001',
      campaignId: 'camp_001',
      campaignTitle: 'Xây Cầu Nông Thôn & Bê Tông Hóa Tuyến Đường Thanh Niên',
      estimatedBudget: 35000000,
      actualCost: 31800000,
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
      estimatedBudget: 12000000,
      actualCost: 11200000,
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

  // --- KẾT NỐI VÀ ĐỒNG BỘ REALTIME TỪ FIREBASE ---
  void _initFirebase() {
    // 1. Lắng nghe trạng thái mạng kết nối Firebase
    _firebaseService.initConnectionListener((connected) {
      _isFirebaseConnected = connected;
      notifyListeners();
    });

    // 2. Tự động kiểm tra nếu database Firebase đang rỗng thì nạp dữ liệu mẫu lên
    _autoSeedIfEmpty();

    // 3. Đăng ký các stream lắng nghe realtime từ Firebase
    _listenToFirebaseStreams();
  }

  Future<void> _autoSeedIfEmpty() async {
    try {
      final isEmpty = await _firebaseService.isDatabaseEmpty();
      if (isEmpty) {
        debugPrint('[DataService] Firebase Database đang rỗng, tiến hành tạo dữ liệu mẫu ban đầu...');
        await syncToFirebase();
      }
    } catch (e) {
      debugPrint('[DataService] Lỗi autoSeedIfEmpty: $e');
    }
  }

  void _listenToFirebaseStreams() {
    // 1. Khoa
    _firebaseService.facultiesStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final list = <Faculty>[];
          final seenIds = <String>{};
          final seenNames = <String>{};
          data.forEach((k, v) {
            final faculty = Faculty.fromMap(Map<String, dynamic>.from(v as Map));
            final trimmedName = faculty.name.trim();
            if (trimmedName.isNotEmpty && !seenIds.contains(faculty.id) && !seenNames.contains(trimmedName)) {
              seenIds.add(faculty.id);
              seenNames.add(trimmedName);
              list.add(faculty);
            }
          });
          if (list.isNotEmpty) {
            faculties = list;
            notifyListeners();
          }
        } catch (e) {
          debugPrint('[DataService] Lỗi parse faculties từ Firebase: $e');
        }
      }
    });

    // 2. Chiến dịch
    _firebaseService.campaignsStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final list = <Campaign>[];
          data.forEach((k, v) {
            list.add(Campaign.fromMap(Map<String, dynamic>.from(v as Map)));
          });
          list.sort((a, b) => b.startDate.compareTo(a.startDate));
          campaigns = list;
          notifyListeners();
        } catch (e) {
          debugPrint('[DataService] Lỗi parse campaigns từ Firebase: $e');
        }
      }
    });

    // 3. Đăng ký
    _firebaseService.registrationsStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final list = <Registration>[];
          data.forEach((k, v) {
            list.add(Registration.fromMap(Map<String, dynamic>.from(v as Map)));
          });
          list.sort((a, b) => b.registeredDate.compareTo(a.registeredDate));
          registrations = list;
          notifyListeners();
        } catch (e) {
          debugPrint('[DataService] Lỗi parse registrations từ Firebase: $e');
        }
      }
    });

    // 4. Báo cáo nhiệm vụ
    _firebaseService.taskReportsStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final list = <TaskReport>[];
          data.forEach((k, v) {
            var item = TaskReport.fromMap(Map<String, dynamic>.from(v as Map));
            // Bảo toàn ảnh minh chứng trong RAM nếu bản tin Firebase chưa đồng bộ kịp chuỗi Base64
            if (item.proofImageBytes == null) {
              final existingIndex = taskReports.indexWhere((r) => r.id == item.id);
              if (existingIndex != -1 && taskReports[existingIndex].proofImageBytes != null) {
                item = item.copyWith(
                  proofImageBytes: taskReports[existingIndex].proofImageBytes,
                  proofImageName: taskReports[existingIndex].proofImageName,
                );
              }
            }
            list.add(item);
          });
          list.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
          taskReports = list;
          notifyListeners();
        } catch (e) {
          debugPrint('[DataService] Lỗi parse taskReports từ Firebase: $e');
        }
      }
    });

    // 5. Ngân sách & Hậu cần
    _firebaseService.budgetLogisticsStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final map = <String, ActivityBudgetLogistics>{};
          data.forEach((k, v) {
            map[k] = ActivityBudgetLogistics.fromMap(Map<String, dynamic>.from(v as Map));
          });
          budgetLogisticsMap = map;
          notifyListeners();
        } catch (e) {
          debugPrint('[DataService] Lỗi parse budgetLogistics từ Firebase: $e');
        }
      }
    });

    // 6. Thông báo Admin
    _firebaseService.adminNotificationsStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final list = <AdminNotification>[];
          data.forEach((k, v) {
            list.add(AdminNotification.fromMap(Map<String, dynamic>.from(v as Map)));
          });
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          adminNotifications = list;
          notifyListeners();
        } catch (e) {
          debugPrint('[DataService] Lỗi parse adminNotifications từ Firebase: $e');
        }
      }
    });

    // 7. Sinh viên
    _firebaseService.volunteersStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          if (data.containsKey(currentVolunteer.id)) {
            currentVolunteer = Volunteer.fromMap(
              Map<String, dynamic>.from(data[currentVolunteer.id] as Map),
            );
            notifyListeners();
          }
        } catch (e) {
          debugPrint('[DataService] Lỗi parse volunteer từ Firebase: $e');
        }
      }
    });

    // 8. Tài khoản Người dùng
    _firebaseService.usersStream?.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          final list = <UserAccount>[];
          data.forEach((k, v) {
            list.add(UserAccount.fromMap(Map<String, dynamic>.from(v as Map)));
          });
          users = list;
          notifyListeners();
        } catch (e) {
          debugPrint('[DataService] Lỗi parse users từ Firebase: $e');
        }
      }
    });
  }

  // --- HÀM THỰC HIỆN ĐẨY TOÀN BỘ DỮ LIỆU LÊN FIREBASE (MANUAL / BUTTON) ---
  Future<bool> syncToFirebase() async {
    _isSyncingFirebase = true;
    _lastSyncMessage = 'Đang đồng bộ dữ liệu lên Firebase...';
    notifyListeners();

    try {
      await _firebaseService.seedDatabase(
        defaultVolunteer: currentVolunteer,
        defaultFaculties: faculties,
        defaultCampaigns: campaigns,
        defaultRegistrations: registrations,
        defaultTaskReports: taskReports,
        defaultBudgetLogistics: budgetLogisticsMap,
        defaultNotifications: adminNotifications,
        defaultUsers: users,
      );
      _lastSyncMessage = 'Đồng bộ Firebase thành công vào lúc ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}';
      _isSyncingFirebase = false;
      notifyListeners();
      return true;
    } catch (e) {
      _lastSyncMessage = 'Đồng bộ thất bại: $e';
      _isSyncingFirebase = false;
      notifyListeners();
      return false;
    }
  }

  // --- QUẢN LÝ XÁC THỰC: ĐĂNG KÝ, ĐĂNG NHẬP, ĐĂNG XUẤT ---

  // 1. Đăng ký tài khoản mới qua Firebase Authentication và lưu dữ liệu mở rộng lên RTDB
  Future<({bool success, String message, UserAccount? user})> registerUser({
    required String fullName,
    required String phone,
    required String email,
    required String faculty,
    required String academicYear,
    required String username,
    required String password,
    String? studentId,
    bool autoLogin = false,
  }) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();
    final cleanEmail = email.trim().toLowerCase();

    if (cleanUsername.isEmpty || cleanPassword.isEmpty) {
      return (success: false, message: 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.', user: null);
    }

    if (cleanPassword.length < 6) {
      return (success: false, message: 'Mật khẩu phải có tối thiểu 6 ký tự theo tiêu chuẩn bảo mật.', user: null);
    }

    // Kiểm tra trùng username
    if (users.any((u) => u.username.toLowerCase() == cleanUsername)) {
      return (success: false, message: 'Tên đăng nhập "$cleanUsername" đã được đăng ký. Vui lòng chọn tên khác.', user: null);
    }

    // Kiểm tra trùng email nếu có nhập
    if (cleanEmail.isNotEmpty && users.any((u) => u.email.toLowerCase() == cleanEmail)) {
      return (success: false, message: 'Địa chỉ email này đã được sử dụng.', user: null);
    }

    String newUserId = 'usr_${DateTime.now().millisecondsSinceEpoch}';

    // 1. Nếu Firebase Authentication khả dụng, tạo tài khoản trên Firebase Auth
    if (_firebaseService.isFirebaseAuthAvailable) {
      try {
        final credential = await _firebaseService.signUpWithEmailPassword(
          email: cleanEmail,
          password: cleanPassword,
        );
        if (credential?.user != null) {
          newUserId = credential!.user!.uid;
          await credential.user!.updateDisplayName(fullName.trim());
        }
      } on FirebaseAuthException catch (e) {
        String errorMsg = 'Đăng ký Firebase Authentication thất bại.';
        switch (e.code) {
          case 'email-already-in-use':
            errorMsg = 'Địa chỉ email "$cleanEmail" đã được đăng ký trên Firebase Authentication.';
            break;
          case 'invalid-email':
            errorMsg = 'Địa chỉ email không đúng định dạng chuẩn.';
            break;
          case 'weak-password':
            errorMsg = 'Mật khẩu quá yếu theo chính sách bảo mật Firebase (tối thiểu 6 ký tự).';
            break;
          case 'operation-not-allowed':
            errorMsg = 'Tính năng đăng nhập Email/Password chưa được kích hoạt trên Firebase Console.';
            break;
          case 'network-request-failed':
            errorMsg = 'Lỗi kết nối mạng đến máy chủ Firebase. Vui lòng thử lại.';
            break;
          default:
            errorMsg = 'Lỗi Firebase Auth (${e.code}): ${e.message ?? ''}';
        }
        return (success: false, message: errorMsg, user: null);
      } catch (e) {
        debugPrint('[DataService] Lỗi ngoại lệ FirebaseAuth: $e');
      }
    }

    final newUser = UserAccount(
      id: newUserId,
      username: cleanUsername,
      password: cleanPassword,
      fullName: fullName.trim(),
      phone: phone.trim(),
      email: cleanEmail,
      faculty: faculty.trim(),
      academicYear: academicYear.trim(),
      role: 'volunteer',
      studentId: studentId?.trim(),
      createdAt: DateTime.now(),
    );

    // Lưu vào danh sách cục bộ
    users.add(newUser);
    // Đẩy trực tiếp lên Firebase Realtime Database
    await _firebaseService.saveUser(newUser);

    // Tự động tạo hồ sơ sinh viên tương ứng
    final newVol = Volunteer(
      id: 'vol_${newUserId.replaceFirst('usr_', '')}',
      studentId: studentId?.trim().isNotEmpty == true
          ? studentId!.trim()
          : 'SV${newUserId.length >= 6 ? newUserId.substring(newUserId.length - 6) : newUserId}',
      fullName: fullName.trim(),
      email: cleanEmail,
      phone: phone.trim(),
      faculty: faculty.trim(),
      teamName: 'Đội hình Sinh viên Tình nguyện',
      totalHours: 0,
      totalPoints: 0,
      completedActivities: 0,
    );
    currentVolunteer = newVol;
    _firebaseService.saveVolunteer(newVol);

    if (autoLogin) {
      currentUser = newUser;
      notifyListeners();
    }

    return (success: true, message: 'Đăng ký tài khoản thành công với Firebase Authentication!', user: newUser);
  }

  // Hoàn tất đăng nhập và cập nhật trạng thái người dùng
  void completeLogin(UserAccount user) {
    currentUser = user;

    final assignedStudentId = (user.studentId != null && user.studentId!.trim().isNotEmpty)
        ? user.studentId!.trim()
        : (user.role == 'admin' ? 'BCH_${user.username}' : currentVolunteer.studentId);

    currentVolunteer = currentVolunteer.copyWith(
      id: user.studentId?.isNotEmpty == true
          ? 'vol_${user.studentId}'
          : 'vol_${user.id.replaceFirst('usr_', '')}',
      fullName: user.fullName,
      email: user.email,
      phone: user.phone,
      faculty: user.faculty,
      studentId: assignedStudentId,
    );

    notifyListeners();
  }

  // 2. Đăng nhập tài khoản tích hợp Firebase Authentication
  Future<({bool success, String message, UserAccount? user})> loginWithFirebaseAuth({
    required String usernameOrEmail,
    required String password,
    bool applyImmediately = true,
  }) async {
    final cleanInput = usernameOrEmail.trim().toLowerCase();
    final cleanPassword = password.trim();

    // 1. Xác định email đích để gửi tới Firebase Auth
    String targetEmail = cleanInput;
    UserAccount? localUser;

    // Tìm trong danh sách users nếu nhập username thay vì email
    final userIndex = users.indexWhere(
      (u) => u.username.toLowerCase() == cleanInput || u.email.toLowerCase() == cleanInput,
    );
    if (userIndex != -1) {
      localUser = users[userIndex];
      targetEmail = localUser.email.toLowerCase();
    }

    // 2. Nếu Firebase Authentication khả dụng và có địa chỉ email hợp lệ
    if (_firebaseService.isFirebaseAuthAvailable && targetEmail.contains('@')) {
      try {
        final credential = await _firebaseService.signInWithEmailPassword(
          email: targetEmail,
          password: cleanPassword,
        );

        if (credential?.user != null) {
          final uid = credential!.user!.uid;

          // Tìm UserAccount khớp với UID hoặc email
          UserAccount? matchedUser = users.firstWhere(
            (u) => u.id == uid || u.email.toLowerCase() == targetEmail,
            orElse: () {
              // Nếu tài khoản mới được tạo trực tiếp trên Firebase Auth console, tự động tạo hồ sơ UserAccount
              final createdUser = UserAccount(
                id: uid,
                username: credential.user!.email?.split('@').first ?? 'user_$uid',
                password: cleanPassword,
                fullName: credential.user!.displayName ?? 'Chiến Sĩ Tình Nguyện',
                phone: '',
                email: credential.user!.email ?? targetEmail,
                faculty: 'Khoa Công nghệ Thông tin & TT',
                academicYear: 'Khóa 2022 - 2026',
                role: 'volunteer',
                createdAt: DateTime.now(),
              );
              users.add(createdUser);
              _firebaseService.saveUser(createdUser);
              return createdUser;
            },
          );

          if (applyImmediately) {
            completeLogin(matchedUser);
          }

          return (
            success: true,
            message: 'Đăng nhập Firebase Authentication thành công! Chào mừng ${matchedUser.fullName}',
            user: matchedUser,
          );
        }
      } on FirebaseAuthException catch (e) {
        // Nếu lỗi tài khoản không tìm thấy trên Firebase Auth, kiểm tra xem có phải tài khoản demo nội bộ không (như admin)
        if ((e.code == 'user-not-found' || e.code == 'invalid-credential') &&
            localUser != null &&
            localUser.password == cleanPassword) {
          // Tự động đồng bộ tạo tài khoản demo này lên Firebase Auth để lần sau đăng nhập trực tiếp
          try {
            await _firebaseService.signUpWithEmailPassword(
              email: localUser.email,
              password: cleanPassword,
            );
          } catch (_) {}

          if (applyImmediately) {
            completeLogin(localUser);
          }
          return (
            success: true,
            message: 'Đăng nhập thành công! Chào mừng ${localUser.fullName}',
            user: localUser,
          );
        }

        String errorMsg = 'Đăng nhập thất bại.';
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            errorMsg = 'Tên đăng nhập / Email hoặc mật khẩu không chính xác.';
            break;
          case 'invalid-email':
            errorMsg = 'Địa chỉ email không đúng định dạng.';
            break;
          case 'user-disabled':
            errorMsg = 'Tài khoản này đã bị vô hiệu hóa trên Firebase.';
            break;
          case 'too-many-requests':
            errorMsg = 'Bạn đã thử đăng nhập sai quá nhiều lần. Vui lòng đợi trong giây lát.';
            break;
          case 'network-request-failed':
            errorMsg = 'Không thể kết nối đến Firebase Auth. Kiểm tra mạng internet của bạn.';
            break;
          default:
            errorMsg = 'Lỗi xác thực (${e.code}): ${e.message ?? ''}';
        }
        return (success: false, message: errorMsg, user: null);
      } catch (e) {
        debugPrint('[DataService] Ngoại lệ FirebaseAuth signIn: $e');
      }
    }

    // 3. Fallback cho môi trường test hoặc local accounts
    return loginUser(
      username: usernameOrEmail,
      password: password,
      applyImmediately: applyImmediately,
    );
  }

  // Phương thức đăng nhập local / fallback (dùng cho tests và offline)
  ({bool success, String message, UserAccount? user}) loginUser({
    required String username,
    required String password,
    bool applyImmediately = true,
  }) {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();

    final index = users.indexWhere(
      (u) => (u.username.toLowerCase() == cleanUsername || u.email.toLowerCase() == cleanUsername) &&
             u.password == cleanPassword,
    );

    if (index == -1) {
      return (
        success: false,
        message: 'Tên đăng nhập hoặc mật khẩu không chính xác.',
        user: null,
      );
    }

    final user = users[index];
    if (applyImmediately) {
      completeLogin(user);
    }

    return (
      success: true,
      message: 'Đăng nhập thành công! Chào mừng ${user.fullName}',
      user: user,
    );
  }

  // 3. Đăng xuất tài khoản
  void logout() {
    currentUser = null;
    _firebaseService.signOut();
    notifyListeners();
  }

  // --- QUẢN LÝ QUÊN MẬT KHẨU & KHÔI PHỤC QUA EMAIL OTP ---

  final Map<String, ({String otp, DateTime expiry})> _pendingPasswordResetOtps = {};

  // Gửi mã OTP xác thực khôi phục mật khẩu tới email
  Future<({bool success, String message, String? otp})> sendPasswordResetOtp(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return (
        success: false,
        message: 'Vui lòng nhập địa chỉ email hợp lệ.',
        otp: null,
      );
    }

    // Kiểm tra tài khoản có tồn tại không
    final userExists = users.any((u) => u.email.toLowerCase() == cleanEmail);
    if (!userExists) {
      return (
        success: false,
        message: 'Không tìm thấy tài khoản nào liên kết với email này ($cleanEmail).',
        otp: null,
      );
    }

    // Sinh mã OTP 6 số ngẫu nhiên
    final random = Random();
    final otp = (100000 + random.nextInt(900000)).toString();
    _pendingPasswordResetOtps[cleanEmail] = (
      otp: otp,
      expiry: DateTime.now().add(const Duration(minutes: 5)),
    );

    // In mã OTP ra terminal console để hỗ trợ kiểm thử và theo dõi hệ thống
    debugPrint('[Email Service] ========================================');
    debugPrint('[Email Service] Gửi mã xác thực OTP về hòm thư: $cleanEmail');
    debugPrint('[Email Service] Mã OTP bảo mật: $otp (Thời hạn 5 phút)');
    debugPrint('[Email Service] ========================================');

    // Nếu Firebase Auth khả dụng, có thể gửi đồng thời link email reset của Firebase
    if (_firebaseService.isFirebaseAuthAvailable) {
      try {
        await _firebaseService.sendPasswordResetEmail(cleanEmail);
      } catch (e) {
        debugPrint('[DataService] Gửi email Firebase reset password: $e');
      }
    }

    return (
      success: true,
      message: 'Mã xác thực OTP đã được gửi đến email $cleanEmail.',
      otp: otp,
    );
  }

  // Xác thực mã OTP và cập nhật mật khẩu mới
  Future<({bool success, String message})> verifyOtpAndResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();
    final cleanNewPassword = newPassword.trim();

    if (cleanNewPassword.length < 6) {
      return (
        success: false,
        message: 'Mật khẩu mới phải có ít nhất 6 ký tự.',
      );
    }

    final pending = _pendingPasswordResetOtps[cleanEmail];
    if (pending == null) {
      return (
        success: false,
        message: 'Chưa có yêu cầu gửi OTP hoặc mã đã hết hạn. Vui lòng bấm gửi lại.',
      );
    }

    if (DateTime.now().isAfter(pending.expiry)) {
      _pendingPasswordResetOtps.remove(cleanEmail);
      return (
        success: false,
        message: 'Mã OTP đã hết hạn (sau 5 phút). Vui lòng yêu cầu mã mới.',
      );
    }

    if (pending.otp != cleanOtp) {
      return (
        success: false,
        message: 'Mã OTP không chính xác. Vui lòng kiểm tra lại.',
      );
    }

    // Cập nhật mật khẩu trong danh sách người dùng
    final userIndex = users.indexWhere((u) => u.email.toLowerCase() == cleanEmail);
    if (userIndex != -1) {
      final updatedUser = users[userIndex].copyWith(password: cleanNewPassword);
      users[userIndex] = updatedUser;
      _firebaseService.saveUser(updatedUser);

      // Xóa mã OTP sau khi sử dụng thành công
      _pendingPasswordResetOtps.remove(cleanEmail);
      notifyListeners();

      return (
        success: true,
        message: 'Đặt lại mật khẩu thành công! Bạn có thể đăng nhập ngay bằng mật khẩu mới.',
      );
    }

    return (
      success: false,
      message: 'Không tìm thấy tài khoản người dùng để cập nhật.',
    );
  }

  // --- ACTIONS CHO SINH VIÊN ---

  // Đăng ký tham gia chiến dịch
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
      final updatedCamp = campaigns[campIndex].copyWith(
        currentRegistered: campaigns[campIndex].currentRegistered + 1,
      );
      campaigns[campIndex] = updatedCamp;
      _firebaseService.saveCampaign(updatedCamp);
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

    // Đồng bộ lên Firebase Realtime Database
    _firebaseService.saveRegistration(newReg);
    _firebaseService.saveAdminNotification(notif);

    notifyListeners();
    return true;
  }

  // --- ACTIONS THÔNG BÁO CHO ADMIN ---
  void markNotificationAsRead(String id) {
    final index = adminNotifications.indexWhere((n) => n.id == id);
    if (index >= 0 && !adminNotifications[index].isRead) {
      final updated = adminNotifications[index].copyWith(isRead: true);
      adminNotifications[index] = updated;
      _firebaseService.saveAdminNotification(updated);
      notifyListeners();
    }
  }

  void markAllNotificationsAsRead() {
    bool hasUnread = false;
    for (int i = 0; i < adminNotifications.length; i++) {
      if (!adminNotifications[i].isRead) {
        adminNotifications[i] = adminNotifications[i].copyWith(isRead: true);
        _firebaseService.saveAdminNotification(adminNotifications[i]);
        hasUnread = true;
      }
    }
    if (hasUnread) {
      notifyListeners();
    }
  }

  void deleteNotification(String id) {
    adminNotifications.removeWhere((n) => n.id == id);
    _firebaseService.deleteAdminNotification(id);
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
    final vId = (currentUser != null && currentUser!.studentId?.isNotEmpty == true)
        ? 'vol_${currentUser!.studentId}'
        : currentVolunteer.id;
    final vName = currentUser?.fullName ?? currentVolunteer.fullName;
    final sId = (currentUser?.studentId != null && currentUser!.studentId!.isNotEmpty)
        ? currentUser!.studentId!
        : currentVolunteer.studentId;

    final newReport = TaskReport(
      id: 'rep_${DateTime.now().millisecondsSinceEpoch}',
      volunteerId: vId,
      volunteerName: vName,
      studentId: sId,
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
    _firebaseService.saveTaskReport(newReport);

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
      final updated = old.copyWith(
        title: title ?? old.title,
        description: description ?? old.description,
        proofDescription: proofDescription ?? old.proofDescription,
        proofType: proofType ?? old.proofType,
        proofImageBytes: proofImageBytes ?? old.proofImageBytes,
        proofImageName: proofImageName ?? old.proofImageName,
        status: resubmit ? ReportStatus.pending : old.status,
        submittedAt: resubmit ? DateTime.now() : old.submittedAt,
      );
      taskReports[index] = updated;
      _firebaseService.saveTaskReport(updated);
      notifyListeners();
    }
  }

  // Cập nhật thông tin cá nhân
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
    _firebaseService.saveVolunteer(currentVolunteer);
    notifyListeners();
  }

  // --- ACTIONS CHO ADMIN / BAN CHỈ HUY ---

  // Quản lý Khoa / Viện
  void saveFaculty(Faculty faculty) {
    final index = faculties.indexWhere((f) => f.id == faculty.id);
    if (index >= 0) {
      faculties[index] = faculty;
      for (int i = 0; i < campaigns.length; i++) {
        if (campaigns[i].facultyId == faculty.id) {
          final updatedCamp = campaigns[i].copyWith(facultyName: faculty.name);
          campaigns[i] = updatedCamp;
          _firebaseService.saveCampaign(updatedCamp);
        }
      }
    } else {
      faculties.add(faculty);
    }
    _firebaseService.saveFaculty(faculty);
    notifyListeners();
  }

  void deleteFaculty(String facultyId) {
    faculties.removeWhere((f) => f.id == facultyId);
    for (int i = 0; i < campaigns.length; i++) {
      if (campaigns[i].facultyId == facultyId) {
        final updatedCamp = campaigns[i].copyWith(facultyId: null, facultyName: null);
        campaigns[i] = updatedCamp;
        _firebaseService.saveCampaign(updatedCamp);
      }
    }
    _firebaseService.deleteFaculty(facultyId);
    notifyListeners();
  }

  List<Campaign> getCampaignsByFaculty(String facultyId) {
    return campaigns.where((c) => c.facultyId == facultyId).toList();
  }

  int getCampaignCountByFaculty(String facultyId) {
    return campaigns.where((c) => c.facultyId == facultyId).length;
  }

  // Tạo hoặc cập nhật chiến dịch
  void saveCampaign(Campaign campaign) {
    final index = campaigns.indexWhere((c) => c.id == campaign.id);
    if (index >= 0) {
      campaigns[index] = campaign;
    } else {
      campaigns.insert(0, campaign);
      final newBudget = ActivityBudgetLogistics(
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
      budgetLogisticsMap[campaign.id] = newBudget;
      _firebaseService.saveBudgetLogistics(newBudget);
    }
    _firebaseService.saveCampaign(campaign);
    notifyListeners();
  }

  // Xóa chiến dịch
  void deleteCampaign(String id) {
    campaigns.removeWhere((c) => c.id == id);
    budgetLogisticsMap.remove(id);
    _firebaseService.deleteCampaign(id);
    notifyListeners();
  }

  // Phê duyệt đăng ký & phân đội hình
  void approveRegistration(String registrationId, String assignedTeam, String? note) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      final reg = registrations[index];
      final updated = reg.copyWith(
        status: RegistrationStatus.approved,
        assignedTeam: assignedTeam,
        note: note ?? 'Đã được Ban chỉ huy phê duyệt tham gia đội hình.',
      );
      registrations[index] = updated;
      _firebaseService.saveRegistration(updated);
      notifyListeners();
    }
  }

  // Từ chối đăng ký
  void rejectRegistration(String registrationId, String reason) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      final reg = registrations[index];
      final updated = reg.copyWith(
        status: RegistrationStatus.rejected,
        note: reason,
      );
      registrations[index] = updated;
      _firebaseService.saveRegistration(updated);
      notifyListeners();
    }
  }

  // Ghi nhận điểm danh
  void updateAttendance(String registrationId, int attendanceDays) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      final updated = registrations[index].copyWith(
        attendanceDays: attendanceDays,
      );
      registrations[index] = updated;
      _firebaseService.saveRegistration(updated);
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
      final updated = old.copyWith(
        status: status,
        awardedHours: awardedHours,
        awardedPoints: awardedPoints,
        feedback: feedback,
      );
      taskReports[index] = updated;
      _firebaseService.saveTaskReport(updated);

      if (status == ReportStatus.approved && old.volunteerId == currentVolunteer.id) {
        currentVolunteer = currentVolunteer.copyWith(
          totalHours: currentVolunteer.totalHours + awardedHours,
          totalPoints: currentVolunteer.totalPoints + awardedPoints,
        );
        _firebaseService.saveVolunteer(currentVolunteer);
      }
      notifyListeners();
    }
  }

  // Phê duyệt cấp chứng nhận điện tử
  void issueCertificate(String registrationId) {
    final index = registrations.indexWhere((r) => r.id == registrationId);
    if (index >= 0) {
      final updated = registrations[index].copyWith(
        isCertified: true,
      );
      registrations[index] = updated;
      _firebaseService.saveRegistration(updated);

      if (registrations[index].volunteerId == currentVolunteer.id) {
        currentVolunteer = currentVolunteer.copyWith(
          completedActivities: currentVolunteer.completedActivities + 1,
        );
        _firebaseService.saveVolunteer(currentVolunteer);
      }
      notifyListeners();
    }
  }

  // Cập nhật ngân sách và hậu cần
  void updateBudgetLogistics(ActivityBudgetLogistics data) {
    budgetLogisticsMap[data.campaignId] = data;
    _firebaseService.saveBudgetLogistics(data);
    notifyListeners();
  }

  void toggleLowBandwidthMode() {
    isLowBandwidthMode = !isLowBandwidthMode;
    notifyListeners();
  }
}

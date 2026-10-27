import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/faculty.dart';
import '../models/campaign.dart';
import '../models/volunteer.dart';
import '../models/registration.dart';
import '../models/task_report.dart';
import '../models/budget_logistics.dart';
import '../models/admin_notification.dart';
import '../models/user_account.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  FirebaseDatabase? get _db {
    try {
      return FirebaseDatabase.instance;
    } catch (e) {
      // Bắt ngoại lệ khi chạy trong môi trường test hoặc chưa initialize Firebase
      return null;
    }
  }

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  DatabaseReference? get _rootRef => _db?.ref();

  // Khởi tạo và lắng nghe trạng thái kết nối
  void initConnectionListener(void Function(bool connected) onConnectionChanged) {
    final db = _db;
    if (db == null) return;

    try {
      db.ref('.info/connected').onValue.listen((event) {
        final connected = (event.snapshot.value as bool?) ?? false;
        _isConnected = connected;
        debugPrint('[FirebaseService] Trạng thái kết nối RTDB: $connected');
        onConnectionChanged(connected);
      }, onError: (e) {
        debugPrint('[FirebaseService] Lỗi kết nối RTDB: $e');
      });
    } catch (e) {
      debugPrint('[FirebaseService] Exception in initConnectionListener: $e');
    }
  }

  // --- KIỂM TRA VÀ TỰ ĐỘNG SEED DỮ LIỆU NẾU DATABASE TRỐNG ---
  Future<bool> isDatabaseEmpty() async {
    final db = _db;
    if (db == null) return false;

    try {
      final snapshot = await db.ref('campaigns').get();
      return !snapshot.exists || snapshot.value == null;
    } catch (e) {
      debugPrint('[FirebaseService] Error checking isDatabaseEmpty: $e');
      return false;
    }
  }

  // Đẩy toàn bộ dữ liệu mẫu lên Firebase Realtime Database
  Future<void> seedDatabase({
    required Volunteer defaultVolunteer,
    required List<Faculty> defaultFaculties,
    required List<Campaign> defaultCampaigns,
    required List<Registration> defaultRegistrations,
    required List<TaskReport> defaultTaskReports,
    required Map<String, ActivityBudgetLogistics> defaultBudgetLogistics,
    required List<AdminNotification> defaultNotifications,
    List<UserAccount>? defaultUsers,
  }) async {
    final root = _rootRef;
    if (root == null) {
      throw Exception('Firebase chưa được khởi tạo trên thiết bị này.');
    }

    try {
      debugPrint('[FirebaseService] Bắt đầu đẩy dữ liệu mẫu lên Firebase Realtime Database...');

      final Map<String, dynamic> facultiesMap = {};
      for (var f in defaultFaculties) {
        facultiesMap[f.id] = f.toMap();
      }

      final Map<String, dynamic> campaignsMap = {};
      for (var c in defaultCampaigns) {
        campaignsMap[c.id] = c.toMap();
      }

      final Map<String, dynamic> volunteersMap = {
        defaultVolunteer.id: defaultVolunteer.toMap(),
      };

      final Map<String, dynamic> registrationsMap = {};
      for (var r in defaultRegistrations) {
        registrationsMap[r.id] = r.toMap();
      }

      final Map<String, dynamic> reportsMap = {};
      for (var rep in defaultTaskReports) {
        reportsMap[rep.id] = rep.toMap();
      }

      final Map<String, dynamic> budgetMap = {};
      defaultBudgetLogistics.forEach((campaignId, budget) {
        budgetMap[campaignId] = budget.toMap();
      });

      final Map<String, dynamic> notifsMap = {};
      for (var n in defaultNotifications) {
        notifsMap[n.id] = n.toMap();
      }

      final Map<String, dynamic> usersMap = {};
      if (defaultUsers != null) {
        for (var u in defaultUsers) {
          usersMap[u.id] = u.toMap();
        }
      }

      final Map<String, dynamic> seedPayload = {
        'system_info': {
          'appName': 'Hệ Thống Quản Lý Chiến Dịch Tình Nguyện Mùa Hè Xanh',
          'version': '1.0.0',
          'universityCampusAddress': 'Số 1 Võ Văn Ngân, Phường Linh Chiểu, TP. Thủ Đức, TP. Hồ Chí Minh',
          'lastSyncedAt': DateTime.now().toIso8601String(),
        },
        'users': usersMap,
        'volunteers': volunteersMap,
        'faculties': facultiesMap,
        'campaigns': campaignsMap,
        'registrations': registrationsMap,
        'task_reports': reportsMap,
        'budget_logistics': budgetMap,
        'admin_notifications': notifsMap,
      };

      await root.update(seedPayload);
      debugPrint('[FirebaseService] Đã tạo thành công cơ sở dữ liệu trên Firebase!');
    } catch (e) {
      debugPrint('[FirebaseService] Lỗi khi tạo database trên Firebase: $e');
      rethrow;
    }
  }

  // --- CÁC HÀM CẬP NHẬT DỮ LIỆU THỜI GIAN THỰC (REALTIME CRUD) ---

  // 1. Hồ sơ Tình nguyện viên
  Future<void> saveVolunteer(Volunteer volunteer) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('volunteers/${volunteer.id}').set(volunteer.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving volunteer: $e');
    }
  }

  // 2. Khoa / Viện
  Future<void> saveFaculty(Faculty faculty) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('faculties/${faculty.id}').set(faculty.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving faculty: $e');
    }
  }

  Future<void> deleteFaculty(String facultyId) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('faculties/$facultyId').remove();
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting faculty: $e');
    }
  }

  // 3. Chiến dịch Tình nguyện
  Future<void> saveCampaign(Campaign campaign) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('campaigns/${campaign.id}').set(campaign.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving campaign: $e');
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('campaigns/$campaignId').remove();
      await db.ref('budget_logistics/$campaignId').remove();
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting campaign: $e');
    }
  }

  // 4. Đơn đăng ký tham gia
  Future<void> saveRegistration(Registration registration) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('registrations/${registration.id}').set(registration.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving registration: $e');
    }
  }

  // 5. Báo cáo nhiệm vụ / minh chứng
  Future<void> saveTaskReport(TaskReport report) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('task_reports/${report.id}').set(report.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving task report: $e');
    }
  }

  // 6. Ngân sách & Hậu cần
  Future<void> saveBudgetLogistics(ActivityBudgetLogistics data) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('budget_logistics/${data.campaignId}').set(data.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving budget logistics: $e');
    }
  }

  // 7. Thông báo Admin
  Future<void> saveAdminNotification(AdminNotification notification) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('admin_notifications/${notification.id}').set(notification.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving admin notification: $e');
    }
  }

  // Alias cho saveAdminNotification
  Future<void> saveNotification(AdminNotification notification) => saveAdminNotification(notification);

  Future<void> deleteAdminNotification(String id) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('admin_notifications/$id').remove();
    } catch (e) {
      debugPrint('[FirebaseService] Error deleting notification: $e');
    }
  }

  // 8. Tài khoản Người dùng
  Future<void> saveUser(UserAccount user) async {
    final db = _db;
    if (db == null) return;
    try {
      await db.ref('users/${user.id}').set(user.toMap());
    } catch (e) {
      debugPrint('[FirebaseService] Error saving user: $e');
    }
  }

  // --- LẮNG NGHE REALTIME DATABASE VÀ TRẢ VỀ STREAM ---

  Stream<DatabaseEvent>? get facultiesStream => _db?.ref('faculties').onValue;
  Stream<DatabaseEvent>? get campaignsStream => _db?.ref('campaigns').onValue;
  Stream<DatabaseEvent>? get registrationsStream => _db?.ref('registrations').onValue;
  Stream<DatabaseEvent>? get taskReportsStream => _db?.ref('task_reports').onValue;
  Stream<DatabaseEvent>? get budgetLogisticsStream => _db?.ref('budget_logistics').onValue;
  Stream<DatabaseEvent>? get adminNotificationsStream => _db?.ref('admin_notifications').onValue;
  Stream<DatabaseEvent>? get volunteersStream => _db?.ref('volunteers').onValue;
  Stream<DatabaseEvent>? get usersStream => _db?.ref('users').onValue;
}
